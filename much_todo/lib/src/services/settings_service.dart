import 'package:flutter/material.dart';
import 'package:much_todo/src/utils/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String darkThemeKey = 'darkThemeKey';
  static const String roomSortKey = 'roomSortKey';
  static const String roomSortDirectionKey = 'roomSortDirectionKey';

  Future<ThemeMode> themeMode() async {
    var prefs = await SharedPreferences.getInstance();

    var darkTheme = prefs.getBool(darkThemeKey);
    if (darkTheme == null) {
      return ThemeMode.light;
    } else if (darkTheme) {
      return ThemeMode.dark;
    } else {
      return ThemeMode.light;
    }
  }

  Future<RoomSortOption> roomSort() async {
    var prefs = await SharedPreferences.getInstance();

    var roomSort = prefs.getInt(roomSortKey) ?? RoomSortOption.name.value;
    return RoomSortOption.values[roomSort];
  }

  Future<void> updateRoomSort(RoomSortOption roomSort) async {
    var prefs = await SharedPreferences.getInstance();

    await prefs.setInt(roomSortKey, roomSort.value);
  }

  Future<SortDirection> roomSortDirection() async {
    var prefs = await SharedPreferences.getInstance();

    var sortDirection = prefs.getInt(roomSortDirectionKey) ?? SortDirection.ascending.value;
    return SortDirection.values[sortDirection];
  }

  Future<void> updateRoomSortDirection(SortDirection sortDirection) async {
    var prefs = await SharedPreferences.getInstance();

    await prefs.setInt(roomSortDirectionKey, sortDirection.value);
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool(darkThemeKey, theme == ThemeMode.dark);
  }
}
