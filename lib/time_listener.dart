library time_listener;

import 'dart:async';

import 'package:time_listener/src/enum/check_interval.dart';
import 'package:time_listener/src/extension/date_time_ext.dart';
import 'package:time_listener/src/i_time_listener.dart';
import 'package:time_listener/src/types/output_type.dart';
import 'package:time_listener/src/utils/isolate_controller.dart';

export 'package:time_listener/src/enum/check_interval.dart';

class TimeListener implements ITimeListener {
  TimeListener._({this.interval = CheckInterval.minutes});

  factory TimeListener() => TimeListener._(
        interval: CheckInterval.minutes,
      );

  factory TimeListener.create({
    CheckInterval interval = CheckInterval.minutes,
  }) =>
      TimeListener._(
        interval: interval,
      );

  final CheckInterval interval;

  IsolateController<DateTime>? _controller;
  Timer? _timer;
  StreamSubscription<DateTime>? _subscription;

  @override
  Future<void> listen(Output output) async {
    if (_subscription != null) return _subscription!.onData(output);

    _controller = await IsolateController.spawn<DateTime>(_handleDateChanged);
    _subscription = _controller!.stream.listen(output);
  }

  @override
  void cancel() {
    _timer?.cancel();
    _subscription?.cancel();
    _controller?.close();
  }
}

extension _DateListenerExt on TimeListener {
  DateTime get _now => switch (interval) {
        CheckInterval.minutes => DateTime.now().toMinutes,
        CheckInterval.seconds => DateTime.now().toSeconds,
      };

  Future<void> _handleDateChanged(Output callback) async {
    DateTime date = _now;
    while (true) {
      await Future.delayed(const Duration(seconds: 1), () {
        final n = _now;
        if (!n.isAfter(date)) return;
        callback(n);
        date = n;
      });
    }
  }
}
