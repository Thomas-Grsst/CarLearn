import 'package:carlearn/layers/functional/SpeedCamera/domain/entities/speed_camera_approach.dart';
import 'package:carlearn/layers/functional/SpeedCamera/presentation/cubit/speed_camera_announcement.dart';
import 'package:flutter_test/flutter_test.dart';

import '../speed_camera_fixtures.dart';

void main() {
  SpeedCameraApproach approachAt(double meters, {int speedLimitKmh = 80}) =>
      SpeedCameraApproach(camera: cameraNorthOf(meters, speedLimitKmh: speedLimitKmh), distanceMeters: meters);

  test('announces the camera one kilometre ahead with its speed limit', () {
    expect(
      SpeedCameraAnnouncement.of(approachAt(990), speedKmh: 78),
      'Attention, radar fixe dans 1 kilomètre. Vitesse limitée à 80.',
    );
  });

  test('rounds a closer camera to the nearest hundred metres', () {
    expect(
      SpeedCameraAnnouncement.of(approachAt(640, speedLimitKmh: 50)),
      'Attention, radar fixe dans 600 mètres. Vitesse limitée à 50.',
    );
  });

  test('asks to slow down when driving above the limit', () {
    expect(
      SpeedCameraAnnouncement.of(approachAt(990, speedLimitKmh: 110), speedKmh: 128),
      'Attention, radar fixe dans 1 kilomètre. Vitesse limitée à 110. Ralentis.',
    );
  });

  test('formats the distance shown on screen', () {
    expect(SpeedCameraAnnouncement.distanceLabel(960), '1 km');
    expect(SpeedCameraAnnouncement.distanceLabel(430), '400 m');
    expect(SpeedCameraAnnouncement.distanceLabel(20), '100 m');
  });
}
