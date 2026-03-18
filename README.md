# time_listener
[![pub package](https://img.shields.io/pub/v/time_listener.svg)](https://pub.dev/packages/time_listener)

A Flutter plugin for listening to time changes via a stream. The time-checking loop runs in an isolate, keeping the UI thread free.

## Features

- Stream-based API — subscribe with any stream listener or `StreamBuilder`
- Isolate-backed — no impact on UI performance
- Two intervals: per-minute (default) or per-second

## Usage

Create a `TimeListener` with the async factory, then subscribe to `.stream`:

```dart
final listener = await TimeListener.create();

final subscription = listener.stream.listen((DateTime dt) {
  print('${dt.hour}:${dt.minute}');
});

// When no longer needed:
subscription.cancel();
listener.dispose();
```

Use `CheckInterval.seconds` for per-second updates:

```dart
final listener = await TimeListener.create(interval: CheckInterval.seconds);

listener.stream.listen((DateTime dt) {
  print('${dt.hour}:${dt.minute}:${dt.second}');
});
```

In a Flutter widget, use `StreamBuilder`:

```dart
FutureBuilder<TimeListener>(
  future: TimeListener.create(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return const SizedBox();
    return StreamBuilder<DateTime>(
      stream: snapshot.data!.stream,
      builder: (context, snap) {
        final dt = snap.data ?? DateTime.now();
        return Text('${dt.hour}:${dt.minute.toString().padLeft(2, '0')}');
      },
    );
  },
)
```

## API

| Member | Description |
|--------|-------------|
| `TimeListener.create({CheckInterval interval})` | Creates and starts the listener. Default interval: `CheckInterval.minutes`. |
| `stream` | `Stream<DateTime>` that emits on each interval tick. |
| `interval` | The `CheckInterval` this instance was created with. |
| `dispose()` | Shuts down the isolate. Call when the listener is no longer needed. |

`CheckInterval` values: `minutes`, `seconds`.