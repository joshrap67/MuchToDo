import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/repositories/rooms/requests/create_room_request.dart';
import 'package:much_todo/src/repositories/rooms/requests/update_room_request.dart';
import 'package:much_todo/src/repositories/rooms/room_repository.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';

class RoomsService {
  static Future<void> getAllRooms(BuildContext context) async {
    try {
      context.read<RoomsProvider>().setLoading(true);
      var rooms = await RoomRepository.getAllRoomsByUser();
      if (context.mounted) {
        context.read<RoomsProvider>().setRooms(rooms);
      }
    } on Exception catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem loading rooms', context);
      }
    } finally {
      if (context.mounted) {
        context.read<RoomsProvider>().setLoading(false);
      }
    }
  }

  static Future<Room?> createRoom(BuildContext context, String name, {String? note}) async {
    Room? room;
    try {
      room = await RoomRepository.createRoom(CreateRoomRequest(name, note));
      if (context.mounted) {
        context.read<RoomsProvider>().addRoom(room);
        context.read<UserProvider>().addRoom(room);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem creating the room', context);
      }
    }
    return room!;
  }

  static Future<Room?> editRoom(BuildContext context, String id, String name, String? note) async {
    Room? room;

    try {
      await RoomRepository.updateRoom(id, UpdateRoomRequest(name, note));
      if (context.mounted) {
        room = context.read<RoomsProvider>().updateRoom(id, name, note);
        context.read<TasksProvider>().updateRoom(id, name);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem updating the room', context);
      }
    }
    return room;
  }

  static Future<bool> deleteRoom(BuildContext context, Room room) async {
    try {
      await RoomRepository.deleteRoom(room.id);
      if (context.mounted) {
        context.read<RoomsProvider>().removeRoom(room);
        context.read<TasksProvider>().removeTasksFromRoomId(room.id);
        context.read<UserProvider>().removeRoom(room);
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem deleting the room', context);
      }
      return false;
    }
  }
}
