import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Location/geo_math.dart';
import '../../../../technical/Location/geo_position.dart';
import '../../../../technical/Location/location_access.dart';
import '../../../../technical/Location/location_source.dart';
import '../../domain/entities/speed_camera.dart';
import '../../domain/use_cases/load_speed_cameras_use_case.dart';
import '../../domain/use_cases/locate_speed_camera_ahead_use_case.dart';
import '../../domain/use_cases/read_speed_camera_alerts_enabled_use_case.dart';
import '../../domain/use_cases/save_speed_camera_alerts_enabled_use_case.dart';
import 'speed_camera_announcement.dart';
import 'speed_camera_state.dart';

class SpeedCameraCubit extends Cubit<SpeedCameraState> {
  SpeedCameraCubit({
    required this._loadCameras,
    required this._readAlertsEnabled,
    required this._saveAlertsEnabled,
    required this._locateAhead,
    required this._location,
    required this._announce,
  }) : super(const SpeedCameraState.loading());

  static const double _forgetDistanceMeters = 1500;
  static const Duration _reconnectDelay = Duration(seconds: 5);

  final LoadSpeedCamerasUseCase _loadCameras;
  final ReadSpeedCameraAlertsEnabledUseCase _readAlertsEnabled;
  final SaveSpeedCameraAlertsEnabledUseCase _saveAlertsEnabled;
  final LocateSpeedCameraAheadUseCase _locateAhead;
  final LocationSource _location;
  final Future<void> Function(String message) _announce;

  List<SpeedCamera> _cameras = const [];
  final Map<String, SpeedCamera> _announced = {};
  StreamSubscription<GeoPosition>? _positions;

  Future<void> load() async {
    try {
      _cameras = await _loadCameras();
    } on Exception {
      _cameras = const [];
    }
    if (isClosed) {
      return;
    }
    emit(state.copyWith(cameraCount: _cameras.length));
    if (!await _readAlertsEnabled()) {
      _emitIfOpen(state.copyWith(status: SpeedCameraStatus.disabled));
      return;
    }
    await _connect(await _location.checkAccess());
  }

  Future<void> setAlertsEnabled(bool enabled) async {
    await _saveAlertsEnabled(enabled);
    if (!enabled) {
      await _disconnect();
      _emitIfOpen(state.copyWith(status: SpeedCameraStatus.disabled, clearApproach: true, clearSpeed: true));
      return;
    }
    await _connect(await _location.requestAccess());
  }

  Future<void> grantAccess() async {
    final status = state.status;
    if (status == SpeedCameraStatus.blocked || status == SpeedCameraStatus.serviceDisabled) {
      await _location.openSettings(
        status == SpeedCameraStatus.blocked ? LocationAccess.blocked : LocationAccess.serviceDisabled,
      );
      return;
    }
    await _connect(await _location.requestAccess());
  }

  Future<void> refreshAccess() async {
    if (!state.needsAttention) {
      return;
    }
    await _connect(await _location.checkAccess());
  }

  @override
  Future<void> close() async {
    await _disconnect();
    return super.close();
  }

  Future<void> _connect(LocationAccess access) async {
    if (isClosed) {
      return;
    }
    if (_cameras.isEmpty) {
      emit(state.copyWith(status: SpeedCameraStatus.unavailable));
      return;
    }
    if (access != LocationAccess.granted) {
      await _disconnect();
      _emitIfOpen(state.copyWith(status: _statusFor(access), clearApproach: true, clearSpeed: true));
      return;
    }
    emit(state.copyWith(status: SpeedCameraStatus.active));
    if (_positions != null) {
      return;
    }
    _positions = _location.watch().listen(_onPosition, onError: (Object _) => _onLocationLost());
  }

  Future<void> _disconnect() async {
    final positions = _positions;
    _positions = null;
    _announced.clear();
    await positions?.cancel();
  }

  Future<void> _onLocationLost() async {
    await _disconnect();
    final access = await _location.checkAccess();
    if (access == LocationAccess.granted) {
      await Future<void>.delayed(_reconnectDelay);
    }
    await _connect(access);
  }

  void _onPosition(GeoPosition position) {
    if (isClosed) {
      return;
    }
    _announced.removeWhere((_, camera) =>
        GeoMath.distanceMeters(position.latitude, position.longitude, camera.latitude, camera.longitude) >
        _forgetDistanceMeters);
    final approach = _locateAhead(cameras: _cameras, position: position);
    emit(state.copyWith(approach: approach, clearApproach: approach == null, speedKmh: position.speedKmh));
    if (approach == null || _announced.containsKey(approach.camera.id)) {
      return;
    }
    _announced[approach.camera.id] = approach.camera;
    _announce(SpeedCameraAnnouncement.of(approach, speedKmh: position.speedKmh));
  }

  void _emitIfOpen(SpeedCameraState next) {
    if (!isClosed) {
      emit(next);
    }
  }

  SpeedCameraStatus _statusFor(LocationAccess access) => switch (access) {
        LocationAccess.granted => SpeedCameraStatus.active,
        LocationAccess.denied => SpeedCameraStatus.needsPermission,
        LocationAccess.blocked => SpeedCameraStatus.blocked,
        LocationAccess.serviceDisabled => SpeedCameraStatus.serviceDisabled,
      };
}
