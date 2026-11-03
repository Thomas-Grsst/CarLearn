import 'package:carlearn/layers/functional/Lesson/domain/use_cases/pick_bonus_topic_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../topic_fixtures.dart';

void main() {
  const pickBonus = PickBonusTopicUseCase();
  final topics = [for (final id in ['a', 'b', 'c', 'd']) buildTopic(id)];

  test('skips tomorrow topic and completed topics', () {
    final bonus = pickBonus(topics: topics, current: topics[0], tomorrow: topics[1], completedTopicIds: {'c'});

    expect(bonus.id, 'd');
  });

  test('falls back to the next topic when everything is completed', () {
    final bonus = pickBonus(topics: topics, current: topics[0], tomorrow: topics[1], completedTopicIds: {'a', 'b', 'c', 'd'});

    expect(bonus.id, 'b');
  });
}
