import 'package:carlearn/layers/functional/SpeedCamera/domain/entities/speed_camera.dart';
import 'package:carlearn/layers/functional/SpeedCamera/domain/use_cases/load_speed_cameras_use_case.dart';
import 'package:carlearn/layers/functional/SpeedCamera/domain/use_cases/locate_speed_camera_ahead_use_case.dart';
import 'package:carlearn/layers/functional/SpeedCamera/domain/use_cases/read_speed_camera_alerts_enabled_use_case.dart';
import 'package:carlearn/layers/functional/SpeedCamera/domain/use_cases/save_speed_camera_alerts_enabled_use_case.dart';
import 'package:carlearn/layers/functional/SpeedCamera/presentation/cubit/speed_camera_cubit.dart';
import 'package:carlearn/layers/functional/SpeedCamera/presentation/widgets/speed_camera_banner.dart';
import 'package:carlearn/layers/technical/Location/location_access.dart';
import 'package:carlearn/layers/technical/Theme/app_colors.dart';
import 'package:carlearn/layers/technical/Theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import '../speed_camera_fixtures.dart';
import 'speed_camera_fakes.dart';

void main() {
  Future<SpeedCameraCubit> pumpBanner(WidgetTester tester, FakeLocationSource location, List<SpeedCamera> cameras) async {
    final preferences = FakeSpeedCameraPreferencesGateway();
    final cubit = SpeedCameraCubit(
      loadCameras: LoadSpeedCamerasUseCase(FakeSpeedCameraGateway(cameras)),
      readAlertsEnabled: ReadSpeedCameraAlertsEnabledUseCase(preferences),
      saveAlertsEnabled: SaveSpeedCameraAlertsEnabledUseCase(preferences),
      locateAhead: const LocateSpeedCameraAheadUseCase(),
      location: location,
      announce: (_) async {},
    );
    await tester.runAsync(cubit.load);
    await tester.pumpWidget(BlocProvider.value(
      value: cubit,
      child: MaterialApp(theme: AppTheme.dark(AppColors.accent(0)), home: const Scaffold(body: SpeedCameraBanner())),
    ));
    addTearDown(cubit.close);
    return cubit;
  }

  testWidgets('shows the speed limit and the distance of the camera ahead', (tester) async {
    final location = FakeLocationSource();
    await pumpBanner(tester, location, [cameraNorthOf(700, speedLimitKmh: 90)]);

    await tester.runAsync(() async {
      location.emit(positionNorthOf(0, speedKmh: 104));
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pump();

    expect(find.text('90'), findsOneWidget);
    expect(find.text('dans 700 m'), findsOneWidget);
    expect(find.text('Tu roules à 104 km/h : ralentis'), findsOneWidget);
  });

  testWidgets('asks for location access when it is missing', (tester) async {
    final location = FakeLocationSource()..current = LocationAccess.denied;
    final cubit = await pumpBanner(tester, location, [cameraNorthOf(700)]);

    expect(find.text('Autoriser'), findsOneWidget);
    await tester.tap(find.text('Autoriser'));
    await tester.pump();

    expect(location.requests, 1);
    expect(cubit.state.needsAttention, isFalse);
    expect(find.text('Autoriser'), findsNothing);
  });
}
