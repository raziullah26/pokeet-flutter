import 'package:flutter/material.dart';

class PokeetColors {
  static const darkBg = Color(0xFF12362B);
  static const darkCard = Color(0xFF124D3B);
  static const darkField = Color(0xFF0E0E10);
  static const darkBorder = Color(0xFF26262B);

  static const lightBg = Color(0xFFB4BBE0);
  static const lightCard = Color(0xFFCCCCFF);
  static const lightField = Color(0xFFF2F5F4);
  static const lightBorder = Color(0xFFE1E6E4);

  static const green = Color(0xFF09A75A);
  static const onGreen = Color(0xFF04140C);
  static const redDark = Color(0xFFFF4D6D);
  static const redLight = Color(0xFFE5384F);
  static const blue = Color(0xFF3498DB);
  static const purple = Color(0xFF9B59B6);
  static const orange = Color(0xFFE67E22);
  static const teal = Color(0xFF1ABC9C);
}

class AppTheme {
  static const String _fontFamily = 'NotoSansBengali';

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: PokeetColors.darkBg,
      colorScheme: const ColorScheme.dark(
        primary: PokeetColors.green,
        onPrimary: PokeetColors.onGreen,
        secondary: PokeetColors.blue,
        error: PokeetColors.redDark,
        surface: PokeetColors.darkCard,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: _fontFamily,
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: PokeetColors.darkCard.withValues(alpha: 0.82),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
        ),
      ),
    );
  }

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: PokeetColors.lightBg,
      colorScheme: const ColorScheme.light(
        primary: PokeetColors.green,
        onPrimary: Colors.white,
        secondary: PokeetColors.blue,
        error: PokeetColors.redLight,
        surface: PokeetColors.lightCard,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        fontFamily: _fontFamily,
        bodyColor: const Color(0xFF101214),
        displayColor: const Color(0xFF101214),
      ),
      cardTheme: CardThemeData(
        color: PokeetColors.lightCard.withValues(alpha: 0.72),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.78)),
        ),
      ),
    );
  }
}
