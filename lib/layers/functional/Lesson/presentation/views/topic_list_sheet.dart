import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Theme/app_colors.dart';
import '../cubit/player_cubit.dart';

class TopicListSheet extends StatelessWidget {
  const TopicListSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => BlocProvider.value(value: context.read<PlayerCubit>(), child: const TopicListSheet()),
      );

  @override
  Widget build(BuildContext context) {
    final state = context.watch<PlayerCubit>().state;
    final accent = AppColors.accent(state.settings.accentIndex);
    final currentIndex = state.topics.indexOf(state.session!.topic);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('Tous les sujets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              itemCount: state.topics.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final topic = state.topics[index];
                final isCurrent = index == currentIndex;
                final isDone = state.completedTopicIds.contains(topic.id);
                return ListTile(
                  minTileHeight: 56,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: Text(
                    topic.title,
                    style: TextStyle(fontWeight: FontWeight.w600, color: isCurrent ? accent : AppColors.text),
                  ),
                  subtitle: Text(
                    '${index + 1} · ${topic.category}'.toUpperCase(),
                    style: const TextStyle(fontSize: 12, color: AppColors.muted, letterSpacing: 0.5),
                  ),
                  trailing: isDone ? const Icon(Icons.check_rounded, color: AppColors.success, semanticLabel: 'Terminé') : null,
                  onTap: () {
                    Navigator.of(context).pop();
                    context.read<PlayerCubit>().selectTopic(topic);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
