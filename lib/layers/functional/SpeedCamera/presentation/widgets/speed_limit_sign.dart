import 'package:flutter/material.dart';

class SpeedLimitSign extends StatelessWidget {
  const SpeedLimitSign({super.key, required this.speedLimitKmh, this.size = 72});

  static const Color _red = Color(0xFFE0262B);

  final int speedLimitKmh;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Vitesse limitée à $speedLimitKmh',
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: _red, width: size * 0.11),
        ),
        child: FittedBox(
          child: Padding(
            padding: EdgeInsets.all(size * 0.08),
            child: Text(
              '$speedLimitKmh',
              style: TextStyle(fontSize: size * 0.38, fontWeight: FontWeight.w800, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
