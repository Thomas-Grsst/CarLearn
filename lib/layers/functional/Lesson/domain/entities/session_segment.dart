import 'segment_kind.dart';

class SessionSegment {
  const SessionSegment({required this.kind, required this.weight});

  final SegmentKind kind;
  final int weight;
}
