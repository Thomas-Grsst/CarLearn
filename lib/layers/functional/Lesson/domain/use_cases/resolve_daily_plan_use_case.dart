import '../entities/calendar_day.dart';
import '../entities/daily_plan.dart';
import '../entities/topic.dart';
import '../gateways/progress_gateway.dart';

class ResolveDailyPlanUseCase {
  const ResolveDailyPlanUseCase(this._progressGateway);

  final ProgressGateway _progressGateway;

  Future<DailyPlan> call({required List<Topic> topics, required CalendarDay today}) async {
    var startDay = await _progressGateway.readStartDay();
    if (startDay == null) {
      startDay = today;
      await _progressGateway.writeStartDay(today);
    }
    final offset = today.number - startDay.number;
    return DailyPlan(
      today: topics[offset % topics.length],
      tomorrow: topics[(offset + 1) % topics.length],
    );
  }
}
