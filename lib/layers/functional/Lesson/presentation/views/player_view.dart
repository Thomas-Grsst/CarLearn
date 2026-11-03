import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/widgets/app_icon_button.dart';
import '../../domain/entities/step_kind.dart';
import '../../domain/use_cases/build_session_use_case.dart';
import '../cubit/player_cubit.dart';
import '../cubit/player_state.dart';
import '../widgets/countdown_ring.dart';
import '../widgets/player_controls.dart';
import '../widgets/session_summary.dart';
import '../widgets/topic_card.dart';
import 'settings_sheet.dart';
import 'topic_list_sheet.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, state) => switch (state.status) {
            PlayerStatus.loading => const Center(child: CircularProgressIndicator()),
            PlayerStatus.failure => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Impossible de charger les sujets.', textAlign: TextAlign.center),
                ),
              ),
            PlayerStatus.ready => _PlayerLayout(state: state),
          },
        ),
      ),
    );
  }
}

class _PlayerLayout extends StatelessWidget {
  const _PlayerLayout({required this.state});

  final PlayerState state;

  static String _speedLabel(double speed) {
    final formatted = speed == speed.roundToDouble() ? speed.toStringAsFixed(0) : '$speed'.replaceAll('.', ',');
    return 'Vitesse $formatted×';
  }

  String get _infoLabel {
    if (state.isFinished) {
      return 'Sujet ${state.topicNumber} sur ${state.topics.length}';
    }
    final remaining = state.session!.estimatedRemaining(fromIndex: state.stepIndex, speed: state.settings.speed);
    final minutes = remaining.inMinutes < 1 ? 1 : (remaining.inSeconds / 60).round();
    return '≈ $minutes min restantes';
  }

  String get _nextLabel {
    if (state.isFinished) {
      return 'Sujet bonus';
    }
    return state.currentStep!.isQuizStep ? 'Question suivante' : 'Partie suivante';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerCubit>();
    final accent = AppColors.accent(state.settings.accentIndex);
    return Column(
      children: [
        _Header(
          onOpenTopics: () => TopicListSheet.show(context),
          onOpenSettings: () => SettingsSheet.show(context),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              spacing: 16,
              children: [
                TopicCard(state: state, accent: accent),
                Expanded(child: _Scene(state: state, accent: accent)),
              ],
            ),
          ),
        ),
        PlayerControls(
          isPlaying: state.isPlaying,
          isFinished: state.isFinished,
          nextLabel: _nextLabel,
          speedLabel: _speedLabel(state.settings.speed),
          infoLabel: _infoLabel,
          accent: accent,
          onPrevious: cubit.previous,
          onTogglePlayback: cubit.togglePlayback,
          onNext: cubit.next,
          onCycleSpeed: cubit.cycleSpeed,
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onOpenTopics, required this.onOpenSettings});

  final VoidCallback onOpenTopics;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now());
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                const Text('En route', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Text(
                  '${date[0].toUpperCase()}${date.substring(1)}',
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
          AppIconButton(icon: Icons.format_list_bulleted_rounded, label: 'Liste des sujets', onPressed: onOpenTopics),
          const SizedBox(width: 8),
          AppIconButton(icon: Icons.tune_rounded, label: 'Réglages', onPressed: onOpenSettings),
        ],
      ),
    );
  }
}

class _Scene extends StatelessWidget {
  const _Scene({required this.state, required this.accent});

  final PlayerState state;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final step = state.currentStep!;
    if (state.isFinished) {
      final revised = state.session!.revisedTopicTitles;
      return SessionSummary(
        todayLabel: revised.isEmpty ? "Écouté aujourd'hui" : "Révisé aujourd'hui",
        todayTitle: revised.isEmpty ? state.session!.topic.title : revised.join(', '),
        todayBadge: revised.isEmpty ? 'Terminé' : 'Révision',
        tomorrowTitle: state.tomorrowTopic?.title ?? '',
      );
    }
    if (step.kind == StepKind.question) {
      final total = BuildSessionUseCase.thinkingTime.inSeconds;
      final countdown = state.countdown;
      final revisionTopic = step.revisionTopicTitle;
      return CountdownRing(
        remaining: countdown ?? total,
        total: total,
        caption: countdown != null
            ? 'À toi : réponds à voix haute'
            : (revisionTopic != null ? 'Révision : $revisionTopic' : 'Écoute bien la question'),
        accent: accent,
      );
    }
    final text = state.hasStarted ? step.text : 'Appuie sur lecture avant de démarrer, puis laisse-toi guider.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 21, height: 1.45)),
      ),
    );
  }
}
