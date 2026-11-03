import 'dart:convert';
import 'dart:io';

import 'speed_camera_csv.dart';

const String _datasetApi = 'https://www.data.gouv.fr/api/1/datasets/liste-des-radars-fixes-en-france/';
const String _fallbackCsv =
    'https://static.data.gouv.fr/resources/liste-des-radars-fixes-en-france/20251230-134204/jeu-de-donnees-liste-des-radars-fixes-en-france-12-2025.csv';
const int _minimumCameraCount = 1000;

Future<void> main(List<String> arguments) async {
  final output = File(arguments.isEmpty ? 'radars/radars.json' : arguments.first);
  final client = HttpClient();
  try {
    final csvUrl = await _latestCsvUrl(client) ?? _fallbackCsv;
    stdout.writeln('Téléchargement de $csvUrl');
    final cameras = SpeedCameraCsv.parse(_decode(await _download(client, Uri.parse(csvUrl))));
    if (cameras.length < _minimumCameraCount) {
      stderr.writeln('Seulement ${cameras.length} radars lus : fichier incomplet.');
      exitCode = 1;
      return;
    }
    await output.parent.create(recursive: true);
    await output.writeAsString(jsonEncode(cameras));
    stdout.writeln('${cameras.length} radars écrits dans ${output.path}');
  } finally {
    client.close();
  }
}

Future<String?> _latestCsvUrl(HttpClient client) async {
  try {
    final dataset = jsonDecode(utf8.decode(await _download(client, Uri.parse(_datasetApi)))) as Map<String, dynamic>;
    final resources = (dataset['resources'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .where((resource) => '${resource['format']}'.toLowerCase() == 'csv')
        .toList()
      ..sort((a, b) => '${b['last_modified']}'.compareTo('${a['last_modified']}'));
    return resources.isEmpty ? null : resources.first['url'] as String;
  } on Exception catch (error) {
    stderr.writeln('API data.gouv.fr indisponible ($error), utilisation du fichier connu.');
    return null;
  }
}

Future<List<int>> _download(HttpClient client, Uri uri) async {
  final request = await client.getUrl(uri);
  final response = await request.close();
  if (response.statusCode != HttpStatus.ok) {
    throw HttpException('HTTP ${response.statusCode}', uri: uri);
  }
  final bytes = <int>[];
  await for (final chunk in response) {
    bytes.addAll(chunk);
  }
  return bytes;
}

String _decode(List<int> bytes) {
  try {
    return utf8.decode(bytes);
  } on FormatException {
    return latin1.decode(bytes);
  }
}
