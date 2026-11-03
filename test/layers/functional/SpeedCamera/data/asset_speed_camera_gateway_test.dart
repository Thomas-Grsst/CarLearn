import 'dart:convert';

import 'package:carlearn/layers/functional/SpeedCamera/data/data_sources/speed_camera_asset_data_source.dart';
import 'package:carlearn/layers/functional/SpeedCamera/data/gateways/asset_speed_camera_gateway.dart';
import 'package:carlearn/layers/functional/SpeedCamera/domain/entities/speed_camera_kind.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

class _MemoryAssetBundle extends CachingAssetBundle {
  _MemoryAssetBundle(this._files);

  final Map<String, String> _files;

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      final manifest = {for (final path in _files.keys) path: <Object>[]};
      return const StandardMessageCodec().encodeMessage(manifest)!;
    }
    final content = _files[key];
    if (content == null) {
      throw StateError('Missing asset $key');
    }
    return ByteData.sublistView(utf8.encode(content));
  }
}

void main() {
  test('reads valid cameras and skips broken entries', () async {
    final bundle = _MemoryAssetBundle({
      SpeedCameraAssetDataSource.assetPath: jsonEncode([
        {'id': '1', 'type': 'ETVM', 'vma': 110, 'lat': 45.1, 'lon': 4.2},
        {'id': '2', 'type': 'ETF', 'vma': '?', 'lat': 45.1, 'lon': 4.2},
      ]),
    });

    final cameras = await AssetSpeedCameraGateway(SpeedCameraAssetDataSource(bundle)).loadAll();

    expect(cameras, hasLength(1));
    expect(cameras.single.kind, SpeedCameraKind.averageSpeed);
    expect(cameras.single.speedLimitKmh, 110);
  });

  test('returns no camera when the list was not bundled', () async {
    final cameras = await AssetSpeedCameraGateway(SpeedCameraAssetDataSource(_MemoryAssetBundle({}))).loadAll();

    expect(cameras, isEmpty);
  });
}
