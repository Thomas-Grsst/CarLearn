import 'package:equatable/equatable.dart';

class GeoPosition extends Equatable {
  const GeoPosition({
    required this.latitude,
    required this.longitude,
    required this.headingDegrees,
    required this.speedMetersPerSecond,
  });

  final double latitude;
  final double longitude;
  final double headingDegrees;
  final double speedMetersPerSecond;

  double get speedKmh => speedMetersPerSecond * 3.6;

  @override
  List<Object?> get props => [latitude, longitude, headingDegrees, speedMetersPerSecond];
}
