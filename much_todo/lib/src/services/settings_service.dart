import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingsService {
  static const String darkThemeKey = 'darkThemeKey';

  Future<ThemeMode> themeMode() async {
    var prefs = await SharedPreferences.getInstance();

    var darkTheme = prefs.getBool(darkThemeKey);
    if (darkTheme == null) {
      return ThemeMode.system;
    } else if (darkTheme) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.light;
    }
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool(darkThemeKey, theme == ThemeMode.dark);
  }
}
