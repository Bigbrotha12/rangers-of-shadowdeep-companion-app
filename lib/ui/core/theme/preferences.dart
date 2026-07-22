import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeModePref { system, light, dark }

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw StateError('SharedPreferences not initialized');
});

final themeModeNotifier =
    StateNotifierProvider<ThemeModeNotifier, ThemeModePref>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeModePref> {
  ThemeModeNotifier(SharedPreferences prefs)
    : _prefs = prefs,
      super(_themeModeFromPrefs(prefs));

  final SharedPreferences _prefs;

  static ThemeModePref _themeModeFromPrefs(SharedPreferences prefs) {
    final value = prefs.getDouble('theme_mode');
    if (value != null) {
      if (value == 0) return ThemeModePref.system;
      if (value == 1) return ThemeModePref.light;
      if (value == 2) return ThemeModePref.dark;
    }
    return ThemeModePref.system;
  }

  void update(ThemeModePref mode) {
    if (state == mode) return;
    state = mode;
    unawaited(_prefs.setDouble('theme_mode', _encodeThemeMode(mode)));
  }

  double _encodeThemeMode(ThemeModePref mode) {
    switch (mode) {
      case ThemeModePref.system: return 0.0;
      case ThemeModePref.light: return 1.0;
      case ThemeModePref.dark: return 2.0;
    }
  }
}


