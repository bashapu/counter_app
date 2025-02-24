import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';

void main() {
  setupWindow();
  runApp(
    // Provide the model to all widgets within the app. We're using
    // ChangeNotifierProvider because that's a simple way to rebuild
    // widgets when a model changes. We could also just use
    // Provider, but then we would have to listen to Counter ourselves.
    //
    // Read Provider's docs to learn about all the available providers.
    ChangeNotifierProvider(
      // Initialize the model in the builder. That way, Provider
      // can own Counter's lifecycle, making sure to call `dispose`
      // when not needed anymore.
      create: (context) => Counter(),
      child: const MyApp(),
    ),
  );
}

const double windowWidth = 360;
const double windowHeight = 640;
void setupWindow() {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    WidgetsFlutterBinding.ensureInitialized();
    setWindowTitle('Provider Counter');
    setWindowMinSize(const Size(windowWidth, windowHeight));
    setWindowMaxSize(const Size(windowWidth, windowHeight));
    getCurrentScreen().then((screen) {
      setWindowFrame(
        Rect.fromCenter(
          center: screen!.frame.center,
          width: windowWidth,
          height: windowHeight,
        ),
      );
    });
  }
}

/// Simplest possible model, with just one field.
///
/// [ChangeNotifier] is a class in `flutter:foundation`. [Counter] does
/// _not_ depend on Provider.
class Counter with ChangeNotifier {
  int value = 0;
  String message = 'You\'re a child!';
  Color bgColor = Colors.lightBlue;

  void increment() {
    if (value < 100) {
      value += 1;
      _updateStage();
      notifyListeners();
    }
  }

  void decrement() {
    if (value > 0) {
      value -= 1;
      _updateStage();
      notifyListeners();
    }
  }

  void setValue(double val) {
    value = val.toInt();
    _updateStage();
    notifyListeners();
  }

  void _updateStage() {
    if (value <= 12) {
      message = 'You\'re a child!';
      bgColor = Colors.lightBlue;
    } else if (value <= 19) {
      message = 'Teenager time!';
      bgColor = Colors.lightGreen;
    } else if (value <= 30) {
      message = 'You\'re a young adult';
      bgColor = Colors.yellowAccent;
    } else if (value <= 50) {
      message = 'You\'re an adult now!';
      bgColor = Colors.orange;
    } else if (value <= 67) {
      message = 'You\'re in mid-life!';
      bgColor = Colors.amber;
    } else {
      message = 'Golden years!';
      bgColor = Colors.grey;
    }
  }

  double get progress {
    if (value <= 33) {
      return value / 33;
    } else if (value <= 67) {
      return (value - 33) / 33;
    } else {
      return (value - 67) / 33;
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Age Counter App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Age Counter')),
      // Consumer looks for an ancestor Provider widget
      // and retrieves its model (Counter, in this case).
      // Then it uses that model to build widgets, and will trigger
      // rebuilds if the model is updated.
      body: Consumer<Counter>(
        builder: (context, counter, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: counter.bgColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'I am ${counter.value} Years old!',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    counter.message,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: counter.increment,
                    child: const Text('Increase Age'),
                  ),
                  ElevatedButton(
                    onPressed: counter.decrement,
                    child: const Text('Decrease Age'),
                  ),
                  Slider(
                    min: 0,
                    max: 100,
                    value: counter.value.toDouble(),
                    onChanged: counter.setValue,
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: counter.progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      counter.value <= 33
                          ? Colors.green
                          : counter.value <= 67
                              ? Colors.yellow
                              : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // You can access your providers anywhere you have access
      //     // to the context. One way is to use Provider.of<Counter>(context).
      //     // The provider package also defines extension methods on the context
      //     // itself. You can call context.watch<Counter>() in a build method
      //     // of any widget to access the current state of Counter, and to ask
      //     // Flutter to rebuild your widget anytime Counter changes.
      //     //
      //     // You can't use context.watch() outside build methods, because that
      //     // often leads to subtle bugs. Instead, you should use
      //     // context.read<Counter>(), which gets the current state
      //     // but doesn't ask Flutter for future rebuilds.
      //     //
      //     // Since we're in a callback that will be called whenever the user
      //     // taps the FloatingActionButton, we are not in the build method here.
      //     // We should use context.read().
      //     var counter = context.read<Counter>();
      //     counter.increment();
      //   },
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
