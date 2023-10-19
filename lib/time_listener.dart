library time_listener;

import 'dart:async';

import 'package:time_listener/src/extension/date_time_ext.dart';
import 'package:time_listener/src/i_time_listener.dart';
import 'package:time_listener/src/utils/isolate_controller.dart';

typedef Output = void Function(DateTime);

class TimeListener implements ITimeListener {
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
  Future<void> _handleDateChanged(Output callback) async {
    DateTime date = DateTime.now();
    while (true) {
      await Future.delayed(
        const Duration(seconds: 1),
        () {
          final now = DateTime.now().simple;
          if (!now.isAfter(date)) return;
          callback(now);
          date = now;
        },
      );
    }
  }
}
