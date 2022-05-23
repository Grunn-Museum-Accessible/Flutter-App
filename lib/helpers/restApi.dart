import 'package:app/libs/PositioningVisualizer/positioningVisualiser.dart';

class RestApi {
  final String host;
  final num port;

  RestApi({required this.host, this.port = 80});

  Future<List<Map<String, String>>> getSoundFiles() async {
    return [
      {
        'name': 'Keys of moon white petals',
        'path': '/assets/audio/keys-of-moon-white-petals.mp3',
      },
      {
        'name': 'Rick Astly',
        'path': '/assets/audio/keys-of-moon-white-petals.mp3',
      },
    ];
  }

  Future updateRoute(Route newRoute) async {
    return;
  }
}
