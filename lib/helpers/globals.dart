import 'package:app/helpers/audioManager.dart';
import 'package:app/pages/audioManagerTest.dart';
import 'package:app/pages/home.dart';
import 'package:app/pages/routesTest.dart';

final Map<String, Map<String, dynamic>> globalsPages = {
  'home': {
    'route': (Map<String, dynamic> routes) => HomeScreen(pages: routes),
  },
  'audio manager test': {
    'route': (Map<String, dynamic> routes) =>
        AudioManagerTestScreen(pages: routes),
  },
  'Routes Beheren': {
    'role': 'admin',
    'children': {
      'nieuwe maken': {
        'route': (Map<String, dynamic> routes) =>
            RoutesTestScreen(pages: routes)
      },
      'Route Bewerken': {
        'route': (Map<String, dynamic> routes) =>
            RoutesTestScreen(pages: routes)
      },
    }
  },
  'home2': {
    'route': (Map<String, dynamic> routes) => RoutesTestScreen(pages: routes),
  },
  'home3': {
    'route': (Map<String, dynamic> routes) => RoutesTestScreen(pages: routes),
  },
  'home4hidden': {
    'hide': true,
    'route': (Map<String, dynamic> routes) => RoutesTestScreen(pages: routes),
  }
};

AudioManager audioManager = AudioManager();
