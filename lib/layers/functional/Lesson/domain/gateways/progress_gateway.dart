import '../entities/calendar_day.dart';
import '../entities/saved_position.dart';

abstract interface class ProgressGateway {
  Future<CalendarDay?> readStartDay();
  Future<void> writeStartDay(CalendarDay day);
  Future<Set<String>> readCompletedTopicIds();
  Future<void> markCompleted(String topicId);
  Future<SavedPosition?> readPosition();
  Future<void> writePosition(SavedPosition position);
}
