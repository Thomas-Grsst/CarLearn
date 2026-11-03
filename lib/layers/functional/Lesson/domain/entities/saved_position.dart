import 'calendar_day.dart';

class SavedPosition {
  const SavedPosition({
    required this.topicId,
    required this.day,
    required this.stepIndex,
    required this.isBonus,
  });

  final String topicId;
  final CalendarDay day;
  final int stepIndex;
  final bool isBonus;
}
