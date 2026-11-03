import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import 'speech_engine.dart';
import 'speech_voice.dart';

class FlutterTtsSpeechEngine implements SpeechEngine {
  FlutterTtsSpeechEngine(this._tts);

  static const double _platformNormalRate = 0.5;
  static const String _language = 'fr-FR';

  final FlutterTts _tts;
  Completer<void>? _pendingUtterance;

  @override
  Future<void> initialize() async {
    _tts
      ..setCompletionHandler(_finishPendingUtterance)
      ..setCancelHandler(_finishPendingUtterance)
      ..setErrorHandler((_) => _finishPendingUtterance());
    await _tts.awaitSpeakCompletion(false);
    await _tts.setLanguage(_language);
    await _tts.setAudioAttributesForNavigation();
  }

  @override
  Future<List<SpeechVoice>> frenchVoices() async {
    final rawVoices = await _tts.getVoices as List<dynamic>? ?? const [];
    final voices = rawVoices
        .whereType<Map<dynamic, dynamic>>()
        .map((raw) => SpeechVoice(
              name: '${raw['name']}',
              locale: '${raw['locale']}',
              requiresNetwork: raw['network_required'] == '1',
            ))
        .where((voice) => voice.locale.toLowerCase().startsWith('fr'))
        .toList()
      ..sort((a, b) {
        if (a.requiresNetwork != b.requiresNetwork) {
          return a.requiresNetwork ? 1 : -1;
        }
        return a.name.compareTo(b.name);
      });
    return voices;
  }

  @override
  Future<void> useVoice(SpeechVoice voice) async {
    await _tts.setVoice({'name': voice.name, 'locale': voice.locale});
  }

  @override
  Future<void> speak(String text, {required double speed}) async {
    _finishPendingUtterance();
    final utterance = Completer<void>();
    _pendingUtterance = utterance;
    await _tts.setSpeechRate(_platformNormalRate * speed);
    final queued = await _tts.speak(text, focus: true);
    if (queued != 1) {
      _finishPendingUtterance();
    }
    return utterance.future;
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
    _finishPendingUtterance();
  }

  void _finishPendingUtterance() {
    final utterance = _pendingUtterance;
    _pendingUtterance = null;
    if (utterance != null && !utterance.isCompleted) {
      utterance.complete();
    }
  }
}
