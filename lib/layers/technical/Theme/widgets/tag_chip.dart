import 'package:flutter/material.dart';

import '../app_colors.dart';

class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.accent});

  final String label;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final highlighted = accent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: highlighted?.withValues(alpha: 0.14),
        border: highlighted == null ? Border.all(color: AppColors.border) : null,
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: highlighted ?? AppColors.muted,
        ),
      ),
    );
  }
}
