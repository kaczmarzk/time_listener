import 'dart:async';
import 'dart:isolate';

typedef IsolateHandler<In, Out> = FutureOr<void> Function(
  In input,
  void Function(Out out) send,
);

class IsolateController<Out> {
  IsolateController._({
    required this.stream,
    required this.close,
  });

  final Stream<Out> stream;
  final void Function() close;

  static Future<void> _$entryPoint<In, Out>(
      _IsolateArgument<In, Out> argument) async {
    try {
      await argument();
    } finally {
      argument.sendPort.send(#exit);
    }
  }

  static Future<IsolateController<Out>> spawn<In, Out>(
    IsolateHandler<In, Out> handler,
    In input,
  ) async {
    final receivePort = ReceivePort();
    final argument = _IsolateArgument<In, Out>(
      handler: handler,
      input: input,
      sendPort: receivePort.sendPort,
    );

    final isolate = await Isolate.spawn<_IsolateArgument<In, Out>>(
      _$entryPoint<In, Out>,
      argument,
      errorsAreFatal: true,
    );

    final outputController = StreamController<Out>.broadcast();
    late final StreamSubscription<Object?> rcvSubscription;

    void close() {
      receivePort.close();
      rcvSubscription.cancel().ignore();
      outputController.close().ignore();
      isolate.kill();
    }

    rcvSubscription = receivePort.listen(
      (message) {
        if (message is Out) {
          outputController.add(message);
        } else if (message == #exit) {
          close();
        }
      },
      onError: outputController.addError,
      cancelOnError: false,
    );

    return IsolateController<Out>._(
      stream: outputController.stream,
      close: close,
    );
  }
}

class _IsolateArgument<In, Out> {
  _IsolateArgument({
    required this.handler,
    required this.input,
    required this.sendPort,
  });

  final IsolateHandler<In, Out> handler;
  final In input;
  final SendPort sendPort;

  FutureOr<void> call() => handler(input, sendPort.send);
}
