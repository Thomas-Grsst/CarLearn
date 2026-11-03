import 'package:flutter/material.dart';

abstract final class AppColors {
  static const Color background = Color(0xFF0C0F14);
  static const Color surface = Color(0xFF151A22);
  static const Color border = Color(0xFF2A3342);
  static const Color track = Color(0xFF1D2430);
  static const Color text = Color(0xFFF3F5F8);
  static const Color muted = Color(0xFFA1ABBA);
  static const Color success = Color(0xFF5FD4A0);

  static const List<Color> accents = [
    Color(0xFF8FA6FF),
    Color(0xFF5FD4A0),
    Color(0xFFFFB86B),
    Color(0xFFF38BA8),
  ];

  static Color accent(int index) => accents[index.clamp(0, accents.length - 1)];
}
