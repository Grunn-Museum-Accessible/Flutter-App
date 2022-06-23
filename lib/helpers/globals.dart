import 'package:app/helpers/audioManager.dart';
import 'package:app/helpers/restApi.dart';
import 'package:app/libs/surround_sound/src/AngleConverter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

final AudioManager audioManager = AudioManager();
final AngleConverter angleConverter = AngleConverter();
final InAppLocalhostServer localhostServer = InAppLocalhostServer();
final RestApi restAPI = RestApi(host: '192.168.1.53');

Future<String> loadAsset(String assetPath) async {
  return rootBundle.loadString(assetPath);
}
