import 'dart:async';
import 'dart:isolate';

typedef IsolateHandler<Out> = FutureOr<void> Function(
    void Function(Out out) send);

class IsolateController<Out> {
  IsolateController._({
    required this.stream,
    required this.close,
  });

  final Stream<Out> stream;
  final void Function() close;

  static Future<void> _$entryPoint<Out>(_IsolateArgument<Out> argument) async {
    try {
      await argument();
    } finally {
      argument.sendPort.send(#exit);
    }
  }

  static Future<IsolateController<Out>> spawn<Out>(
      IsolateHandler<Out> handler) async {
    final receivePort = ReceivePort();
    final argument = _IsolateArgument<Out>(
      handler: handler,
      sendPort: receivePort.sendPort,
    );

    final isolate = await Isolate.spawn<_IsolateArgument<Out>>(
      _$entryPoint<Out>,
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

class _IsolateArgument<Out> {
  _IsolateArgument({
    required this.handler,
    required this.sendPort,
  });

  final IsolateHandler<Out> handler;
  final SendPort sendPort;

  FutureOr<void> call() => handler(sendPort.send);
}
