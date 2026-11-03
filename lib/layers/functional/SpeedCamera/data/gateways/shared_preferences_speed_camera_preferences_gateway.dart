import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/gateways/speed_camera_preferences_gateway.dart';

class SharedPreferencesSpeedCameraPreferencesGateway implements SpeedCameraPreferencesGateway {
  const SharedPreferencesSpeedCameraPreferencesGateway(this._preferences);

  static const String _alertsEnabledKey = 'speedCamera.alertsEnabled';

  final SharedPreferencesAsync _preferences;

  @override
  Future<bool> readAlertsEnabled() async => await _preferences.getBool(_alertsEnabledKey) ?? true;

  @override
  Future<void> writeAlertsEnabled(bool enabled) => _preferences.setBool(_alertsEnabledKey, enabled);
}
