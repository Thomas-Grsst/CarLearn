import 'speech_voice.dart';

abstract interface class SpeechEngine {
  Future<void> initialize();
  Future<List<SpeechVoice>> frenchVoices();
  Future<void> useVoice(SpeechVoice voice);
  Future<void> speak(String text, {required double speed});
  Future<void> stop();
}
