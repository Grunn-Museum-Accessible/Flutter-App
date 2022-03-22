import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  late AudioCache cache;

  // source,  lower volume
  Map<String, AudioPlayer> playing = {};
  Map<String, bool> lowerVol = {};

  AudioManager() {
    cache = AudioCache(prefix: 'assets/audio/');
  }

  void addStream(String audioSource, bool lowerVol) {
    cache.load(audioSource);
    if (this.lowerVol.containsKey(audioSource)) {
      this.lowerVol[audioSource] = lowerVol;
    } else {
      this.lowerVol.addAll({audioSource: lowerVol});
    }
  }

  bool isPlaying(String audioSource) {
    return playing.containsKey(audioSource);
  }

  void stopStream(String audioSource) {
    playing[audioSource]?.stop();
  }

  void stopAllStreams() {
    playing.forEach((source, player) {
      player.stop();
    });
  }

  void playStream(String audioSource) async {
    AudioPlayer player = await cache.play(audioSource);
    playing.addAll({audioSource: player});

    lowerVol.forEach((stream, lowervol) {
      if (stream != audioSource || playing.entries.length <= 2) {
        if (lowervol) {
          playing[stream]?.setVolume(0.2);
        }
      }
    });

    player.onPlayerCompletion.listen((event) {
      playing.remove(audioSource);
      if (playing.keys.length <= 1) {
        playing.forEach((stream, player) {
          player.setVolume(1);
        });
      }
    });
  }
}
