import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'layers/functional/Lesson/data/data_sources/topic_asset_data_source.dart';
import 'layers/functional/Lesson/data/gateways/asset_topic_gateway.dart';
import 'layers/functional/Lesson/data/gateways/shared_preferences_progress_gateway.dart';
import 'layers/functional/Lesson/data/gateways/shared_preferences_settings_gateway.dart';
import 'layers/functional/Lesson/domain/use_cases/build_session_use_case.dart';
import 'layers/functional/Lesson/domain/use_cases/complete_topic_use_case.dart';
import 'layers/functional/Lesson/domain/use_cases/load_topics_use_case.dart';
import 'layers/functional/Lesson/domain/use_cases/pick_bonus_topic_use_case.dart';
import 'layers/functional/Lesson/domain/use_cases/read_completed_topics_use_case.dart';
import 'layers/functional/Lesson/domain/use_cases/read_position_use_case.dart';
import 'layers/functional/Lesson/domain/use_cases/read_settings_use_case.dart';
import 'layers/functional/Lesson/domain/use_cases/resolve_daily_plan_use_case.dart';
import 'layers/functional/Lesson/domain/use_cases/save_position_use_case.dart';
import 'layers/functional/Lesson/domain/use_cases/save_settings_use_case.dart';
import 'layers/functional/Lesson/presentation/cubit/player_cubit.dart';
import 'layers/functional/Lesson/presentation/views/player_view.dart';
import 'layers/technical/ScreenWake/wakelock_screen_wake.dart';
import 'layers/technical/Speech/flutter_tts_speech_engine.dart';
import 'layers/technical/Theme/app_colors.dart';
import 'layers/technical/Theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  final preferences = SharedPreferencesAsync();
  final progressGateway = SharedPreferencesProgressGateway(preferences);
  final settingsGateway = SharedPreferencesSettingsGateway(preferences);
  final topicGateway = AssetTopicGateway(TopicAssetDataSource(rootBundle));

  final playerCubit = PlayerCubit(
    loadTopics: LoadTopicsUseCase(topicGateway),
    resolveDailyPlan: ResolveDailyPlanUseCase(progressGateway),
    buildSession: BuildSessionUseCase(),
    pickBonusTopic: const PickBonusTopicUseCase(),
    completeTopic: CompleteTopicUseCase(progressGateway),
    readCompletedTopics: ReadCompletedTopicsUseCase(progressGateway),
    readPosition: ReadPositionUseCase(progressGateway),
    savePosition: SavePositionUseCase(progressGateway),
    readSettings: ReadSettingsUseCase(settingsGateway),
    saveSettings: SaveSettingsUseCase(settingsGateway),
    speech: FlutterTtsSpeechEngine(FlutterTts()),
    screenWake: const WakelockScreenWake(),
    now: DateTime.now,
  )..load();

  runApp(BlocProvider.value(value: playerCubit, child: const EnRouteApp()));
}

class EnRouteApp extends StatelessWidget {
  const EnRouteApp({super.key});

  @override
  Widget build(BuildContext context) {
    final accentIndex = context.select<PlayerCubit, int>((cubit) => cubit.state.settings.accentIndex);
    return MaterialApp(
      title: 'En route',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(AppColors.accent(accentIndex)),
      home: const PlayerView(),
    );
  }
}
