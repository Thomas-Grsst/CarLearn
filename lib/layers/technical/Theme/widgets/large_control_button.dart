import 'package:flutter/material.dart';

import '../app_colors.dart';

class LargeControlButton extends StatelessWidget {
  const LargeControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isEmphasized,
    required this.accent,
    this.iconSize = 40,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isEmphasized;
  final Color accent;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final background = isEmphasized ? accent : AppColors.surface;
    final foreground = isEmphasized ? AppColors.background : AppColors.text;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
          side: BorderSide(color: isEmphasized ? accent : AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onPressed,
          child: SizedBox(height: 96, child: Center(child: Icon(icon, size: iconSize, color: foreground))),
        ),
      ),
    );
  }
}
