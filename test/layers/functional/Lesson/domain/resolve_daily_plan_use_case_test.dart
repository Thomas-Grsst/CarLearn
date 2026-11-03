import 'package:carlearn/layers/functional/Lesson/domain/entities/calendar_day.dart';
import 'package:carlearn/layers/functional/Lesson/domain/use_cases/resolve_daily_plan_use_case.dart';
import 'package:flutter_test/flutter_test.dart';

import '../topic_fixtures.dart';
import 'fake_progress_gateway.dart';

void main() {
  final topics = [for (final id in ['a', 'b', 'c']) buildTopic(id)];

  test('starts with the first topic on the first day and remembers that day', () async {
    final gateway = FakeProgressGateway();

    final plan = await ResolveDailyPlanUseCase(gateway)(topics: topics, today: const CalendarDay(100));

    expect(plan.today.id, 'a');
    expect(plan.tomorrow.id, 'b');
    expect(gateway.startDay, const CalendarDay(100));
  });

  test('moves one topic per day and wraps around', () async {
    final gateway = FakeProgressGateway()..startDay = const CalendarDay(100);

    final plan = await ResolveDailyPlanUseCase(gateway)(topics: topics, today: const CalendarDay(102));

    expect(plan.today.id, 'c');
    expect(plan.tomorrow.id, 'a');
  });

  test('derives the calendar day from the local date', () {
    expect(CalendarDay.from(DateTime(2026, 11, 3, 23, 59)), CalendarDay.from(DateTime(2026, 11, 3, 0, 1)));
    expect(CalendarDay.from(DateTime(2026, 11, 4)).number - CalendarDay.from(DateTime(2026, 11, 3)).number, 1);
  });
}
