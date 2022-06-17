import 'package:app/libs/theme.dart';
import 'package:app/pages/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Groninger museum slechtzienden tour companion app',
      home: HomeScreen(),
    );
  }
}
