import '../../domain/entities/segment_kind.dart';
import '../cubit/player_state.dart';

class StepCaption {
  const StepCaption({required this.label, required this.title});

  factory StepCaption.of(PlayerState state) {
    final session = state.session!;
    final step = state.currentStep!;
    if (state.isFinished) {
      return const StepCaption(label: 'Fin de la séance', title: 'Appuie sur suivant pour un sujet bonus');
    }
    final kind = session.segments[step.segmentIndex].kind;
    final quizName = kind == SegmentKind.quiz ? 'Quiz' : 'Révision';
    return switch (kind) {
      SegmentKind.intro => const StepCaption(label: 'Introduction', title: 'Présentation du sujet'),
      SegmentKind.part => StepCaption(
          label: 'Partie ${step.partNumber} sur ${session.topic.sections.length}',
          title: step.partTitle ?? '',
        ),
      SegmentKind.summary => const StepCaption(label: 'Résumé', title: "L'essentiel à retenir"),
      SegmentKind.quiz || SegmentKind.revision => step.isQuizStep
          ? StepCaption(
              label: '$quizName · question ${step.questionNumber} sur ${step.questionTotal}',
              title: step.questionText ?? '',
            )
          : StepCaption(label: quizName, title: 'Prépare-toi à répondre'),
    };
  }

  final String label;
  final String title;
}
