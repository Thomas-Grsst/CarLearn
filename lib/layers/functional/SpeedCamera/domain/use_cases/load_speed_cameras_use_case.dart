import '../entities/speed_camera.dart';
import '../gateways/speed_camera_gateway.dart';

class LoadSpeedCamerasUseCase {
  const LoadSpeedCamerasUseCase(this._speedCameraGateway);

  final SpeedCameraGateway _speedCameraGateway;

  Future<List<SpeedCamera>> call() => _speedCameraGateway.loadAll();
}
