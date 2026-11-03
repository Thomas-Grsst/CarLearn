abstract final class SpeedCameraCsv {
  static const String _separator = ';';

  static List<Map<String, Object>> parse(String csv) {
    final lines = csv.split(RegExp(r'\r?\n')).where((line) => line.trim().isNotEmpty).toList();
    if (lines.isEmpty) {
      return const [];
    }
    final header = lines.first.split(_separator).map(_normalize).toList();
    final idColumn = header.indexWhere((name) => name.startsWith('num') || name == 'id');
    final typeColumn = header.indexWhere((name) => name.startsWith('type'));
    final speedColumn = header.indexWhere((name) => name.startsWith('vma') || name.startsWith('vitesse'));
    final latitudeColumn = header.indexWhere((name) => name.startsWith('lat'));
    final longitudeColumn = header.indexWhere((name) => name.startsWith('lon'));
    if ([idColumn, typeColumn, speedColumn, latitudeColumn, longitudeColumn].contains(-1)) {
      throw FormatException('Colonnes inattendues : ${lines.first}');
    }
    final cameras = <Map<String, Object>>[];
    final seenIds = <String, int>{};
    for (final line in lines.skip(1)) {
      final cells = line.split(_separator).map((cell) => cell.trim()).toList();
      if (cells.length < header.length) {
        continue;
      }
      final speed = int.tryParse(cells[speedColumn]);
      final latitude = _coordinate(cells[latitudeColumn]);
      final longitude = _coordinate(cells[longitudeColumn]);
      if (speed == null || speed <= 0 || latitude == null || longitude == null) {
        continue;
      }
      if (latitude.abs() > 90 || longitude.abs() > 180 || (latitude == 0 && longitude == 0)) {
        continue;
      }
      final rawId = cells[idColumn].isEmpty ? 'radar' : cells[idColumn];
      final occurrence = seenIds.update(rawId, (count) => count + 1, ifAbsent: () => 1);
      cameras.add({
        'id': occurrence == 1 ? rawId : '$rawId-$occurrence',
        'type': cells[typeColumn].toUpperCase(),
        'vma': speed,
        'lat': _rounded(latitude),
        'lon': _rounded(longitude),
      });
    }
    return cameras;
  }

  static String _normalize(String name) => name.trim().toLowerCase();

  static double? _coordinate(String raw) => double.tryParse(raw.replaceAll(',', '.').replaceAll(' ', ''));

  static double _rounded(double value) => (value * 1000000).round() / 1000000;
}
