import '../../domain/entities/speed_camera_approach.dart';

abstract final class SpeedCameraAnnouncement {
  static const double _closeDistanceMeters = 200;
  static const double _fullKilometerMeters = 950;
  static const int _overSpeedToleranceKmh = 2;

  static String of(SpeedCameraApproach approach, {double? speedKmh}) {
    final camera = approach.camera;
    final where = _distanceLabel(approach.distanceMeters);
    final limit = 'Vitesse limitée à ${camera.speedLimitKmh}.';
    final tooFast = speedKmh != null && speedKmh > camera.speedLimitKmh + _overSpeedToleranceKmh ? ' Ralentis.' : '';
    return 'Attention, ${camera.kind.label} $where. $limit$tooFast';
  }

  static String distanceLabel(double distanceMeters) {
    if (distanceMeters >= _fullKilometerMeters) {
      return '1 km';
    }
    return '${_roundedMeters(distanceMeters)} m';
  }

  static String _distanceLabel(double distanceMeters) {
    if (distanceMeters >= _fullKilometerMeters) {
      return 'dans 1 kilomètre';
    }
    if (distanceMeters < _closeDistanceMeters) {
      return 'tout proche';
    }
    return 'dans ${_roundedMeters(distanceMeters)} mètres';
  }

  static int _roundedMeters(double distanceMeters) => ((distanceMeters / 100).round() * 100).clamp(100, 1000);
}
