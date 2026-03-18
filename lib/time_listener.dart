library time_listener;

import 'dart:async';

import 'package:time_listener/src/enum/check_interval.dart';
import 'package:time_listener/src/extension/date_time_ext.dart';
import 'package:time_listener/src/utils/isolate_controller.dart';

export 'package:time_listener/src/enum/check_interval.dart';

Future<void> _timeLoop(
  CheckInterval interval,
  void Function(DateTime) send,
) async {
  DateTime last = _truncate(DateTime.now(), interval);
  while (true) {
    await Future.delayed(const Duration(seconds: 1));
    final now = _truncate(DateTime.now(), interval);
    if (now.isAfter(last)) {
      send(now);
      last = now;
    }
  }
}

DateTime _truncate(DateTime dt, CheckInterval interval) => switch (interval) {
      CheckInterval.minutes => dt.toMinutes,
      CheckInterval.seconds => dt.toSeconds,
    };

class TimeListener {
  TimeListener._({
    required this.interval,
    required IsolateController<DateTime> controller,
  }) : _controller = controller;

  static Future<TimeListener> create({
    CheckInterval interval = CheckInterval.minutes,
  }) async {
    final controller = await IsolateController.spawn<CheckInterval, DateTime>(
      _timeLoop,
      interval,
    );
    return TimeListener._(interval: interval, controller: controller);
  }

  final CheckInterval interval;
  final IsolateController<DateTime> _controller;

  Stream<DateTime> get stream => _controller.stream;

  void dispose() => _controller.close();
}
