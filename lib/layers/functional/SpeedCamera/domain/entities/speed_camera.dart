import 'package:equatable/equatable.dart';

import 'speed_camera_kind.dart';

class SpeedCamera extends Equatable {
  const SpeedCamera({
    required this.id,
    required this.kind,
    required this.speedLimitKmh,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final SpeedCameraKind kind;
  final int speedLimitKmh;
  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [id, kind, speedLimitKmh, latitude, longitude];
}
