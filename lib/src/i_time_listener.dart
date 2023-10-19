import 'package:time_listener/src/types/output_type.dart';

abstract interface class ITimeListener {
  Future<void> listen(Output output);

  void cancel();
}
