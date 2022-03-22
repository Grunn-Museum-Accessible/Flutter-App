import 'package:app/helpers/globals.dart';
import 'package:app/helpers/routeGenerator.dart';
import 'package:app/libs/theme.dart';
import 'package:app/pages/home.dart';
import 'package:app/pages/routesTest.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);




  @override
  Widget build(BuildContext context) {
    dynamic routes = generateRoutesMap(GLOBALS_PAGES);
    print(routes);
    
    return MaterialApp(
      title: 'Groninger museum slechtzienden tour companion app',
      theme: ThemeData(
          colorScheme: PrimaryTheme.lightColorScheme,
          textTheme: PrimaryTheme.textThemeFonts,
      ),
      routes: routes,
      initialRoute: '/home',
    );
  }
}

