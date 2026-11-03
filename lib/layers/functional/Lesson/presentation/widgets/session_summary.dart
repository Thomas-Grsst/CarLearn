import 'package:flutter/material.dart';

import '../../../../technical/Theme/app_colors.dart';

class SessionSummary extends StatelessWidget {
  const SessionSummary({
    super.key,
    required this.todayLabel,
    required this.todayTitle,
    required this.todayBadge,
    required this.tomorrowTitle,
  });

  final String todayLabel;
  final String todayTitle;
  final String todayBadge;
  final String tomorrowTitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        _SummaryRow(label: todayLabel, title: todayTitle, badge: todayBadge, isDone: true),
        _SummaryRow(label: 'Demain', title: tomorrowTitle, badge: 'À venir', isDone: false),
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Séance terminée. Il te reste de la route ? Appuie sur suivant.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, height: 1.45, color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.title, required this.badge, required this.isDone});

  final String label;
  final String title;
  final String badge;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.track, borderRadius: BorderRadius.circular(16)),
      child: Row(
        spacing: 12,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 3,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isDone ? AppColors.success.withValues(alpha: 0.12) : null,
              border: isDone ? null : Border.all(color: AppColors.border),
            ),
            child: Text(
              badge,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDone ? AppColors.success : AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
