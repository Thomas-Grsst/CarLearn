import 'dart:math';
import 'package:carlearn/layers/functional/Lesson/domain/entities/calendar_day.dart';
import 'package:carlearn/layers/functional/Lesson/domain/entities/saved_position.dart';
import 'package:carlearn/layers/functional/Lesson/domain/entities/step_kind.dart';
import 'package:carlearn/layers/functional/Lesson/domain/use_cases/build_session_use_case.dart';
import 'package:carlearn/layers/functional/Lesson/domain/use_cases/complete_topic_use_case.dart';
import 'package:carlearn/layers/functional/Lesson/domain/use_cases/load_topics_use_case.dart';
import 'package:carlearn/layers/functional/Lesson/domain/use_cases/pick_bonus_topic_use_case.dart';
import 'package:carlearn/layers/functional/Lesson/domain/use_cases/read_completed_topics_use_case.dart';
import 'package:carlearn/layers/functional/Lesson/domain/use_cases/read_position_use_case.dart';
import 'package:carlearn/layers/functional/Lesson/domain/use_cases/read_settings_use_case.dart';
import 'package:carlearn/layers/functional/Lesson/domain/use_cases/resolve_daily_plan_use_case.dart';
import 'package:carlearn/layers/functional/Lesson/domain/use_cases/save_position_use_case.dart';
import 'package:carlearn/layers/functional/Lesson/domain/use_cases/save_settings_use_case.dart';
import 'package:carlearn/layers/functional/Lesson/presentation/cubit/player_cubit.dart';
import 'package:carlearn/layers/functional/Lesson/presentation/cubit/player_state.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import '../domain/fake_progress_gateway.dart';
import '../topic_fixtures.dart';
import 'player_fakes.dart';

void main() {
  final topics = [for (final id in ['a', 'b', 'c', 'd']) buildTopic(id)];
  final today = DateTime(2026, 11, 3, 8);
  late FakeProgressGateway progress;
  late FakeSettingsGateway settings;
  late FakeSpeechEngine speech;
  late FakeScreenWake screenWake;

  PlayerCubit buildCubit() => PlayerCubit(
        loadTopics: LoadTopicsUseCase(FakeTopicGateway(topics)),
        resolveDailyPlan: ResolveDailyPlanUseCase(progress),
        buildSession: BuildSessionUseCase(random: Random(1)),
        pickBonusTopic: const PickBonusTopicUseCase(),
        completeTopic: CompleteTopicUseCase(progress),
        readCompletedTopics: ReadCompletedTopicsUseCase(progress),
        readPosition: ReadPositionUseCase(progress),
        savePosition: SavePositionUseCase(progress),
        readSettings: ReadSettingsUseCase(settings),
        saveSettings: SaveSettingsUseCase(settings),
        speech: speech,
        screenWake: screenWake,
        now: () => today,
      );

  setUp(() {
    progress = FakeProgressGateway();
    settings = FakeSettingsGateway();
    speech = FakeSpeechEngine();
    screenWake = FakeScreenWake();
  });

  test('loads the daily topic and picks an offline voice', () async {
    final cubit = buildCubit();
    await cubit.load();

    expect(cubit.state.status, PlayerStatus.ready);
    expect(cubit.state.session!.topic.id, 'a');
    expect(cubit.state.tomorrowTopic!.id, 'b');
    expect(speech.voice!.name, 'fr-fr-x-local');
    await cubit.close();
  });

  test('resumes the position saved earlier the same day', () async {
    progress
      ..startDay = CalendarDay.from(today)
      ..position = SavedPosition(topicId: 'c', day: CalendarDay.from(today), stepIndex: 4, isBonus: true);
    final cubit = buildCubit();
    await cubit.load();

    expect(cubit.state.session!.topic.id, 'c');
    expect(cubit.state.stepIndex, 4);
    expect(cubit.state.isBonus, isTrue);
    await cubit.close();
  });

  test('next jumps to the following part, previous goes back to its start', () async {
    final cubit = buildCubit();
    await cubit.load();
    final session = cubit.state.session!;

    await cubit.next();
    expect(cubit.state.stepIndex, session.firstStepOfSegment(1));
    await cubit.next();
    expect(cubit.state.stepIndex, session.firstStepOfSegment(2));
    await cubit.previous();
    expect(cubit.state.stepIndex, session.firstStepOfSegment(1));
    await cubit.close();
  });

  test('plays the whole session, counts down on questions and marks the topic done', () {
    fakeAsync((async) {
      final cubit = buildCubit();
      cubit.load();
      async.flushMicrotasks();
      final session = cubit.state.session!;
      final countdowns = <int>[];
      final subscription = cubit.stream.listen((state) {
        final countdown = state.countdown;
        if (countdown != null && (countdowns.isEmpty || countdowns.last != countdown)) {
          countdowns.add(countdown);
        }
      });

      cubit.play();
      async.elapse(const Duration(minutes: 5));

      expect(speech.spoken, session.steps.map((step) => step.text).toList());
      expect(countdowns.take(7), [7, 6, 5, 4, 3, 2, 1]);
      expect(cubit.state.isFinished, isTrue);
      expect(cubit.state.isPlaying, isFalse);
      expect(progress.completed, {'a'});
      expect(screenWake.isOn, isFalse);
      subscription.cancel();
      cubit.close();
      async.flushMicrotasks();
    });
  });

  test('next on the end screen starts a bonus topic that is neither today nor tomorrow', () async {
    final cubit = buildCubit();
    await cubit.load();
    final session = cubit.state.session!;
    progress.completed.add('a');
    await cubit.selectTopic(session.topic);
    while (cubit.state.currentStep!.kind != StepKind.end) {
      await cubit.next();
    }

    await cubit.next();

    expect(cubit.state.isBonus, isTrue);
    expect(cubit.state.session!.topic.id, 'c');
    expect(cubit.state.isPlaying, isTrue);
    await cubit.pause();
    await cubit.close();
  });

  test('cycles speed and persists it', () async {
    final cubit = buildCubit();
    await cubit.load();

    await cubit.cycleSpeed();

    expect(cubit.state.settings.speed, 1.15);
    expect(settings.stored.speed, 1.15);
    await cubit.close();
  });

  test('a radar announcement interrupts the lesson, then the current step starts again', () {
    fakeAsync((async) {
      final cubit = buildCubit();
      cubit.load();
      async.flushMicrotasks();
      final firstStep = cubit.state.currentStep!.text;

      cubit.play();
      async.flushMicrotasks();
      cubit.announce('Attention, radar fixe dans 1 kilomètre. Vitesse limitée à 80.');
      async.flushMicrotasks();

      expect(speech.spoken, [firstStep, 'Attention, radar fixe dans 1 kilomètre. Vitesse limitée à 80.', firstStep]);
      expect(cubit.state.isPlaying, isTrue);
      cubit.pause();
      cubit.close();
      async.flushMicrotasks();
    });
  });

  test('a radar announcement while paused does not start the lesson', () async {
    final cubit = buildCubit();
    await cubit.load();

    await cubit.announce('Attention, radar fixe tout proche. Vitesse limitée à 50.');

    expect(speech.spoken, ['Attention, radar fixe tout proche. Vitesse limitée à 50.']);
    expect(cubit.state.isPlaying, isFalse);
    await cubit.close();
  });
}
