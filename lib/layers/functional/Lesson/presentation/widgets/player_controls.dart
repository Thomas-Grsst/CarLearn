import 'package:flutter/material.dart';

import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/widgets/large_control_button.dart';
import '../../../../technical/Theme/widgets/pill_button.dart';

class PlayerControls extends StatelessWidget {
  const PlayerControls({
    super.key,
    required this.isPlaying,
    required this.isFinished,
    required this.nextLabel,
    required this.speedLabel,
    required this.infoLabel,
    required this.accent,
    required this.onPrevious,
    required this.onTogglePlayback,
    required this.onNext,
    required this.onCycleSpeed,
  });

  final bool isPlaying;
  final bool isFinished;
  final String nextLabel;
  final String speedLabel;
  final String infoLabel;
  final Color accent;
  final VoidCallback onPrevious;
  final VoidCallback onTogglePlayback;
  final VoidCallback onNext;
  final VoidCallback onCycleSpeed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      child: Column(
        spacing: 12,
        children: [
          Row(
            spacing: 12,
            children: [
              Expanded(
                flex: 4,
                child: LargeControlButton(
                  icon: Icons.skip_previous_rounded,
                  label: 'Partie précédente',
                  onPressed: onPrevious,
                  isEmphasized: false,
                  accent: accent,
                ),
              ),
              Expanded(
                flex: 5,
                child: LargeControlButton(
                  icon: isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  label: isPlaying ? 'Pause' : 'Lecture',
                  onPressed: onTogglePlayback,
                  isEmphasized: !isFinished,
                  accent: accent,
                  iconSize: 52,
                ),
              ),
              Expanded(
                flex: 4,
                child: LargeControlButton(
                  icon: Icons.skip_next_rounded,
                  label: nextLabel,
                  onPressed: onNext,
                  isEmphasized: isFinished,
                  accent: accent,
                ),
              ),
            ],
          ),
          Row(
            spacing: 12,
            children: [
              PillButton(label: speedLabel, onPressed: onCycleSpeed),
              Expanded(
                child: Text(
                  infoLabel,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
