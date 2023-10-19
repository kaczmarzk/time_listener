extension DateTimeExt on DateTime {
  DateTime get toMinutes => copyWith(second: 0, millisecond: 0, microsecond: 0);
  DateTime get toSeconds => copyWith(millisecond: 0, microsecond: 0);
}
