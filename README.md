# time_listener
[![pub package](https://img.shields.io/pub/v/time_listener.svg)](https://pub.dev/packages/time_listener)

An extremely easy-to-use flutter plugin that allows you to listen time changes.

### Features

This package makes very easy to listen time changes using a stream.
The code responsible for checking time diff is run in an isolate, so you don't have to worry about performance.

### Usage

To start listening create instance of the class and call "listen" method on it.
Stream event with the new date will come every second.

```dart
  // actively listen for time updates with the interval specified in parameter
  // until listener.cancel() is called
  final listener = TimeListener()..listen((DateTime dt) {
  print('${dt.hour}:${dt.minute}:${dt.second}');
  });

  // don't forget to cancel listener when it is no longer needed
  // so the program doesn't run forever
  await listener.cancel();
```  
To specify interval (by default every minute) you can use custom factory.
```dart

  // below code will emit new DateTime every minute without seconds precision
  // output - 21:37:00
  final listener = TimeListener()..listen((DateTime dt) {
  print('${dt.hour}:${dt.minute}:${dt.second}');
  });

  // but if you need u can specify more precise interval with custom factory
  // output - 21:37:24
  final listener = TimeListener.create(interval: CheckInterval.seconds)..listen((DateTime dt) {
  print('${dt.hour}:${dt.minute}:${dt.second}');
  });
```  

