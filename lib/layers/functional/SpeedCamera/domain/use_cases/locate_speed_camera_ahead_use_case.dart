import '../../../../technical/Location/geo_math.dart';
import '../../../../technical/Location/geo_position.dart';
import '../entities/speed_camera.dart';
import '../entities/speed_camera_approach.dart';

class LocateSpeedCameraAheadUseCase {
  const LocateSpeedCameraAheadUseCase();

  static const double warningDistanceMeters = 1000;
  static const double maxHeadingDeviationDegrees = 45;
  static const double minimumSpeedMetersPerSecond = 3;
  static const double _latitudeWindowDegrees = 0.012;
  static const double _longitudeWindowDegrees = 0.02;

  SpeedCameraApproach? call({required List<SpeedCamera> cameras, required GeoPosition position}) {
    if (position.speedMetersPerSecond < minimumSpeedMetersPerSecond) {
      return null;
    }
    SpeedCameraApproach? nearest;
    for (final camera in cameras) {
      if ((camera.latitude - position.latitude).abs() > _latitudeWindowDegrees ||
          (camera.longitude - position.longitude).abs() > _longitudeWindowDegrees) {
        continue;
      }
      final distance = GeoMath.distanceMeters(position.latitude, position.longitude, camera.latitude, camera.longitude);
      if (distance > warningDistanceMeters || (nearest != null && distance >= nearest.distanceMeters)) {
        continue;
      }
      final bearing = GeoMath.bearingDegrees(position.latitude, position.longitude, camera.latitude, camera.longitude);
      if (GeoMath.angleBetweenDegrees(bearing, position.headingDegrees) > maxHeadingDeviationDegrees) {
        continue;
      }
      nearest = SpeedCameraApproach(camera: camera, distanceMeters: distance);
    }
    return nearest;
  }
}
