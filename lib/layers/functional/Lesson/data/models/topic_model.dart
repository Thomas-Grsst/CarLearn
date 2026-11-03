import '../../domain/entities/quiz_question.dart';
import '../../domain/entities/topic.dart';
import '../../domain/entities/topic_section.dart';

class TopicModel {
  const TopicModel(this._json);

  final Map<String, dynamic> _json;

  bool get isValid =>
      _json['id'] is String &&
      _json['titre'] is String &&
      _json['sections'] is List &&
      (_json['sections'] as List).isNotEmpty &&
      _json['quiz'] is List;

  Topic toEntity() => Topic(
        id: _json['id'] as String,
        category: (_json['categorie'] as String?) ?? '',
        title: _json['titre'] as String,
        intro: (_json['intro'] as String?) ?? '',
        sections: [
          for (final raw in (_json['sections'] as List).cast<Map<String, dynamic>>())
            TopicSection(title: raw['titre'] as String, text: raw['texte'] as String),
        ],
        summary: (_json['resume'] as String?) ?? '',
        quiz: [
          for (final raw in (_json['quiz'] as List).cast<Map<String, dynamic>>())
            QuizQuestion(question: raw['q'] as String, answer: raw['r'] as String),
        ],
      );
}
