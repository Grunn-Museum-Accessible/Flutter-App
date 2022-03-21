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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Groninger museum slechtzienden tour companion app',
      theme: ThemeData(
          colorScheme: PrimaryTheme.lightColorScheme,
          textTheme: PrimaryTheme.textThemeFonts,
      ),
      home: Scaffold(
        appBar: AppBar(
          actions: const <Widget>[
            
          ],
        ),
      ),
    );
  }
}
