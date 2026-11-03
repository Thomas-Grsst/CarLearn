import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/speed_camera_model.dart';

class SpeedCameraAssetDataSource {
  const SpeedCameraAssetDataSource(this._bundle);

  static const String assetPath = 'radars/radars.json';

  final AssetBundle _bundle;

  Future<List<SpeedCameraModel>> readAll() async {
    final manifest = await AssetManifest.loadFromAssetBundle(_bundle);
    if (!manifest.listAssets().contains(assetPath)) {
      return const [];
    }
    final decoded = jsonDecode(await _bundle.loadString(assetPath)) as List<dynamic>;
    return [for (final raw in decoded.cast<Map<String, dynamic>>()) SpeedCameraModel(raw)];
  }
}
