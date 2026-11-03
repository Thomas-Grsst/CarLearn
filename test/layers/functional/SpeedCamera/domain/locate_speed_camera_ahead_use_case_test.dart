import 'package:carlearn/layers/functional/SpeedCamera/domain/use_cases/locate_speed_camera_ahead_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../speed_camera_fixtures.dart';

void main() {
  const locate = LocateSpeedCameraAheadUseCase();

  test('finds a camera ahead within one kilometre', () {
    final approach = locate(cameras: [cameraNorthOf(900)], position: positionNorthOf(0));

    expect(approach, isNotNull);
    expect(approach!.distanceMeters, closeTo(900, 5));
  });

  test('ignores a camera further than one kilometre', () {
    expect(locate(cameras: [cameraNorthOf(1100)], position: positionNorthOf(0)), isNull);
  });

  test('ignores a camera behind the car', () {
    expect(locate(cameras: [cameraNorthOf(-500)], position: positionNorthOf(0)), isNull);
  });

  test('ignores a camera off to the side of the heading', () {
    expect(locate(cameras: [cameraNorthOf(300, eastMeters: 600)], position: positionNorthOf(0)), isNull);
  });

  test('ignores cameras while the car is stopped', () {
    expect(locate(cameras: [cameraNorthOf(500)], position: positionNorthOf(0, speedKmh: 5)), isNull);
  });

  test('picks the nearest camera ahead', () {
    final approach = locate(
      cameras: [cameraNorthOf(800, id: 'far'), cameraNorthOf(400, id: 'near'), cameraNorthOf(-100, id: 'behind')],
      position: positionNorthOf(0),
    );

    expect(approach!.camera.id, 'near');
  });

  test('handles headings that wrap around north', () {
    final approach = locate(cameras: [cameraNorthOf(600, eastMeters: -50)], position: positionNorthOf(0, headingDegrees: 355));

    expect(approach, isNotNull);
  });
}
