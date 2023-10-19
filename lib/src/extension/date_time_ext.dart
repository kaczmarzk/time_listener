extension DateTimeExt on DateTime {
  DateTime get simple => copyWith(second: 0, millisecond: 0, microsecond: 0);
}
