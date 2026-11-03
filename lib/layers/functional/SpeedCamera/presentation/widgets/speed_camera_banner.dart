import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Theme/app_colors.dart';
import '../../../../technical/Theme/widgets/pill_button.dart';
import '../cubit/speed_camera_announcement.dart';
import '../cubit/speed_camera_cubit.dart';
import '../cubit/speed_camera_state.dart';
import 'speed_limit_sign.dart';

class SpeedCameraBanner extends StatefulWidget {
  const SpeedCameraBanner({super.key});

  @override
  State<SpeedCameraBanner> createState() => _SpeedCameraBannerState();
}

class _SpeedCameraBannerState extends State<SpeedCameraBanner> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: () => context.read<SpeedCameraCubit>().refreshAccess());
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SpeedCameraCubit, SpeedCameraState>(
      builder: (context, state) {
        final approach = state.approach;
        if (approach != null) {
          return _ApproachCard(state: state);
        }
        if (state.needsAttention) {
          return _AccessCard(status: state.status, onPressed: context.read<SpeedCameraCubit>().grantAccess);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _ApproachCard extends StatelessWidget {
  const _ApproachCard({required this.state});

  static const Color _warning = Color(0xFFFF6B6B);

  final SpeedCameraState state;

  @override
  Widget build(BuildContext context) {
    final approach = state.approach!;
    final speed = state.speedKmh;
    final kind = approach.camera.kind.label;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: state.isOverSpeedLimit ? _warning : AppColors.border, width: 2),
        ),
        child: Row(
          spacing: 14,
          children: [
            SpeedLimitSign(speedLimitKmh: approach.camera.speedLimitKmh),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    '${kind[0].toUpperCase()}${kind.substring(1)}',
                    style: const TextStyle(fontSize: 13, color: AppColors.muted, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'dans ${SpeedCameraAnnouncement.distanceLabel(approach.distanceMeters)}',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                  if (speed != null)
                    Text(
                      state.isOverSpeedLimit ? 'Tu roules à ${speed.round()} km/h : ralentis' : 'Tu roules à ${speed.round()} km/h',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: state.isOverSpeedLimit ? _warning : AppColors.success,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({required this.status, required this.onPressed});

  final SpeedCameraStatus status;
  final VoidCallback onPressed;

  String get _message => switch (status) {
        SpeedCameraStatus.serviceDisabled => 'Active la localisation du téléphone pour être prévenu des radars.',
        SpeedCameraStatus.blocked => 'La localisation est refusée. Autorise-la dans les paramètres pour les alertes radars.',
        _ => 'Autorise la localisation pour être prévenu 1 km avant chaque radar.',
      };

  String get _action => status == SpeedCameraStatus.needsPermission ? 'Autoriser' : 'Paramètres';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        spacing: 12,
        children: [
          const Icon(Icons.speed_rounded, color: AppColors.muted),
          Expanded(child: Text(_message, style: const TextStyle(fontSize: 14, height: 1.35))),
          PillButton(label: _action, onPressed: onPressed),
        ],
      ),
    );
  }
}
