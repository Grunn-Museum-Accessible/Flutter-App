import 'package:flutter/material.dart';

class Theme {
  static ColorTheme dark = ColorTheme(
    logo: Colors.white,
    text: Colors.white,
    background: Color.fromARGB(255, 38, 38, 38),
  );

  static ColorTheme light = ColorTheme(
    logo: Color.fromARGB(255, 38, 38, 38),
    text: Colors.black,
    background: Colors.white,
  );
}

class ColorTheme {
  Color logo;
  Color text;
  Color background;

  ColorTheme({
    required this.logo,
    required this.text,
    required this.background,
  });
}
