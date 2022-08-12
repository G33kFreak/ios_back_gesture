// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:ios_will_pop_scope/ios_will_pop_scope.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  IosPageRouteBuilder(
                    routeSettings: IosRouteSettings(
                      onWillPop: () {
                        print('Some action!');
                        return Future.value(false);
                      },
                    ),
                    pageBuilder: (context, _, __) => const SecondScreen(),
                  ),
                );
              },
              child: const Text('To second screen'),
            ),
          ],
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  const SecondScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We need to configure this button as well, since adding
      // ios back gesture conflicts with WillPopScope. Once again
      // it affects iOS version only
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            print('Some action!');
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('second screen'),
          ],
        ),
      ),
    );
  }
}
