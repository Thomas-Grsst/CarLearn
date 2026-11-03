import '../../domain/entities/speed_camera.dart';
import '../../domain/gateways/speed_camera_gateway.dart';
import '../data_sources/speed_camera_asset_data_source.dart';

class AssetSpeedCameraGateway implements SpeedCameraGateway {
  const AssetSpeedCameraGateway(this._dataSource);

  final SpeedCameraAssetDataSource _dataSource;

  @override
  Future<List<SpeedCamera>> loadAll() async {
    final models = await _dataSource.readAll();
    return [for (final model in models) if (model.isValid) model.toEntity()];
  }
}
