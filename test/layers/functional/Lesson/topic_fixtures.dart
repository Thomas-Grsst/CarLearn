import 'package:carlearn/layers/functional/Lesson/domain/entities/quiz_question.dart';
import 'package:carlearn/layers/functional/Lesson/domain/entities/topic.dart';
import 'package:carlearn/layers/functional/Lesson/domain/entities/topic_section.dart';

Topic buildTopic(String id, {int sectionCount = 2, int questionCount = 2}) => Topic(
      id: id,
      category: 'Catégorie $id',
      title: 'Titre $id',
      intro: 'Intro de $id. Deuxième phrase.',
      sections: [
        for (var i = 1; i <= sectionCount; i++) TopicSection(title: 'Partie $i de $id', text: 'Texte $i. Suite $i !'),
      ],
      summary: 'En résumé : $id.',
      quiz: [
        for (var i = 1; i <= questionCount; i++) QuizQuestion(question: 'Question $i de $id ?', answer: 'Réponse $i.'),
      ],
    );
