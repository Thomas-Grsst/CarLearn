import 'package:equatable/equatable.dart';

class PlayerSettings extends Equatable {
  const PlayerSettings({required this.speed, required this.voiceName, required this.accentIndex});

  static const List<double> availableSpeeds = [0.85, 1.0, 1.15, 1.3];
  static const PlayerSettings defaults = PlayerSettings(speed: 1.0, voiceName: null, accentIndex: 0);

  final double speed;
  final String? voiceName;
  final int accentIndex;

  double get nextSpeed {
    final current = availableSpeeds.indexOf(speed);
    return availableSpeeds[(current + 1) % availableSpeeds.length];
  }

  PlayerSettings copyWith({double? speed, String? voiceName, int? accentIndex}) => PlayerSettings(
        speed: speed ?? this.speed,
        voiceName: voiceName ?? this.voiceName,
        accentIndex: accentIndex ?? this.accentIndex,
      );

  @override
  List<Object?> get props => [speed, voiceName, accentIndex];
}
