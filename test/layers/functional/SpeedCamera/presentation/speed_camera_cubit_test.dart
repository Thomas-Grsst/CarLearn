import 'package:carlearn/layers/functional/SpeedCamera/domain/entities/speed_camera.dart';
import 'package:carlearn/layers/functional/SpeedCamera/domain/use_cases/load_speed_cameras_use_case.dart';
import 'package:carlearn/layers/functional/SpeedCamera/domain/use_cases/locate_speed_camera_ahead_use_case.dart';
import 'package:carlearn/layers/functional/SpeedCamera/domain/use_cases/read_speed_camera_alerts_enabled_use_case.dart';
import 'package:carlearn/layers/functional/SpeedCamera/domain/use_cases/save_speed_camera_alerts_enabled_use_case.dart';
import 'package:carlearn/layers/functional/SpeedCamera/presentation/cubit/speed_camera_cubit.dart';
import 'package:carlearn/layers/functional/SpeedCamera/presentation/cubit/speed_camera_state.dart';
import 'package:carlearn/layers/technical/Location/location_access.dart';
import 'package:flutter_test/flutter_test.dart';

import '../speed_camera_fixtures.dart';
import 'speed_camera_fakes.dart';

void main() {
  late FakeSpeedCameraPreferencesGateway preferences;
  late FakeLocationSource location;
  late List<String> announcements;

  SpeedCameraCubit buildCubit(List<SpeedCamera> cameras) => SpeedCameraCubit(
        loadCameras: LoadSpeedCamerasUseCase(FakeSpeedCameraGateway(cameras)),
        readAlertsEnabled: ReadSpeedCameraAlertsEnabledUseCase(preferences),
        saveAlertsEnabled: SaveSpeedCameraAlertsEnabledUseCase(preferences),
        locateAhead: const LocateSpeedCameraAheadUseCase(),
        location: location,
        announce: (message) async => announcements.add(message),
      );

  Future<void> drive(SpeedCameraCubit cubit, double meters, {double speedKmh = 90}) async {
    location.emit(positionNorthOf(meters, speedKmh: speedKmh));
    await Future<void>.delayed(Duration.zero);
  }

  setUp(() {
    preferences = FakeSpeedCameraPreferencesGateway();
    location = FakeLocationSource();
    announcements = [];
  });

  test('announces a camera once when it comes within one kilometre', () async {
    final cubit = buildCubit([cameraNorthOf(2000, speedLimitKmh: 70)]);
    await cubit.load();

    expect(cubit.state.status, SpeedCameraStatus.active);
    await drive(cubit, 0);
    expect(announcements, isEmpty);
    await drive(cubit, 1010);
    await drive(cubit, 1300);
    await drive(cubit, 1800);

    expect(announcements, ['Attention, radar fixe dans 1 kilomètre. Vitesse limitée à 70. Ralentis.']);
    expect(cubit.state.approach!.camera.speedLimitKmh, 70);
    expect(cubit.state.isOverSpeedLimit, isTrue);
    await cubit.close();
  });

  test('clears the alert once the camera is passed', () async {
    final cubit = buildCubit([cameraNorthOf(500)]);
    await cubit.load();

    await drive(cubit, 0);
    expect(cubit.state.approach, isNotNull);
    await drive(cubit, 600);

    expect(cubit.state.approach, isNull);
    expect(announcements, hasLength(1));
    await cubit.close();
  });

  test('announces the same camera again on a later trip', () async {
    final cubit = buildCubit([cameraNorthOf(500)]);
    await cubit.load();

    await drive(cubit, 0);
    await drive(cubit, 2500);
    await drive(cubit, -1600);
    await drive(cubit, 0);

    expect(announcements, hasLength(2));
    await cubit.close();
  });

  test('waits for the driver to grant location access', () async {
    location
      ..current = LocationAccess.denied
      ..afterRequest = LocationAccess.granted;
    final cubit = buildCubit([cameraNorthOf(500)]);
    await cubit.load();

    expect(cubit.state.status, SpeedCameraStatus.needsPermission);
    expect(location.requests, 0);
    expect(location.isWatching, isFalse);

    await cubit.grantAccess();

    expect(cubit.state.status, SpeedCameraStatus.active);
    expect(location.isWatching, isTrue);
    await cubit.close();
  });

  test('sends the driver to the settings when access is blocked', () async {
    location.current = LocationAccess.blocked;
    final cubit = buildCubit([cameraNorthOf(500)]);
    await cubit.load();

    await cubit.grantAccess();
    expect(location.openedSettings, [LocationAccess.blocked]);

    location.current = LocationAccess.granted;
    await cubit.refreshAccess();
    expect(cubit.state.status, SpeedCameraStatus.active);
    await cubit.close();
  });

  test('stays off when the driver disabled the alerts', () async {
    preferences.enabled = false;
    final cubit = buildCubit([cameraNorthOf(500)]);
    await cubit.load();

    expect(cubit.state.status, SpeedCameraStatus.disabled);
    expect(location.isWatching, isFalse);

    await cubit.setAlertsEnabled(true);
    expect(preferences.enabled, isTrue);
    expect(cubit.state.status, SpeedCameraStatus.active);

    await cubit.setAlertsEnabled(false);
    expect(location.isWatching, isFalse);
    await cubit.close();
  });

  test('reports a missing camera list', () async {
    final cubit = buildCubit(const []);
    await cubit.load();

    expect(cubit.state.status, SpeedCameraStatus.unavailable);
    await cubit.close();
  });
}
