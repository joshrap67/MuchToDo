import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/repositories/rooms/requests/create_room_request.dart';
import 'package:much_todo/src/repositories/rooms/requests/update_room_request.dart';
import 'package:much_todo/src/repositories/rooms/room_repository.dart';
import 'package:much_todo/src/utils/result.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';

class RoomsService {
  static Future<void> getAllRoomsBlindSend(BuildContext context) async {
    try {
      context.read<RoomsProvider>().setLoading(true);
      var rooms = await RoomRepository.getAllRoomsByUser();
      if (context.mounted) {
        context.read<RoomsProvider>().setRooms(rooms);
      }
    } on Exception {
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
    } catch (e) {
      result.setErrorMessage('There was a problem creating the room');
    }
    return result;
  }

  static Future<Result<void>> editRoom(BuildContext context, String id, String name, String? note) async {
    var result = Result<void>();

    try {
      await RoomRepository.updateRoom(id, UpdateRoomRequest(name.trim(), note?.trim()));
      if (context.mounted) {
        context.read<RoomsProvider>().updateRoom(id, name, note);
        context.read<TasksProvider>().updateRoom(id, name);
      }
    } catch (e) {
      result.setErrorMessage('There was a problem updating the room');
    }
    return result;
  }

  static Future<Result<void>> deleteRoom(BuildContext context, Room room) async {
    var result = Result<void>();
    try {
      await RoomRepository.deleteRoom(room.id);
      if (context.mounted) {
        context.read<RoomsProvider>().removeRoom(room);
        context.read<TasksProvider>().removeTasksFromRoomId(room.id);
        context.read<UserProvider>().removeRoom(room);
      }
    } catch (e) {
      result.setErrorMessage('There was a problem deleting the room');
    }
    return result;
  }
}
