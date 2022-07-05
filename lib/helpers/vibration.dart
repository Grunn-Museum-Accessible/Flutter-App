import 'dart:async';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class Vibration {
  bool running = false;
  Duration duration = Duration(milliseconds: 600);
  late Timer timer;

  Vibration() {
    doLoop();
  }

  dispose() {
    timer.cancel();
  }

  Future doLoop() async {
    timer = Timer(duration, () {
      if (running) {
        vibrate();
      }

      doLoop();
    });
  }

  void vibrate() {
    Vibrate.vibrate();
  }

  void setDuration(double ms) {
    duration = Duration(milliseconds: ms.toInt());
  }

  void start() {
    running = true;
  }

  void stop() {
    running = false;
  }
}
