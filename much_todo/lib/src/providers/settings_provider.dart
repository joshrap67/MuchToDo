import 'package:flutter/material.dart';

import 'package:much_todo/src/services/settings_service.dart';
import 'package:much_todo/src/utils/enums.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider(this._settingsService);

  final SettingsService _settingsService;

  late ThemeMode _themeMode;
  late RoomSortOption _roomSort;
  late SortDirection _roomSortDirection;

  ThemeMode get themeMode => _themeMode;

  RoomSortOption get roomSort => _roomSort;

  SortDirection get roomSortDirection => _roomSortDirection;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    _roomSort = await _settingsService.roomSort();
    _roomSortDirection = await _settingsService.roomSortDirection();
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null || newThemeMode == _themeMode) {
      return;
    }

    _themeMode = newThemeMode;
    notifyListeners();

    await _settingsService.updateThemeMode(newThemeMode);
  }

  Future<void> updateRoomSort(RoomSortOption roomSort, SortDirection sortDirection) async {
    _roomSort = roomSort;
    _roomSortDirection = sortDirection;
    notifyListeners();

    await _settingsService.updateRoomSort(roomSort);
    await _settingsService.updateRoomSortDirection(sortDirection);
  }
}
