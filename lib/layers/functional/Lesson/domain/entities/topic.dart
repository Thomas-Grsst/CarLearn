import 'package:equatable/equatable.dart';

import 'quiz_question.dart';
import 'topic_section.dart';

class Topic extends Equatable {
  const Topic({
    required this.id,
    required this.category,
    required this.title,
    required this.intro,
    required this.sections,
    required this.summary,
    required this.quiz,
  });

  final String id;
  final String category;
  final String title;
  final String intro;
  final List<TopicSection> sections;
  final String summary;
  final List<QuizQuestion> quiz;

  @override
  List<Object?> get props => [id];
}
