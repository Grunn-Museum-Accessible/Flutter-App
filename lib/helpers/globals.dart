import 'package:app/helpers/restApi.dart';
import 'package:app/helpers/vibration.dart';
import 'package:app/libs/surround_sound/src/AngleConverter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

final AudioPlayer audioPlayer = AudioPlayer();
final AngleConverter angleConverter = AngleConverter();
final InAppLocalhostServer localhostServer = InAppLocalhostServer();
final RestClient restAPI = RestClient();

final Vibration vibration = Vibration();

Future<String> loadAsset(String assetPath) async {
  return rootBundle.loadString(assetPath);
}

String makeValidIMageUrl(String oldUrl) {
  if (oldUrl.startsWith('/')) {
    return RestClient.baseUrl + oldUrl;
  }
  return oldUrl;
}
