import 'package:flutter_test/flutter_test.dart';

import '../../tool/speed_camera_csv.dart';

void main() {
  test('parses the official fixed camera list', () {
    const csv = 'Numéro de radar;Type de radar;Date de mise en service;VMA ;Latitude; Longitude\r\n'
        '12001;ETD;31/10/2011 00:00;70;+45.361;+4.2526\r\n'
        '12008;etf;31/10/2011 00:00;80;+46.413340;-0,436502\r\n'
        '12009;ETF;31/10/2011 00:00;;+46.4;+0.4\r\n'
        '12001;ETT;31/10/2011 00:00;50;+43.1;+5.9\r\n';

    expect(SpeedCameraCsv.parse(csv), [
      {'id': '12001', 'type': 'ETD', 'vma': 70, 'lat': 45.361, 'lon': 4.2526},
      {'id': '12008', 'type': 'ETF', 'vma': 80, 'lat': 46.41334, 'lon': -0.436502},
      {'id': '12001-2', 'type': 'ETT', 'vma': 50, 'lat': 43.1, 'lon': 5.9},
    ]);
  });

  test('rejects a file whose columns changed', () {
    expect(() => SpeedCameraCsv.parse('a;b;c\n1;2;3'), throwsFormatException);
  });
}
