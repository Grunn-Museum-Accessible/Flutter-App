import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class Vibration {
  String mode = 'heavy';
  late Timer timer;

  Vibration() {
    doLoop();
  }

  dispose() {
    timer.cancel();
  }

  Future doLoop() async {
    timer = Timer.periodic(Duration(milliseconds: 600), (timer) {
      //code to run on every 5 seconds
      if (running) {
        vibrate();
      }
    });
  }

  void vibrate() {
    // if (mode == 'heavy') {
    Vibrate.vibrate();

    // }
  }

  bool running = false;
  void start() {
    running = true;
  }

  void stop() {
    running = false;
  }
}
