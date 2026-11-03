import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/ScreenWake/screen_wake.dart';
import '../../../../technical/Speech/speech_engine.dart';
import '../../../../technical/Speech/speech_voice.dart';
import '../../domain/entities/calendar_day.dart';
import '../../domain/entities/saved_position.dart';
import '../../domain/entities/player_settings.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/session_step.dart';
import '../../domain/entities/step_kind.dart';
import '../../domain/entities/topic.dart';
import '../../domain/use_cases/build_session_use_case.dart';
import '../../domain/use_cases/complete_topic_use_case.dart';
import '../../domain/use_cases/load_topics_use_case.dart';
import '../../domain/use_cases/pick_bonus_topic_use_case.dart';
import '../../domain/use_cases/read_completed_topics_use_case.dart';
import '../../domain/use_cases/read_position_use_case.dart';
import '../../domain/use_cases/read_settings_use_case.dart';
import '../../domain/use_cases/resolve_daily_plan_use_case.dart';
import '../../domain/use_cases/save_position_use_case.dart';
import '../../domain/use_cases/save_settings_use_case.dart';
import 'player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit({
    required this._loadTopics,
    required this._resolveDailyPlan,
    required this._buildSession,
    required this._pickBonusTopic,
    required this._completeTopic,
    required this._readCompletedTopics,
    required this._readPosition,
    required this._savePosition,
    required this._readSettings,
    required this._saveSettings,
    required this._speech,
    required this._screenWake,
    required this._now,
  }) : super(const PlayerState.loading());

  static const Duration _tick = Duration(seconds: 1);

  final LoadTopicsUseCase _loadTopics;
  final ResolveDailyPlanUseCase _resolveDailyPlan;
  final BuildSessionUseCase _buildSession;
  final PickBonusTopicUseCase _pickBonusTopic;
  final CompleteTopicUseCase _completeTopic;
  final ReadCompletedTopicsUseCase _readCompletedTopics;
  final ReadPositionUseCase _readPosition;
  final SavePositionUseCase _savePosition;
  final ReadSettingsUseCase _readSettings;
  final SaveSettingsUseCase _saveSettings;
  final SpeechEngine _speech;
  final ScreenWake _screenWake;
  final DateTime Function() _now;

  int _playbackToken = 0;

  CalendarDay get _today => CalendarDay.from(_now());

  Future<void> load() async {
    try {
      final topics = await _loadTopics();
      if (topics.isEmpty) {
        emit(state.copyWith(status: PlayerStatus.failure));
        return;
      }
      final plan = await _resolveDailyPlan(topics: topics, today: _today);
      final completed = await _readCompletedTopics();
      final settings = await _readSettings();
      final position = await _readPosition();

      var topic = plan.today;
      var stepIndex = 0;
      var isBonus = false;
      if (position != null && position.day == _today) {
        final resumed = topics.where((candidate) => candidate.id == position.topicId);
        if (resumed.isNotEmpty) {
          topic = resumed.first;
          stepIndex = position.stepIndex;
          isBonus = position.isBonus;
        }
      }
      final session = _sessionFor(topic, topics, completed);
      emit(state.copyWith(
        status: PlayerStatus.ready,
        topics: topics,
        dailyTopic: plan.today,
        tomorrowTopic: plan.tomorrow,
        session: session,
        stepIndex: stepIndex.clamp(0, session.lastIndex),
        isBonus: isBonus,
        completedTopicIds: completed,
        settings: settings,
      ));
      await _prepareVoices();
    } on Exception {
      emit(state.copyWith(status: PlayerStatus.failure));
    }
  }

  Future<void> togglePlayback() => state.isPlaying ? pause() : play();

  Future<void> play() async {
    final session = state.session;
    if (session == null) {
      return;
    }
    final startIndex = state.isFinished ? 0 : state.stepIndex;
    emit(state.copyWith(isPlaying: true, stepIndex: startIndex, clearCountdown: true));
    await _screenWake.keepOn();
    _runPlayback(++_playbackToken);
  }

  Future<void> pause() async {
    _playbackToken++;
    await _speech.stop();
    emit(state.copyWith(isPlaying: false, clearCountdown: true));
    await _screenWake.release();
  }

  Future<void> next() async {
    final session = state.session;
    final step = state.currentStep;
    if (session == null || step == null) {
      return;
    }
    if (step.kind == StepKind.end) {
      await _startBonusTopic();
      return;
    }
    if (step.isQuizStep) {
      final nextQuestion = _indexWhereAfter(
        session,
        state.stepIndex,
        (candidate) => candidate.kind == StepKind.question && candidate.segmentIndex == step.segmentIndex,
      );
      if (nextQuestion != null) {
        await _jumpTo(nextQuestion);
        return;
      }
    }
    final nextSegment = session.steps.indexWhere((candidate) => candidate.segmentIndex > step.segmentIndex);
    await _jumpTo(nextSegment < 0 ? session.lastIndex : nextSegment);
  }

  Future<void> previous() async {
    final session = state.session;
    final step = state.currentStep;
    if (session == null || step == null) {
      return;
    }
    if (step.isQuizStep) {
      final current = session.steps.indexWhere((candidate) =>
          candidate.kind == StepKind.question &&
          candidate.segmentIndex == step.segmentIndex &&
          candidate.questionNumber == step.questionNumber);
      if (state.stepIndex > current) {
        await _jumpTo(current);
        return;
      }
      final earlier = session.steps.indexWhere((candidate) =>
          candidate.kind == StepKind.question &&
          candidate.segmentIndex == step.segmentIndex &&
          candidate.questionNumber == step.questionNumber! - 1);
      if (earlier >= 0) {
        await _jumpTo(earlier);
        return;
      }
    }
    final segmentStart = session.firstStepOfSegment(step.segmentIndex);
    final isWellIntoSegment = state.stepIndex - segmentStart > 2;
    final target = (isWellIntoSegment || step.segmentIndex == 0) && step.kind != StepKind.end
        ? step.segmentIndex
        : (step.segmentIndex - 1).clamp(0, session.segments.length - 1);
    await _jumpTo(session.firstStepOfSegment(target));
  }

  Future<void> selectTopic(Topic topic) async {
    await _openTopic(topic, isBonus: false);
  }

  Future<void> cycleSpeed() async {
    await _updateSettings(state.settings.copyWith(speed: state.settings.nextSpeed));
    if (state.isPlaying) {
      await _jumpTo(state.stepIndex);
    }
  }

  Future<void> selectAccent(int accentIndex) => _updateSettings(state.settings.copyWith(accentIndex: accentIndex));

  Future<void> selectVoice(SpeechVoice voice) async {
    await _speech.useVoice(voice);
    await _updateSettings(state.settings.copyWith(voiceName: voice.name));
  }

  @override
  Future<void> close() async {
    _playbackToken++;
    await _speech.stop();
    await _screenWake.release();
    return super.close();
  }

  Future<void> _runPlayback(int token) async {
    bool isCurrent() => token == _playbackToken && !isClosed;

    while (isCurrent()) {
      final step = state.currentStep!;
      await _speech.speak(step.text, speed: state.settings.speed);
      if (!isCurrent()) {
        return;
      }
      if (step.kind == StepKind.end) {
        final completed = await _completeTopic(state.session!.topic.id);
        if (!isCurrent()) {
          return;
        }
        emit(state.copyWith(isPlaying: false, completedTopicIds: completed));
        await _screenWake.release();
        return;
      }
      if (step.kind == StepKind.question) {
        for (var remaining = step.pauseAfter.inSeconds; remaining > 0; remaining--) {
          emit(state.copyWith(countdown: remaining));
          await Future<void>.delayed(_tick);
          if (!isCurrent()) {
            return;
          }
        }
      } else {
        await Future<void>.delayed(step.pauseAfter);
        if (!isCurrent()) {
          return;
        }
      }
      emit(state.copyWith(stepIndex: state.stepIndex + 1, clearCountdown: true));
      await _persistPosition();
    }
  }

  Future<void> _jumpTo(int index) async {
    final session = state.session;
    if (session == null) {
      return;
    }
    final wasPlaying = state.isPlaying;
    _playbackToken++;
    await _speech.stop();
    emit(state.copyWith(stepIndex: index.clamp(0, session.lastIndex), clearCountdown: true));
    await _persistPosition();
    if (wasPlaying) {
      _runPlayback(++_playbackToken);
    }
  }

  Future<void> _startBonusTopic() async {
    final session = state.session;
    final tomorrow = state.tomorrowTopic;
    if (session == null || tomorrow == null) {
      return;
    }
    final bonus = _pickBonusTopic(
      topics: state.topics,
      current: session.topic,
      tomorrow: tomorrow,
      completedTopicIds: state.completedTopicIds,
    );
    await _openTopic(bonus, isBonus: true);
    await play();
  }

  Future<void> _openTopic(Topic topic, {required bool isBonus}) async {
    _playbackToken++;
    await _speech.stop();
    final completed = await _readCompletedTopics();
    emit(state.copyWith(
      session: _sessionFor(topic, state.topics, completed),
      stepIndex: 0,
      isPlaying: false,
      clearCountdown: true,
      isBonus: isBonus,
      completedTopicIds: completed,
    ));
    await _persistPosition();
  }

  Session _sessionFor(Topic topic, List<Topic> topics, Set<String> completed) => _buildSession(
        topic: topic,
        revisionPool: topics.where((candidate) => completed.contains(candidate.id)).toList(),
      );

  Future<void> _prepareVoices() async {
    await _speech.initialize();
    final voices = await _speech.frenchVoices();
    if (isClosed || voices.isEmpty) {
      return;
    }
    final preferred = voices.where((voice) => voice.name == state.settings.voiceName);
    final chosen = preferred.isNotEmpty ? preferred.first : voices.first;
    await _speech.useVoice(chosen);
    emit(state.copyWith(voices: voices, settings: state.settings.copyWith(voiceName: chosen.name)));
  }

  Future<void> _updateSettings(PlayerSettings settings) async {
    emit(state.copyWith(settings: settings));
    await _saveSettings(state.settings);
  }

  Future<void> _persistPosition() async {
    final session = state.session;
    if (session == null) {
      return;
    }
    await _savePosition(SavedPosition(
      topicId: session.topic.id,
      day: _today,
      stepIndex: state.stepIndex,
      isBonus: state.isBonus,
    ));
  }

  int? _indexWhereAfter(Session session, int start, bool Function(SessionStep step) test) {
    for (var i = start + 1; i < session.steps.length; i++) {
      if (test(session.steps[i])) {
        return i;
      }
    }
    return null;
  }
}
