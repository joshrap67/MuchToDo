import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service that stores and retrieves user settings.
///
/// By default, this class does not persist user settings. If you'd like to
/// persist the user settings locally, use the shared_preferences package. If
/// you'd like to store settings on a web server, use the http package.
class SettingsService {
  /// Loads the User's preferred ThemeMode from local or remote storage.
  static const String darkThemeKey = 'darkThemeKey';
  static const String colorKey = 'colorKey';

  Future<ThemeMode> themeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final bool? darkTheme = prefs.getBool(darkThemeKey);
    if (darkTheme == null) {
      return ThemeMode.system;
    } else if (darkTheme) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.light;
    }
  }

  Future<Color> color() async {
	  final SharedPreferences prefs = await SharedPreferences.getInstance();

	  final int? color = prefs.getInt(colorKey);
	  if (color == null) {
		  return const Color(0xFF00647d);
	  } else {
		  return Color(color);
	  }
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(darkThemeKey, theme == ThemeMode.dark);
  }

  Future<void> updateColor(Color color) async {
	  final SharedPreferences prefs = await SharedPreferences.getInstance();
	  await prefs.setInt(colorKey, color.value);
  }
}
