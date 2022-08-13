# Ios will pop scope

The fork of [cupertino_will_pop_scope](https://pub.dev/packages/cupertino_will_pop_scope). This version provides correct behavior of [WillPopScope](https://api.flutter.dev/flutter/widgets/WillPopScope-class.html) for iOS back gesture, which is currently is not supported (see [issue#14203](https://github.com/flutter/flutter/issues/14203)). In forked package, callback passed to `WillPopScope` has been called for few times when we use iOS back gesture, this packages resolves this problem. 

> **_NOTE:_** You can replace your `WillPopScope` with `IosWillPopScope` at all, in order to support iOS back gesture. Anyway, for android and any other platform it will work just like regular `WillPopScope`.

---
You are able to check out the simple app that uses this package in [example](example/lib/main.dart)

<br />


## Getting Started

To use this package, add `ios_will_pop_scope` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

### Import the library

```dart
import 'package:ios_will_pop_scope/ios_will_pop_scope.dart';
```

### Configure page transition theme for iOS

```dart
return MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
        pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
                TargetPlatform.iOS: IosWillPopScopePageBuilder(),
            },
        ),
        primarySwatch: Colors.red,
    ),
    home: const MainScreen(),
);
```

### Wrap needed screen with `IosWillPopScope`

```dart
class SecondScreen extends StatelessWidget {
  const SecondScreen({Key? key}) : super(key: key);

  Future<bool> _onWillPop() async {
    print('Some action!!!');
    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return IosWillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('second screen'),
            ],
          ),
        ),
      ),
    );
  }
}
```