import 'dart:async';

import 'package:flutter/material.dart';
import 'package:time_listener/time_listener.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TimeListener? _listener;
  StreamSubscription<DateTime>? _subscription;
  DateTime _time = DateTime.now();

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _listener = await TimeListener.create(interval: CheckInterval.seconds);
    _subscription = _listener!.stream.listen((dt) {
      if (mounted) setState(() => _time = dt);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _listener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Current time',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10.0),
            Text(
              '${_time.hour}:${_time.minute}:${_time.second}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
