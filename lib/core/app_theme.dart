
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF142B4A);
  static const Color secondary = Color(0xFF24476D);
  static const Color background = Color(0xFFF4F7FB);
  static const Color income = Color(0xFF16A879);
  static const Color expense = Color(0xFFE45B64);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    fontFamily: 'Roboto',
  );
}
