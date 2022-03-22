import 'package:app/pages/home.dart';
import 'package:app/pages/routesTest.dart';

final Map<String, Map<String, dynamic>> globalsPages = {
  'home': {
    'route': (Map<String, dynamic> routes) => HomeScreen(pages: routes),
  },
  'Routes Beheren': {
    'role': 'admin',
    'children': {
      'nieuwe maken': {
        'route': (Map<String, dynamic> routes) => RoutesTest(pages: routes)
      },
      'Route Bewerken': {
        'route': (Map<String, dynamic> routes) => RoutesTest(pages: routes)
      },
    }
  },
  'home2': {
    'route': (Map<String, dynamic> routes) => RoutesTest(pages: routes),
  },
  'home3': {
    'route': (Map<String, dynamic> routes) => RoutesTest(pages: routes),
  },

};
