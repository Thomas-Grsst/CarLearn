import 'package:carlearn/layers/functional/Lesson/data/data_sources/topic_asset_data_source.dart';
import 'package:carlearn/layers/functional/Lesson/data/gateways/asset_topic_gateway.dart';
import 'package:carlearn/layers/functional/Lesson/domain/use_cases/build_session_use_case.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const minimumDuration = Duration(minutes: 11);

  test('every topic lasts at least ten minutes at normal speed, with a safety margin', () async {
    final topics = await AssetTopicGateway(TopicAssetDataSource(rootBundle)).loadAll();
    final buildSession = BuildSessionUseCase();

    final tooShort = <String>[];
    for (final topic in topics) {
      final duration = buildSession(topic: topic, revisionPool: const []).estimatedRemaining(fromIndex: 0, speed: 1.0);
      if (duration < minimumDuration) {
        tooShort.add('${topic.id} (${(duration.inSeconds / 60).toStringAsFixed(1)} min)');
      }
    }

    expect(tooShort, isEmpty);
  });
}
