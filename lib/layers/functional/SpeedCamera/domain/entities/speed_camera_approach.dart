import 'package:equatable/equatable.dart';

import 'speed_camera.dart';

class SpeedCameraApproach extends Equatable {
  const SpeedCameraApproach({required this.camera, required this.distanceMeters});

  final SpeedCamera camera;
  final double distanceMeters;

  @override
  List<Object?> get props => [camera, distanceMeters];
}
