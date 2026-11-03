import 'package:flutter/material.dart';

import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/widgets/tag_chip.dart';
import '../cubit/player_state.dart';
import 'segment_progress_bar.dart';
import 'step_caption.dart';

class TopicCard extends StatelessWidget {
  const TopicCard({super.key, required this.state, required this.accent});

  final PlayerState state;
  final Color accent;

  String get _badge {
    if (state.isBonus) {
      return 'Sujet bonus';
    }
    return state.session!.topic == state.dailyTopic ? 'Sujet du jour' : 'Sujet choisi';
  }

  @override
  Widget build(BuildContext context) {
    final session = state.session!;
    final caption = StepCaption.of(state);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 14,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [TagChip(label: _badge, accent: accent), TagChip(label: session.topic.category)],
          ),
          Text(session.topic.title, style: const TextStyle(fontSize: 28, height: 1.15, fontWeight: FontWeight.w700)),
          SegmentProgressBar(session: session, stepIndex: state.stepIndex, isFinished: state.isFinished, accent: accent),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(caption.label, style: const TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w600)),
              Text(caption.title, style: const TextStyle(fontSize: 18, height: 1.3, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
