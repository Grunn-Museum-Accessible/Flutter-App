import 'dart:js';

import 'package:flutter/material.dart';

// libs
import 'libs/theme.dart';

// pages
import './pages/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

   final Map<String, Map<String, dynamic>> pages = const {
    "home": {
      "route": HomeScreen,
    },
    "Routes Beheren": {
      "role": "admin",
      "children": {
        "nieuwe maken": {
          "route": Null
        },
        "Route Bewerken": {
          "route": Null
        }
      }
    }
  };

  Map<String, Widget Function(BuildContext)> genRoutesMap() {
    Map<String, Widget Function(BuildContext)> routesMap = {};

    pages.forEach((key, value) {
      if (pages[key]!.containsKey('route')) {
        // has a route
        Iterable<MapEntry<String, Widget Function(BuildContext)>> entries = <String, Widget Function(BuildContext)>{
          key.toString(): (context) => pages[key]!['route']()
        }.entries;
        routesMap.addEntries(entries);
      } 
    });

    return routesMap;
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Groninger museum slechtzienden tour companion app',
      theme: ThemeData(
          colorScheme: PrimaryTheme.lightColorScheme,
          textTheme: PrimaryTheme.textThemeFonts,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreen(pages: pages)
      }
    );
  }
}

