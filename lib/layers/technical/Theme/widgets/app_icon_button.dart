import 'package:flutter/material.dart';

import '../app_colors.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({super.key, required this.icon, required this.label, required this.onPressed});

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: SizedBox(width: 48, height: 48, child: Icon(icon, size: 22, semanticLabel: label)),
        ),
      ),
    );
  }
}
