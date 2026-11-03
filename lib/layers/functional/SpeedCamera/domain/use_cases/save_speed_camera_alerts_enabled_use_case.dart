import '../gateways/speed_camera_preferences_gateway.dart';

class SaveSpeedCameraAlertsEnabledUseCase {
  const SaveSpeedCameraAlertsEnabledUseCase(this._preferencesGateway);

  final SpeedCameraPreferencesGateway _preferencesGateway;

  Future<void> call(bool enabled) => _preferencesGateway.writeAlertsEnabled(enabled);
}
