import 'dart:math';

abstract final class GeoMath {
  static const double _earthRadiusMeters = 6371000;

  static double distanceMeters(double fromLatitude, double fromLongitude, double toLatitude, double toLongitude) {
    final phi1 = _radians(fromLatitude);
    final phi2 = _radians(toLatitude);
    final deltaPhi = _radians(toLatitude - fromLatitude);
    final deltaLambda = _radians(toLongitude - fromLongitude);
    final a = sin(deltaPhi / 2) * sin(deltaPhi / 2) + cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    return 2 * _earthRadiusMeters * atan2(sqrt(a), sqrt(1 - a));
  }

  static double bearingDegrees(double fromLatitude, double fromLongitude, double toLatitude, double toLongitude) {
    final phi1 = _radians(fromLatitude);
    final phi2 = _radians(toLatitude);
    final deltaLambda = _radians(toLongitude - fromLongitude);
    final y = sin(deltaLambda) * cos(phi2);
    final x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLambda);
    return (_degrees(atan2(y, x)) + 360) % 360;
  }

  static double angleBetweenDegrees(double first, double second) {
    final difference = (first - second).abs() % 360;
    return difference > 180 ? 360 - difference : difference;
  }

  static double _radians(double degrees) => degrees * pi / 180;

  static double _degrees(double radians) => radians * 180 / pi;
}
