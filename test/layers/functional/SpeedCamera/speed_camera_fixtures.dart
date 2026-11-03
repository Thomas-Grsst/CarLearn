import 'package:carlearn/layers/functional/SpeedCamera/domain/entities/speed_camera.dart';
import 'package:carlearn/layers/functional/SpeedCamera/domain/entities/speed_camera_kind.dart';
import 'package:carlearn/layers/technical/Location/geo_position.dart';

const double originLatitude = 45.0;
const double originLongitude = 4.0;
const double metersPerLatitudeDegree = 111195;

SpeedCamera cameraNorthOf(double meters, {String id = 'r1', int speedLimitKmh = 80, double eastMeters = 0}) =>
    SpeedCamera(
      id: id,
      kind: SpeedCameraKind.fixed,
      speedLimitKmh: speedLimitKmh,
      latitude: originLatitude + meters / metersPerLatitudeDegree,
      longitude: originLongitude + eastMeters / (metersPerLatitudeDegree * 0.7071),
    );

GeoPosition positionNorthOf(double meters, {double headingDegrees = 0, double speedKmh = 90}) => GeoPosition(
      latitude: originLatitude + meters / metersPerLatitudeDegree,
      longitude: originLongitude,
      headingDegrees: headingDegrees,
      speedMetersPerSecond: speedKmh / 3.6,
    );
