import 'package:flutter/material.dart';

class PrimaryTheme {
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFFFFFFFF),
    onPrimary: Color(0xff000000),
    secondary: Color(0xFF1E1E1E),
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFF4536AA),
    onError: Color(0xFFFFFFFF),
    background: Color(0xFFFFFFFF),
    onBackground: Color(0xff000000),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xff000000),
  );

  static TextTheme textThemeFonts = TextTheme(
    headline1: TextStyle(
      color: lightColorScheme.onPrimary,
      fontFamily: 'Eurostile',
      fontSize: 28
    ),
    headline2: TextStyle(
      color: lightColorScheme.onPrimary,
      fontFamily: 'Eurostile',
      fontSize: 26
    ),
    headline3: TextStyle(
      color: lightColorScheme.onPrimary,
      fontFamily: 'Eurostile',
      fontSize: 22
    ),
    headline4: TextStyle(
      color: lightColorScheme.onPrimary,
      fontFamily: 'Eurostile',
      fontSize: 20
    ),
    headline5: TextStyle(
      color: lightColorScheme.onPrimary,
      fontFamily: 'Eurostile',
      fontSize: 16
    ),
    headline6: TextStyle(
      color: lightColorScheme.onPrimary,
      fontFamily: 'Eurostile',
      fontSize: 14
    ),
    bodyText1: TextStyle(
      color: lightColorScheme.onPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.5
    ),
    bodyText2: TextStyle(
      color: lightColorScheme.onPrimary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 1.5
    ),
    subtitle1: TextStyle(
      color: lightColorScheme.onPrimary,
      fontSize: 12,
      fontWeight: FontWeight.w400
    ),
    subtitle2: TextStyle(
      color: lightColorScheme.secondary,
      fontSize: 12,
      fontWeight: FontWeight.w400
    )
  );
}
