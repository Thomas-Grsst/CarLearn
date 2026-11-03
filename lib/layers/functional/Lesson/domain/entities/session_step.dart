import 'step_kind.dart';

class SessionStep {
  const SessionStep({
    required this.text,
    required this.segmentIndex,
    required this.kind,
    required this.pauseAfter,
    this.partNumber,
    this.partTitle,
    this.questionNumber,
    this.questionTotal,
    this.questionText,
    this.revisionTopicTitle,
  });

  final String text;
  final int segmentIndex;
  final StepKind kind;
  final Duration pauseAfter;
  final int? partNumber;
  final String? partTitle;
  final int? questionNumber;
  final int? questionTotal;
  final String? questionText;
  final String? revisionTopicTitle;

  bool get isQuizStep => questionNumber != null;
}
