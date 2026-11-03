import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/topic_model.dart';

class TopicAssetDataSource {
  const TopicAssetDataSource(this._bundle);

  static final RegExp _batchFile = RegExp(r'^sujets/lot(\d+)\.json$');

  final AssetBundle _bundle;

  Future<List<List<TopicModel>>> readBatches() async {
    final manifest = await AssetManifest.loadFromAssetBundle(_bundle);
    final paths = manifest.listAssets().where(_batchFile.hasMatch).toList()
      ..sort((a, b) => _batchNumber(a).compareTo(_batchNumber(b)));
    final batches = <List<TopicModel>>[];
    for (final path in paths) {
      final decoded = jsonDecode(await _bundle.loadString(path)) as List<dynamic>;
      batches.add([for (final raw in decoded.cast<Map<String, dynamic>>()) TopicModel(raw)]);
    }
    return batches;
  }

  int _batchNumber(String path) => int.parse(_batchFile.firstMatch(path)!.group(1)!);
}
