import 'package:carlearn/layers/functional/Lesson/domain/entities/player_settings.dart';
import 'package:carlearn/layers/functional/Lesson/domain/entities/topic.dart';
import 'package:carlearn/layers/functional/Lesson/domain/gateways/settings_gateway.dart';
import 'package:carlearn/layers/functional/Lesson/domain/gateways/topic_gateway.dart';
import 'package:carlearn/layers/technical/ScreenWake/screen_wake.dart';
import 'package:carlearn/layers/technical/Speech/speech_engine.dart';
import 'package:carlearn/layers/technical/Speech/speech_voice.dart';

class FakeTopicGateway implements TopicGateway {
  FakeTopicGateway(this.topics);

  final List<Topic> topics;

  @override
  Future<List<Topic>> loadAll() async => topics;
}

class FakeSettingsGateway implements SettingsGateway {
  PlayerSettings stored = PlayerSettings.defaults;

  @override
  Future<PlayerSettings> read() async => stored;

  @override
  Future<void> write(PlayerSettings settings) async => stored = settings;
}

class FakeSpeechEngine implements SpeechEngine {
  final List<String> spoken = [];
  final List<double> speeds = [];
  SpeechVoice? voice;

  @override
  Future<void> initialize() async {}

  @override
  Future<List<SpeechVoice>> frenchVoices() async =>
      const [SpeechVoice(name: 'fr-fr-x-local', locale: 'fr-FR', requiresNetwork: false)];

  @override
  Future<void> useVoice(SpeechVoice voice) async => this.voice = voice;

  @override
  Future<void> speak(String text, {required double speed}) async {
    spoken.add(text);
    speeds.add(speed);
  }

  @override
  Future<void> stop() async {}
}

class FakeScreenWake implements ScreenWake {
  bool isOn = false;

  @override
  Future<void> keepOn() async => isOn = true;

  @override
  Future<void> release() async => isOn = false;
}

