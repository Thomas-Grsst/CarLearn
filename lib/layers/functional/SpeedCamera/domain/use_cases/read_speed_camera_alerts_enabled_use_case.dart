import '../gateways/speed_camera_preferences_gateway.dart';

class ReadSpeedCameraAlertsEnabledUseCase {
  const ReadSpeedCameraAlertsEnabledUseCase(this._preferencesGateway);

  final SpeedCameraPreferencesGateway _preferencesGateway;

  Future<bool> call() => _preferencesGateway.readAlertsEnabled();
}
