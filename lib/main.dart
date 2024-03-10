import 'dart:async';
import 'dart:math';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_event/keyboard_event.dart';
import 'package:win32/win32.dart';
import 'dart:ffi';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer? timer;
  final combinationKeys = <String>[];
  int count = 0;
  final keyboardEvent = KeyboardEvent();

  void moveMouse() {
    final input = calloc<INPUT>();
    input.ref.type = INPUT_MOUSE;
    input.ref.mi.dx =
        Random().nextInt(1024) * 65536 ~/ GetSystemMetrics(SM_CXSCREEN);
    input.ref.mi.dy =
        Random().nextInt(720) * 65536 ~/ GetSystemMetrics(SM_CYSCREEN);
    input.ref.mi.mouseData = 0;
    input.ref.mi.dwFlags = MOUSEEVENTF_MOVE | MOUSEEVENTF_ABSOLUTE;
    input.ref.mi.time = 0;
    input.ref.mi.dwExtraInfo = GetMessageExtraInfo();
    SendInput(1, input, sizeOf<INPUT>());
    print(">>> move_mouse");
    calloc.free(input);
  }

  void timerInitial() {
    timer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
          moveMouse();
        });
  }

  void keyDown(String key) {
    combinationKeys.add(key.toUpperCase());
    checkCombination();
    print(">>>>1 $combinationKeys");
  }

  void keyUp(String key) {
    combinationKeys.remove(key.toUpperCase());
    count = 0;
  }

  void checkCombination() {
    if (combinationKeys.contains('S') &&
        combinationKeys.contains('T') &&
        combinationKeys.contains('BACK')) {
      timerInitial();
    } else if (combinationKeys.contains('S') &&
        combinationKeys.contains('P') &&
        combinationKeys.contains('BACK')) {
      timer?.cancel();
      timer = null;
      combinationKeys.clear();
      print(">>> cancell");
    }
  }

  @override
  void initState() {
    KeyboardEvent.init().then((value) {
      keyboardEvent.startListening((keyEvent) {
        if (keyEvent.isKeyDown) {
          keyDown(keyEvent.vkName!);
        } else {
          keyUp(keyEvent.vkName!);
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: combinationKeys.map((e) => Text("<$e>")).toList(),
        ),
      ),
    );
  }
}
