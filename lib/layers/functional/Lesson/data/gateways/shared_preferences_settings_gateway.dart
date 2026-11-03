import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/player_settings.dart';
import '../../domain/gateways/settings_gateway.dart';

class SharedPreferencesSettingsGateway implements SettingsGateway {
  const SharedPreferencesSettingsGateway(this._preferences);

  static const String _speedKey = 'settings.speed';
  static const String _voiceKey = 'settings.voiceName';
  static const String _accentKey = 'settings.accentIndex';

  final SharedPreferencesAsync _preferences;

  @override
  Future<PlayerSettings> read() async {
    const defaults = PlayerSettings.defaults;
    final storedSpeed = await _preferences.getDouble(_speedKey);
    return PlayerSettings(
      speed: PlayerSettings.availableSpeeds.contains(storedSpeed) ? storedSpeed! : defaults.speed,
      voiceName: await _preferences.getString(_voiceKey),
      accentIndex: await _preferences.getInt(_accentKey) ?? defaults.accentIndex,
    );
  }

  @override
  Future<void> write(PlayerSettings settings) async {
    await _preferences.setDouble(_speedKey, settings.speed);
    await _preferences.setInt(_accentKey, settings.accentIndex);
    final voiceName = settings.voiceName;
    if (voiceName != null) {
      await _preferences.setString(_voiceKey, voiceName);
    }
  }
}
