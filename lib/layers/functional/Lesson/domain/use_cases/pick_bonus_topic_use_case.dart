import '../entities/topic.dart';

class PickBonusTopicUseCase {
  const PickBonusTopicUseCase();

  Topic call({
    required List<Topic> topics,
    required Topic current,
    required Topic tomorrow,
    required Set<String> completedTopicIds,
  }) {
    final start = topics.indexOf(current);
    for (var offset = 1; offset <= topics.length; offset++) {
      final candidate = topics[(start + offset) % topics.length];
      final isExcluded = candidate == current || candidate == tomorrow;
      if (!isExcluded && !completedTopicIds.contains(candidate.id)) {
        return candidate;
      }
    }
    return topics[(start + 1) % topics.length];
  }
}
