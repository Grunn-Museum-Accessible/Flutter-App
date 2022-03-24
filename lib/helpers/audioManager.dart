import 'package:audioplayers/audioplayers.dart';

/// A class to handle the playing of music
///
/// this class handles the playing of music saved as a asset
/// it also gives you the option to lower the sound of playing
/// audio when other sounds are playing in this app
///
/// you should only have a single instance of this class used globaly
class AudioManager {
  late AudioCache cache;

  // source,  lower volume
  Map<String, AudioPlayer> playing = {};
  Map<String, bool> lowerVol = {};

  AudioManager() {
    cache = AudioCache(prefix: 'assets/audio/');
  }

  /// add a audio stream to the cache
  ///
  /// store a asset in the cache so it can be playyed.
  /// if lowerVol is set to true the volume of this audio source wil lower when
  /// different audio sources start playing
  void addStream(String audioSource, bool lowerVol) {
    cache.load(audioSource);
    if (this.lowerVol.containsKey(audioSource)) {
      this.lowerVol[audioSource] = lowerVol;
    } else {
      this.lowerVol.addAll({audioSource: lowerVol});
    }
  }

  /// this function is to be used to check if the passed source is being played
  bool isPlaying(String audioSource) {
    return playing.containsKey(audioSource);
  }

  /// Stop playing the audio stream of source passed through
  void stopStream(String audioSource) {
    playing[audioSource]?.stop();
  }

  /// stop playing all audio streams currently playing
  void stopAllStreams() {
    playing.forEach((source, player) {
      player.stop();
    });

    playing.clear();
  }

  /// start playing a already added stream.
  ///
  /// if the stream is not added it will still play but you wont have
  /// the lowering volume feature for this audio source
  void playStream(String audioSource) async {
    // check if currently playing. if it is playing restart the stream
    if (isPlaying(audioSource)) {
      playing[audioSource]!.seek(Duration.zero);

      return;
    }

    // create a new audio player
    AudioPlayer player = await cache.play(audioSource);
    playing.addAll({audioSource: player});

    // lower volume of all other playing sources that have the option enabled
    // wont lower volume of passed source
    lowerVol.forEach((stream, lowervol) {
      if (stream != audioSource) {
        if (lowervol) {
          playing[stream]?.setVolume(0.2);
        }
      }
    });

    // setup callback to remove from player list and restore the volume of
    // sources if only one other source is playing
    player.onPlayerCompletion.listen((event) {
      playing.remove(audioSource);

      if (playing.length <= 1) {
        playing.forEach((stream, player) {
          player.setVolume(1);
        });
      }
    });
  }
}
