import 'dart:async';

import 'package:carlearn/layers/functional/SpeedCamera/domain/entities/speed_camera.dart';
import 'package:carlearn/layers/functional/SpeedCamera/domain/gateways/speed_camera_gateway.dart';
import 'package:carlearn/layers/functional/SpeedCamera/domain/gateways/speed_camera_preferences_gateway.dart';
import 'package:carlearn/layers/technical/Location/geo_position.dart';
import 'package:carlearn/layers/technical/Location/location_access.dart';
import 'package:carlearn/layers/technical/Location/location_source.dart';

class FakeSpeedCameraGateway implements SpeedCameraGateway {
  FakeSpeedCameraGateway(this.cameras);

  final List<SpeedCamera> cameras;

  @override
  Future<List<SpeedCamera>> loadAll() async => cameras;
}

class FakeSpeedCameraPreferencesGateway implements SpeedCameraPreferencesGateway {
  bool enabled = true;

  @override
  Future<bool> readAlertsEnabled() async => enabled;

  @override
  Future<void> writeAlertsEnabled(bool enabled) async => this.enabled = enabled;
}

class FakeLocationSource implements LocationSource {
  LocationAccess current = LocationAccess.granted;
  LocationAccess afterRequest = LocationAccess.granted;
  final List<LocationAccess> openedSettings = [];
  int requests = 0;
  StreamController<GeoPosition>? _controller;

  bool get isWatching => _controller?.hasListener ?? false;

  void emit(GeoPosition position) => _controller!.add(position);

  @override
  Future<LocationAccess> checkAccess() async => current;

  @override
  Future<LocationAccess> requestAccess() async {
    requests++;
    current = afterRequest;
    return current;
  }

  @override
  Future<void> openSettings(LocationAccess access) async => openedSettings.add(access);

  @override
  Stream<GeoPosition> watch() {
    _controller = StreamController<GeoPosition>();
    return _controller!.stream;
  }
}
