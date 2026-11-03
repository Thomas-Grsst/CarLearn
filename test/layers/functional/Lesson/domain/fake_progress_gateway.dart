import 'package:carlearn/layers/functional/Lesson/domain/entities/calendar_day.dart';
import 'package:carlearn/layers/functional/Lesson/domain/entities/saved_position.dart';
import 'package:carlearn/layers/functional/Lesson/domain/gateways/progress_gateway.dart';

class FakeProgressGateway implements ProgressGateway {
  CalendarDay? startDay;
  final Set<String> completed = {};
  SavedPosition? position;

  @override
  Future<CalendarDay?> readStartDay() async => startDay;

  @override
  Future<void> writeStartDay(CalendarDay day) async => startDay = day;

  @override
  Future<Set<String>> readCompletedTopicIds() async => {...completed};

  @override
  Future<void> markCompleted(String topicId) async => completed.add(topicId);

  @override
  Future<SavedPosition?> readPosition() async => position;

  @override
  Future<void> writePosition(SavedPosition position) async => this.position = position;
}
