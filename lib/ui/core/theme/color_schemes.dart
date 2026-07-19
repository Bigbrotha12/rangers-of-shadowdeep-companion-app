import 'package:flutter/material.dart';

class ColorSchemes {
  ColorSchemes._();

  static const String _rangersBlue = '#1a365d';
  static const String _rangersRed = '#b04f4f';
  static const String _rangersGold = '#d69e2e';

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: _hexToColor(_rangersBlue),
        secondary: _hexToColor(_rangersRed),
        tertiary: _hexToColor(_rangersGold),
        surface: _hexToColor('#f8f9fa'),
        onSecondary: Colors.white,
        onSurface: _hexToColor('#1a1a1a'),
        error: _hexToColor('#b34d4d'),
      ),
      scaffoldBackgroundColor: _hexToColor('#f8f9fa'),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: _hexToColor(_rangersBlue),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: Colors.white,
        selectedItemColor: _hexToColor(_rangersBlue),
        unselectedItemColor: _hexToColor('#4b5563'),
        type: BottomNavigationBarType.fixed,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: _hexToColor(_rangersRed),
        unselectedLabelColor: _hexToColor('#4b5563'),
        indicatorColor: _hexToColor(_rangersRed),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _hexToColor('#ffffff'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _hexToColor(_rangersBlue), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _hexToColor(_rangersRed)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _hexToColor(_rangersRed), width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _hexToColor(_rangersBlue),
        secondary: _hexToColor(_rangersRed),
        tertiary: _hexToColor(_rangersGold),
        surface: _hexToColor('#1a1a2e'),
        onSecondary: Colors.white,
        onSurface: _hexToColor('#e8e8e8'),
        error: _hexToColor('#ef4444'),
      ),
      scaffoldBackgroundColor: _hexToColor('#0f0f1a'),
      cardColor: _hexToColor('#1a1a2e'),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _hexToColor('#000000'),
        shadowColor: _hexToColor(_rangersBlue).withValues(alpha: 0.3),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: _hexToColor('#0f0f1a'),
        foregroundColor: _hexToColor('#e8e8e8'),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        elevation: 0,
        backgroundColor: _hexToColor('#1a1a2e'),
        selectedItemColor: _hexToColor(_rangersBlue),
        unselectedItemColor: _hexToColor('#9ca3af'),
        type: BottomNavigationBarType.fixed,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: _hexToColor(_rangersRed),
        unselectedLabelColor: _hexToColor('#9ca3af'),
        indicatorColor: _hexToColor(_rangersRed),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _hexToColor('#16162a'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _hexToColor(_rangersBlue), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _hexToColor(_rangersRed)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _hexToColor(_rangersRed), width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          backgroundColor: _hexToColor(_rangersBlue),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _hexToColor(_rangersBlue),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      iconTheme: IconThemeData(
        color: _hexToColor('#8b8b99'),
      ),
    );
  }
}

Color _hexToColor(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final value = int.parse(cleaned, radix: 16);
  return Color(0xFF000000 | value);
}
