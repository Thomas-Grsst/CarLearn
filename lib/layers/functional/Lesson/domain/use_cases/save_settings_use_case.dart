import '../entities/player_settings.dart';
import '../gateways/settings_gateway.dart';

class SaveSettingsUseCase {
  const SaveSettingsUseCase(this._settingsGateway);

  final SettingsGateway _settingsGateway;

  Future<void> call(PlayerSettings settings) => _settingsGateway.write(settings);
}
