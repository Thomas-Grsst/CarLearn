import 'dart:math';

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
import 'package:carlearn/layers/functional/Lesson/presentation/views/player_view.dart';
import 'package:carlearn/layers/technical/Theme/app_colors.dart';
import 'package:carlearn/layers/technical/Theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../domain/fake_progress_gateway.dart';
import '../topic_fixtures.dart';
import 'player_fakes.dart';

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  Future<PlayerCubit> pumpPlayer(WidgetTester tester) async {
    final progress = FakeProgressGateway();
    final settings = FakeSettingsGateway();
    final cubit = PlayerCubit(
      loadTopics: LoadTopicsUseCase(FakeTopicGateway([buildTopic('a'), buildTopic('b'), buildTopic('c')])),
      resolveDailyPlan: ResolveDailyPlanUseCase(progress),
      buildSession: BuildSessionUseCase(random: Random(1)),
      pickBonusTopic: const PickBonusTopicUseCase(),
      completeTopic: CompleteTopicUseCase(progress),
      readCompletedTopics: ReadCompletedTopicsUseCase(progress),
      readPosition: ReadPositionUseCase(progress),
      savePosition: SavePositionUseCase(progress),
      readSettings: ReadSettingsUseCase(settings),
      saveSettings: SaveSettingsUseCase(settings),
      speech: FakeSpeechEngine(),
      screenWake: FakeScreenWake(),
      now: () => DateTime(2026, 11, 3),
    );
    await tester.runAsync(cubit.load);
    tester.view.physicalSize = const Size(390, 844) * tester.view.devicePixelRatio;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(BlocProvider.value(
      value: cubit,
      child: MaterialApp(theme: AppTheme.dark(AppColors.accent(0)), home: const PlayerView()),
    ));
    return cubit;
  }

  testWidgets('shows the daily topic card and the three large controls', (tester) async {
    await pumpPlayer(tester);

    expect(find.text('Titre a'), findsOneWidget);
    expect(find.text('SUJET DU JOUR'), findsOneWidget);
    expect(find.text('Introduction'), findsOneWidget);
    expect(find.text('Vitesse 1×'), findsOneWidget);
    expect(find.bySemanticsLabel('Lecture'), findsOneWidget);
    expect(find.bySemanticsLabel('Partie suivante'), findsOneWidget);
  });

  testWidgets('next moves the card to the first part', (tester) async {
    await pumpPlayer(tester);

    await tester.tap(find.bySemanticsLabel('Partie suivante'));
    await tester.pumpAndSettle();

    expect(find.text('Partie 1 sur 2'), findsOneWidget);
    expect(find.text('Partie 1 de a'), findsOneWidget);
  });
}
