import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/calendar_day.dart';
import '../../domain/entities/saved_position.dart';
import '../../domain/gateways/progress_gateway.dart';

class SharedPreferencesProgressGateway implements ProgressGateway {
  const SharedPreferencesProgressGateway(this._preferences);

  static const String _startDayKey = 'progress.startDay';
  static const String _completedKey = 'progress.completedTopicIds';
  static const String _positionTopicKey = 'progress.position.topicId';
  static const String _positionDayKey = 'progress.position.day';
  static const String _positionStepKey = 'progress.position.step';
  static const String _positionBonusKey = 'progress.position.bonus';

  final SharedPreferencesAsync _preferences;

  @override
  Future<CalendarDay?> readStartDay() async {
    final number = await _preferences.getInt(_startDayKey);
    return number == null ? null : CalendarDay(number);
  }

  @override
  Future<void> writeStartDay(CalendarDay day) => _preferences.setInt(_startDayKey, day.number);

  @override
  Future<Set<String>> readCompletedTopicIds() async =>
      (await _preferences.getStringList(_completedKey))?.toSet() ?? <String>{};

  @override
  Future<void> markCompleted(String topicId) async {
    final completed = await readCompletedTopicIds();
    if (completed.add(topicId)) {
      await _preferences.setStringList(_completedKey, completed.toList());
    }
  }

  @override
  Future<SavedPosition?> readPosition() async {
    final topicId = await _preferences.getString(_positionTopicKey);
    final day = await _preferences.getInt(_positionDayKey);
    final step = await _preferences.getInt(_positionStepKey);
    if (topicId == null || day == null || step == null) {
      return null;
    }
    return SavedPosition(
      topicId: topicId,
      day: CalendarDay(day),
      stepIndex: step,
      isBonus: await _preferences.getBool(_positionBonusKey) ?? false,
    );
  }

  @override
  Future<void> writePosition(SavedPosition position) async {
    await _preferences.setString(_positionTopicKey, position.topicId);
    await _preferences.setInt(_positionDayKey, position.day.number);
    await _preferences.setInt(_positionStepKey, position.stepIndex);
    await _preferences.setBool(_positionBonusKey, position.isBonus);
  }
}
