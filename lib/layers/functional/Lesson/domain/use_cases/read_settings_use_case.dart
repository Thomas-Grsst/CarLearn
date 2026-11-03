import '../entities/player_settings.dart';
import '../gateways/settings_gateway.dart';

class ReadSettingsUseCase {
  const ReadSettingsUseCase(this._settingsGateway);

  final SettingsGateway _settingsGateway;

  Future<PlayerSettings> call() => _settingsGateway.read();
}
