import 'package:equatable/equatable.dart';

class SpeechVoice extends Equatable {
  const SpeechVoice({required this.name, required this.locale, required this.requiresNetwork});

  final String name;
  final String locale;
  final bool requiresNetwork;

  @override
  List<Object?> get props => [name, locale];
}
