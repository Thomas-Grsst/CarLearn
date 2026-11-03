import 'package:flutter/material.dart';

import '../../../../technical/Theme/app_colors.dart';

class CountdownRing extends StatelessWidget {
  const CountdownRing({
    super.key,
    required this.remaining,
    required this.total,
    required this.caption,
    required this.accent,
  });

  final int remaining;
  final int total;
  final String caption;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 14,
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            fit: StackFit.expand,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(end: remaining / total),
                duration: const Duration(seconds: 1),
                builder: (context, value, _) => CircularProgressIndicator(
                  value: value,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  color: accent,
                  backgroundColor: AppColors.track,
                ),
              ),
              Center(
                child: Text(
                  '$remaining',
                  style: const TextStyle(fontSize: 52, fontWeight: FontWeight.w700),
                  semanticsLabel: '$remaining secondes',
                ),
              ),
            ],
          ),
        ),
        Text(caption, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, color: AppColors.muted)),
      ],
    );
  }
}
