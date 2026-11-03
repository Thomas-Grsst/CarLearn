import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Theme/app_colors.dart';
import '../../../SpeedCamera/presentation/cubit/speed_camera_cubit.dart';
import '../../../SpeedCamera/presentation/views/speed_camera_settings_section.dart';
import '../cubit/player_cubit.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<PlayerCubit>()),
            BlocProvider.value(value: context.read<SpeedCameraCubit>()),
          ],
          child: const SettingsSheet(),
        ),
      );

  static const TextStyle _sectionStyle = TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w600);
  static const TextStyle _noteStyle = TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5);

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<PlayerCubit>();
    final state = cubit.state;
    final selectedVoice = state.voices.where((voice) => voice.name == state.settings.voiceName).firstOrNull;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            const Text('Réglages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const Text('Radars', style: _sectionStyle),
            const SpeedCameraSettingsSection(),
            const Text('Voix', style: _sectionStyle),
            if (state.voices.isEmpty)
              const Text(
                "Aucune voix française trouvée. Installe-la dans les paramètres Android : Synthèse vocale, puis Français.",
                style: _noteStyle,
              )
            else
              DropdownButtonFormField(
                initialValue: selectedVoice,
                isExpanded: true,
                decoration: const InputDecoration(border: OutlineInputBorder(), filled: true, fillColor: AppColors.track),
                items: [
                  for (final voice in state.voices)
                    DropdownMenuItem(
                      value: voice,
                      child: Text(voice.requiresNetwork ? '${voice.name} (en ligne)' : voice.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (voice) {
                  if (voice != null) {
                    cubit.selectVoice(voice);
                  }
                },
              ),
            const Text('Pour écouter hors ligne, choisis une voix qui n’est pas marquée « en ligne ».', style: _noteStyle),
            const Text('Couleur', style: _sectionStyle),
            Row(
              spacing: 12,
              children: [
                for (var i = 0; i < AppColors.accents.length; i++)
                  Semantics(
                    button: true,
                    selected: i == state.settings.accentIndex,
                    label: 'Couleur ${i + 1}',
                    child: InkResponse(
                      onTap: () => cubit.selectAccent(i),
                      radius: 28,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.accents[i],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: i == state.settings.accentIndex ? AppColors.text : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const Text(
              "Prépare la lecture à l'arrêt. En roulant, utilise seulement les trois gros boutons. L'écran reste allumé pendant la lecture.",
              style: _noteStyle,
            ),
          ],
        ),
      ),
    );
  }
}
