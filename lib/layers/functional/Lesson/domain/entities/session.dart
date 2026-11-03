import 'session_segment.dart';
import 'session_step.dart';
import 'topic.dart';

class Session {
  const Session({
    required this.topic,
    required this.steps,
    required this.segments,
    required this.revisedTopicTitles,
  });

  static const int wordsPerMinuteAtNormalSpeed = 155;

  final Topic topic;
  final List<SessionStep> steps;
  final List<SessionSegment> segments;
  final List<String> revisedTopicTitles;

  int get lastIndex => steps.length - 1;

  int firstStepOfSegment(int segmentIndex) =>
      steps.indexWhere((step) => step.segmentIndex == segmentIndex);

  int stepCountInSegment(int segmentIndex) =>
      steps.where((step) => step.segmentIndex == segmentIndex).length;

  Duration estimatedRemaining({required int fromIndex, required double speed}) {
    var milliseconds = 0.0;
    for (final step in steps.skip(fromIndex)) {
      final words = step.text.split(RegExp(r'\s+')).length;
      milliseconds += words / (wordsPerMinuteAtNormalSpeed * speed) * Duration.millisecondsPerMinute;
      milliseconds += step.pauseAfter.inMilliseconds;
    }
    return Duration(milliseconds: milliseconds.round());
  }
}
