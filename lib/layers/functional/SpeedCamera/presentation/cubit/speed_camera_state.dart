import 'package:equatable/equatable.dart';

import '../../domain/entities/speed_camera_approach.dart';

enum SpeedCameraStatus { loading, disabled, unavailable, needsPermission, blocked, serviceDisabled, active }

class SpeedCameraState extends Equatable {
  const SpeedCameraState({
    required this.status,
    required this.cameraCount,
    required this.approach,
    required this.speedKmh,
  });

  const SpeedCameraState.loading()
      : status = SpeedCameraStatus.loading,
        cameraCount = 0,
        approach = null,
        speedKmh = null;

  final SpeedCameraStatus status;
  final int cameraCount;
  final SpeedCameraApproach? approach;
  final double? speedKmh;

  bool get alertsEnabled => status != SpeedCameraStatus.disabled;

  bool get needsAttention =>
      status == SpeedCameraStatus.needsPermission ||
      status == SpeedCameraStatus.blocked ||
      status == SpeedCameraStatus.serviceDisabled;

  bool get isOverSpeedLimit {
    final current = speedKmh;
    final limit = approach?.camera.speedLimitKmh;
    return current != null && limit != null && current > limit + 2;
  }

  SpeedCameraState copyWith({
    SpeedCameraStatus? status,
    int? cameraCount,
    SpeedCameraApproach? approach,
    bool clearApproach = false,
    double? speedKmh,
    bool clearSpeed = false,
  }) =>
      SpeedCameraState(
        status: status ?? this.status,
        cameraCount: cameraCount ?? this.cameraCount,
        approach: clearApproach ? null : (approach ?? this.approach),
        speedKmh: clearSpeed ? null : (speedKmh ?? this.speedKmh),
      );

  @override
  List<Object?> get props => [status, cameraCount, approach, speedKmh];
}
