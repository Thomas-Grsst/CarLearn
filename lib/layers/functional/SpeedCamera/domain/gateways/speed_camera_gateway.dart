import '../entities/speed_camera.dart';

abstract interface class SpeedCameraGateway {
  Future<List<SpeedCamera>> loadAll();
}
