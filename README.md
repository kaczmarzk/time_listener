## time_listener
An extremely easy-to-use flutter plugin that allows you to listen time changes.

### Features

This package makes it easy to listen for the device's time change using a dedicated stream.
The code responsible for checking the time difference is run in a isolate, so you don't have to worry about performance.

### Usage

To start listening, create instances of the class and call the listen method on it.
Stream  event with the new date will come every second.
  ```dart
final listener = TimeListener();
listener.listen((DateTime date) => print(date));
```

Remember to stop listening the moment you no longer need it.

  ```dart
 listener.cancel();
```
  