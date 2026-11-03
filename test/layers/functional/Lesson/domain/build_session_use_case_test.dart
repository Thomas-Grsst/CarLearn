import 'dart:math';

import 'package:carlearn/layers/functional/Lesson/domain/entities/segment_kind.dart';
import 'package:carlearn/layers/functional/Lesson/domain/entities/step_kind.dart';
import 'package:carlearn/layers/functional/Lesson/domain/use_cases/build_session_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../topic_fixtures.dart';

void main() {
  final buildSession = BuildSessionUseCase(random: Random(1));

  test('splits text into spoken sentences', () {
    expect(
      BuildSessionUseCase.splitSentences('Bonjour. Ça va ? Oui ! Fin sans point'),
      ['Bonjour.', 'Ça va ?', 'Oui !', 'Fin sans point'],
    );
  });

  test('orders segments intro, parts, summary, quiz and ends the session', () {
    final session = buildSession(topic: buildTopic('a'), revisionPool: const []);

    expect(session.segments.map((segment) => segment.kind), [
      SegmentKind.intro,
      SegmentKind.part,
      SegmentKind.part,
      SegmentKind.summary,
      SegmentKind.quiz,
    ]);
    expect(session.steps.first.text, 'Sujet du jour : Titre a.');
    expect(session.steps.last.kind, StepKind.end);
    expect(session.revisedTopicTitles, isEmpty);
  });

  test('pairs each quiz question with its answer and a thinking pause', () {
    final session = buildSession(topic: buildTopic('a', questionCount: 3), revisionPool: const []);
    final questions = session.steps.where((step) => step.kind == StepKind.question).toList();
    final answers = session.steps.where((step) => step.kind == StepKind.answer).toList();

    expect(questions, hasLength(3));
    expect(answers.map((step) => step.text), ['Réponse : Réponse 1.', 'Réponse : Réponse 2.', 'Réponse : Réponse 3.']);
    expect(questions.every((step) => step.pauseAfter == BuildSessionUseCase.thinkingTime), isTrue);
    expect(questions.map((step) => step.questionNumber), [1, 2, 3]);
  });

  test('adds a revision segment from completed topics only', () {
    final current = buildTopic('a');
    final session = buildSession(topic: current, revisionPool: [current, buildTopic('b'), buildTopic('c')]);

    expect(session.segments.last.kind, SegmentKind.revision);
    expect(session.revisedTopicTitles, unorderedEquals(['Titre b', 'Titre c']));
    final revisionQuestions = session.steps.where((step) => step.revisionTopicTitle != null && step.kind == StepKind.question);
    expect(revisionQuestions, hasLength(4));
  });

  test('caps revision at six questions', () {
    final pool = [for (var i = 0; i < 5; i++) buildTopic('t$i', questionCount: 5)];
    final session = buildSession(topic: buildTopic('a'), revisionPool: pool);
    final revisionQuestions = session.steps.where((step) => step.revisionTopicTitle != null && step.kind == StepKind.question);

    expect(revisionQuestions, hasLength(BuildSessionUseCase.revisionQuestionCount));
  });
}
