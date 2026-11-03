import 'package:equatable/equatable.dart';

import '../../../../technical/Speech/speech_voice.dart';
import '../../domain/entities/player_settings.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/session_step.dart';
import '../../domain/entities/step_kind.dart';
import '../../domain/entities/topic.dart';

enum PlayerStatus { loading, ready, failure }

class PlayerState extends Equatable {
  const PlayerState({
    required this.status,
    required this.topics,
    required this.dailyTopic,
    required this.tomorrowTopic,
    required this.session,
    required this.stepIndex,
    required this.isPlaying,
    required this.countdown,
    required this.isBonus,
    required this.completedTopicIds,
    required this.settings,
    required this.voices,
  });

  const PlayerState.loading()
      : status = PlayerStatus.loading,
        topics = const [],
        dailyTopic = null,
        tomorrowTopic = null,
        session = null,
        stepIndex = 0,
        isPlaying = false,
        countdown = null,
        isBonus = false,
        completedTopicIds = const {},
        settings = PlayerSettings.defaults,
        voices = const [];

  final PlayerStatus status;
  final List<Topic> topics;
  final Topic? dailyTopic;
  final Topic? tomorrowTopic;
  final Session? session;
  final int stepIndex;
  final bool isPlaying;
  final int? countdown;
  final bool isBonus;
  final Set<String> completedTopicIds;
  final PlayerSettings settings;
  final List<SpeechVoice> voices;

  SessionStep? get currentStep => session?.steps[stepIndex];

  bool get isFinished => currentStep?.kind == StepKind.end;

  bool get hasStarted => isPlaying || stepIndex > 0;

  int get topicNumber => session == null ? 0 : topics.indexOf(session!.topic) + 1;

  PlayerState copyWith({
    PlayerStatus? status,
    List<Topic>? topics,
    Topic? dailyTopic,
    Topic? tomorrowTopic,
    Session? session,
    int? stepIndex,
    bool? isPlaying,
    int? countdown,
    bool clearCountdown = false,
    bool? isBonus,
    Set<String>? completedTopicIds,
    PlayerSettings? settings,
    List<SpeechVoice>? voices,
  }) =>
      PlayerState(
        status: status ?? this.status,
        topics: topics ?? this.topics,
        dailyTopic: dailyTopic ?? this.dailyTopic,
        tomorrowTopic: tomorrowTopic ?? this.tomorrowTopic,
        session: session ?? this.session,
        stepIndex: stepIndex ?? this.stepIndex,
        isPlaying: isPlaying ?? this.isPlaying,
        countdown: clearCountdown ? null : (countdown ?? this.countdown),
        isBonus: isBonus ?? this.isBonus,
        completedTopicIds: completedTopicIds ?? this.completedTopicIds,
        settings: settings ?? this.settings,
        voices: voices ?? this.voices,
      );

  @override
  List<Object?> get props => [
        status,
        topics,
        dailyTopic,
        tomorrowTopic,
        session,
        stepIndex,
        isPlaying,
        countdown,
        isBonus,
        completedTopicIds,
        settings,
        voices,
      ];
}
