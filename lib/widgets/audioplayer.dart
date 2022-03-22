import 'package:app/helpers/globals.dart';
import 'package:flutter/material.dart';

class AudioController extends StatelessWidget {
  final String audioSource;
  final Widget child;

  AudioController(
      {required this.audioSource,
      required this.child,
      Key? key,
      bool lowerVolume = false})
      : super(key: key) {
    audioManager.addStream(audioSource, lowerVolume);
  }

  void _play() {
    audioManager.playStream(audioSource);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        onPressed: _play,
        child: child,
      ),
    );
  }
}
