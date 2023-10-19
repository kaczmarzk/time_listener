import 'package:time_listener/time_listener.dart';

abstract interface class ITimeListener {
  Future<void> listen(Output output);

  void cancel();
}
