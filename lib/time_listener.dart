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
    if (_controller == null && _subscription == null) return _create(output);
    return _subscription!.onData(output);
  }

  @override
  void cancel() {
    _timer?.cancel();
    _subscription?.cancel();
    _controller?.close();
  }

  Future<void> _create(Output output) async {
    _controller = await IsolateController.spawn<DateTime>(_handleDateChanged);
    _subscription = _controller!.stream.listen(output);
  }
}

extension _DateListenerExt on TimeListener {
  Future<void> _handleDateChanged(Output callback) async {
    DateTime date = DateTime.now();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        final now = DateTime.now().simple;
        if (!now.isAfter(date)) return;
        callback(now);
        date = now;
      },
    );
  }
}
