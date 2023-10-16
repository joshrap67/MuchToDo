import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/providers/settings_provider.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/repositories/rooms/requests/create_room_request.dart';
import 'package:much_todo/src/repositories/rooms/requests/set_room_task_sort_request.dart';
import 'package:much_todo/src/repositories/rooms/requests/update_room_request.dart';
import 'package:much_todo/src/repositories/rooms/room_repository.dart';
import 'package:much_todo/src/utils/result.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

class RoomsService {
  static Future<void> getAllRoomsBlindSend(BuildContext context) async {
    try {
      context.read<RoomsProvider>().setLoading(true);
      var rooms = await RoomRepository.getAllRoomsByUser();
      if (context.mounted) {
        var sort = context.read<SettingsProvider>().roomSort;
        var sortDirection = context.read<SettingsProvider>().roomSortDirection;
        context.read<RoomsProvider>().setRooms(rooms);
        context.read<RoomsProvider>().setSort(sort, sortDirection);
      }
    } on Exception catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
      if (context.mounted) {
        showSnackbar('There was a problem loading rooms', context);
      }
    } finally {
      if (context.mounted) {
        context.read<RoomsProvider>().setLoading(false);
      }
    }
  }

  static Future<Result<Room>> createRoom(BuildContext context, String name, {String? note}) async {
    var result = Result<Room>();
    try {
      var room = await RoomRepository.createRoom(CreateRoomRequest(name.trim(), note?.trim()));
      result.setData(room);
      if (context.mounted) {
        context.read<RoomsProvider>().addRoom(room);
        context.read<UserProvider>().addRoom(room);
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      result.setErrorMessage('There was a problem creating the room');
    }
    return result;
  }

  static Future<Result<void>> editRoom(BuildContext context, String id, String name, String? note) async {
    var result = Result();

    try {
      await RoomRepository.updateRoom(id, UpdateRoomRequest(name.trim(), note?.trim()));
      if (context.mounted) {
        context.read<RoomsProvider>().updateRoom(id, name, note);
        context.read<TasksProvider>().updateRoom(id, name);
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      result.setErrorMessage('There was a problem updating the room');
    }
    return result;
  }

  static Future<Result<void>> setFavorite(BuildContext context, String id, bool isFavorite) async {
    var result = Result();

    try {
      // blind send
      context.read<RoomsProvider>().setRoomIsFavorite(id, isFavorite);
      if (isFavorite) {
        await RoomRepository.favoriteRoom(id);
      } else {
        await RoomRepository.unfavoriteRoom(id);
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      result.setErrorMessage('There was a problem favoriting the room');
    }
    return result;
  }

  static Future<Result<void>> setRoomTaskSort(
      BuildContext context, String id, int taskSort, int taskSortDirection) async {
    var result = Result();

    try {
      // blind send
      context.read<RoomsProvider>().setRoomTaskSort(id, taskSort, taskSortDirection);
      await RoomRepository.setTaskSort(id, SetRoomTaskSortRequest(taskSort, taskSortDirection));
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      result.setErrorMessage('There was a problem setting the task sort');
    }
    return result;
  }

  static Future<Result<void>> deleteRoom(BuildContext context, Room room) async {
    var result = Result();
    try {
      await RoomRepository.deleteRoom(room.id);
      if (context.mounted) {
        context.read<RoomsProvider>().removeRoom(room);
        context.read<TasksProvider>().removeTasksFromRoomId(room.id);
        context.read<UserProvider>().removeRoom(room);
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      result.setErrorMessage('There was a problem deleting the room');
    }
    return result;
  }
}
