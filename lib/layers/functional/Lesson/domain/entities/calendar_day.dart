import 'package:equatable/equatable.dart';

class CalendarDay extends Equatable {
  const CalendarDay(this.number);

  factory CalendarDay.from(DateTime moment) {
    final utcMidnight = DateTime.utc(moment.year, moment.month, moment.day);
    return CalendarDay(utcMidnight.millisecondsSinceEpoch ~/ Duration.millisecondsPerDay);
  }

  final int number;

  @override
  List<Object?> get props => [number];
}
