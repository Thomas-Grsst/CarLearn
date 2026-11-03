import 'package:carlearn/layers/functional/Lesson/data/data_sources/topic_asset_data_source.dart';
import 'package:carlearn/layers/functional/Lesson/data/gateways/asset_topic_gateway.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads every bundled topic with unique ids and alternating categories', () async {
    final topics = await AssetTopicGateway(TopicAssetDataSource(rootBundle)).loadAll();

    expect(topics, hasLength(100));
    expect(topics.map((topic) => topic.id).toSet(), hasLength(100));
    expect(topics.first.id, 'memoire');
    expect(topics[0].category, isNot(topics[1].category));
    for (final topic in topics) {
      expect(topic.sections, isNotEmpty, reason: topic.id);
      expect(topic.quiz, isNotEmpty, reason: topic.id);
    }
  });
}
