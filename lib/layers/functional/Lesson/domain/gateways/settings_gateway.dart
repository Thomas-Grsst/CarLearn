import '../entities/player_settings.dart';

abstract interface class SettingsGateway {
  Future<PlayerSettings> read();
  Future<void> write(PlayerSettings settings);
}
