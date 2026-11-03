abstract interface class SpeedCameraPreferencesGateway {
  Future<bool> readAlertsEnabled();
  Future<void> writeAlertsEnabled(bool enabled);
}
