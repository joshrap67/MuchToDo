import 'package:flutter/material.dart';

import '../services/settings_service.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider(this._settingsService);

  final SettingsService _settingsService; // todo i don't think this needs to be here, it can be static

  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;
    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;
    notifyListeners();

    await _settingsService.updateThemeMode(newThemeMode);
  }
}
