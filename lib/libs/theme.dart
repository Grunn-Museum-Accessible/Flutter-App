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

  static const TextTheme textThemeFonts = TextTheme(
    headlineLarge: TextStyle(fontFamily: 'Eurostile'),
    headlineMedium: TextStyle(fontFamily: 'Eurostile'),
    headlineSmall: TextStyle(fontFamily: 'Eurostile'),
    bodyLarge: TextStyle(fontFamily: 'NueuHaasUnica'),
    bodyMedium: TextStyle(fontFamily: 'NueuHaasUnica'),
    bodySmall: TextStyle(fontFamily: 'NueuHaasUnica'),
  );
}