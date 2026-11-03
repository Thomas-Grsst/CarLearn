import 'dart:math';

import '../entities/segment_kind.dart';
import '../entities/session.dart';
import '../entities/session_segment.dart';
import '../entities/session_step.dart';
import '../entities/step_kind.dart';
import '../entities/topic.dart';

class BuildSessionUseCase {
  BuildSessionUseCase({Random? random}) : _random = random ?? Random();

  static const Duration thinkingTime = Duration(seconds: 7);
  static const int revisionQuestionCount = 6;
  static const Duration _sentencePause = Duration(milliseconds: 350);
  static const Duration _headingPause = Duration(milliseconds: 700);
  static const Duration _transitionPause = Duration(milliseconds: 800);
  static const Duration _answerPause = Duration(milliseconds: 1200);
  static final RegExp _sentencePattern = RegExp(r'[^.!?…]+[.!?…]+[»"]?\s*|[^.!?…]+$');

  final Random _random;

  Session call({required Topic topic, required List<Topic> revisionPool}) {
    final steps = <SessionStep>[];
    final segments = <SessionSegment>[];

    int openSegment(SegmentKind kind, {int weight = 1}) {
      segments.add(SessionSegment(kind: kind, weight: weight));
      return segments.length - 1;
    }

    void narrate(String text, int segment, {Duration pause = _sentencePause, int? partNumber, String? partTitle}) {
      for (final sentence in splitSentences(text)) {
        steps.add(SessionStep(
          text: sentence,
          segmentIndex: segment,
          kind: StepKind.narration,
          pauseAfter: pause,
          partNumber: partNumber,
          partTitle: partTitle,
        ));
      }
    }

    final intro = openSegment(SegmentKind.intro);
    narrate('Sujet du jour : ${topic.title}.', intro, pause: _headingPause);
    narrate(topic.intro, intro);

    for (var i = 0; i < topic.sections.length; i++) {
      final section = topic.sections[i];
      final part = openSegment(SegmentKind.part);
      narrate('Partie ${i + 1} : ${section.title}.', part, pause: _headingPause, partNumber: i + 1, partTitle: section.title);
      narrate(section.text, part, partNumber: i + 1, partTitle: section.title);
    }

    narrate(topic.summary, openSegment(SegmentKind.summary));

    final quiz = openSegment(SegmentKind.quiz, weight: 2);
    narrate('Place au quiz. Je pose une question, tu as quelques secondes pour répondre à voix haute.', quiz, pause: _transitionPause);
    for (var i = 0; i < topic.quiz.length; i++) {
      final question = topic.quiz[i];
      _addQuestion(steps, quiz, i + 1, topic.quiz.length, 'Question ${i + 1}. ${question.question}', question.question, question.answer, null);
    }

    final revisedTitles = <String>[];
    final candidates = [
      for (final other in revisionPool.where((other) => other != topic))
        for (final question in other.quiz) (topic: other, question: question),
    ]..shuffle(_random);
    final picked = candidates.take(revisionQuestionCount).toList();
    if (picked.isNotEmpty) {
      final revision = openSegment(SegmentKind.revision, weight: 2);
      narrate('Maintenant, un peu de révision sur les sujets des jours précédents.', revision, pause: _transitionPause);
      for (var i = 0; i < picked.length; i++) {
        final entry = picked[i];
        if (!revisedTitles.contains(entry.topic.title)) {
          revisedTitles.add(entry.topic.title);
        }
        _addQuestion(steps, revision, i + 1, picked.length, 'À propos de : ${entry.topic.title}. ${entry.question.question}',
            entry.question.question, entry.question.answer, entry.topic.title);
      }
    }

    steps.add(SessionStep(
      text: "C'est terminé pour aujourd'hui. Il te reste de la route ? Appuie sur suivant pour un sujet bonus. Bonne route !",
      segmentIndex: segments.length,
      kind: StepKind.end,
      pauseAfter: Duration.zero,
    ));

    return Session(topic: topic, steps: steps, segments: segments, revisedTopicTitles: revisedTitles);
  }

  static List<String> splitSentences(String text) {
    final sentences = _sentencePattern.allMatches(text).map((match) => match.group(0)!.trim()).where((s) => s.isNotEmpty).toList();
    return sentences.isEmpty ? [text] : sentences;
  }

  void _addQuestion(List<SessionStep> steps, int segment, int number, int total, String spoken, String question, String answer,
      String? revisionTopicTitle) {
    steps
      ..add(SessionStep(
        text: spoken,
        segmentIndex: segment,
        kind: StepKind.question,
        pauseAfter: thinkingTime,
        questionNumber: number,
        questionTotal: total,
        questionText: question,
        revisionTopicTitle: revisionTopicTitle,
      ))
      ..add(SessionStep(
        text: 'Réponse : $answer',
        segmentIndex: segment,
        kind: StepKind.answer,
        pauseAfter: _answerPause,
        questionNumber: number,
        questionTotal: total,
        questionText: question,
        revisionTopicTitle: revisionTopicTitle,
      ));
  }
}
