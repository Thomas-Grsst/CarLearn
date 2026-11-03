import 'package:flutter/material.dart';

import '../../../../technical/Theme/app_colors.dart';
import '../../domain/entities/session.dart';

class SegmentProgressBar extends StatelessWidget {
  const SegmentProgressBar({
    super.key,
    required this.session,
    required this.stepIndex,
    required this.isFinished,
    required this.accent,
  });

  static const double _minimumVisibleFill = 0.04;

  final Session session;
  final int stepIndex;
  final bool isFinished;
  final Color accent;

  double _fillOf(int segmentIndex) {
    final currentSegment = session.steps[stepIndex].segmentIndex;
    if (isFinished || segmentIndex < currentSegment) {
      return 1;
    }
    if (segmentIndex > currentSegment) {
      return 0;
    }
    final start = session.firstStepOfSegment(segmentIndex);
    final count = session.stepCountInSegment(segmentIndex);
    return ((stepIndex - start) / count).clamp(_minimumVisibleFill, 1).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        spacing: 4,
        children: [
          for (var i = 0; i < session.segments.length; i++)
            Expanded(
              flex: session.segments[i].weight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: Container(
                  height: 6,
                  color: AppColors.track,
                  alignment: Alignment.centerLeft,
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 300),
                    widthFactor: _fillOf(i),
                    heightFactor: 1,
                    child: ColoredBox(color: accent),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
