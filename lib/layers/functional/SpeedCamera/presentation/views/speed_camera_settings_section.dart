import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../technical/Theme/app_colors.dart';
import '../cubit/speed_camera_cubit.dart';
import '../cubit/speed_camera_state.dart';

class SpeedCameraSettingsSection extends StatelessWidget {
  const SpeedCameraSettingsSection({super.key});

  static const TextStyle _noteStyle = TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5);

  String _statusLabel(SpeedCameraState state) {
    final count = NumberFormat.decimalPattern('fr_FR').format(state.cameraCount);
    return switch (state.status) {
      SpeedCameraStatus.loading => 'Chargement des radars…',
      SpeedCameraStatus.disabled => 'Désactivées.',
      SpeedCameraStatus.unavailable => 'Liste des radars absente de cette version de l’application.',
      SpeedCameraStatus.needsPermission => 'En attente de l’autorisation de localisation.',
      SpeedCameraStatus.blocked => 'Localisation refusée : autorise-la dans les paramètres Android.',
      SpeedCameraStatus.serviceDisabled => 'La localisation du téléphone est coupée.',
      SpeedCameraStatus.active => 'Actives : $count radars fixes surveillés.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<SpeedCameraCubit>();
    final state = cubit.state;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Alertes radars', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          subtitle: Text(_statusLabel(state), style: _noteStyle),
          value: state.alertsEnabled,
          onChanged: state.status == SpeedCameraStatus.loading ? null : cubit.setAlertsEnabled,
        ),
        const Text(
          'La voix t’annonce chaque radar fixe 1 km avant, avec la vitesse à respecter, même pendant une leçon. '
          'Les radars viennent de la liste officielle du ministère de l’Intérieur.',
          style: _noteStyle,
        ),
      ],
    );
  }
}
