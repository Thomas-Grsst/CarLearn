import '../../domain/entities/speed_camera.dart';
import '../../domain/entities/speed_camera_kind.dart';

class SpeedCameraModel {
  const SpeedCameraModel(this._json);

  final Map<String, dynamic> _json;

  bool get isValid =>
      _json['id'] is String && _json['type'] is String && _json['vma'] is int && _json['lat'] is num && _json['lon'] is num;

  SpeedCamera toEntity() => SpeedCamera(
        id: _json['id'] as String,
        kind: SpeedCameraKind.fromCode(_json['type'] as String),
        speedLimitKmh: _json['vma'] as int,
        latitude: (_json['lat'] as num).toDouble(),
        longitude: (_json['lon'] as num).toDouble(),
      );
}
