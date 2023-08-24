import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';

class RoomsService {
  static Future<Room> createRoom(BuildContext context, String name, {String? note}) async {
    Room? room;
    await Future.delayed(const Duration(seconds: 2), () {
      room = Room(const Uuid().v4(), name.trim(), note == null || note.isEmpty ? null : note, []);
      context.read<RoomsProvider>().addRoom(room!);
    });
    return room!;
  }

  static Future<void> deleteRoom(BuildContext context, Room room) async {
    await Future.delayed(const Duration(seconds: 2), () {
      context.read<RoomsProvider>().removeRoom(room);
      context.read<TasksProvider>().removeTasksFromRoomId(room.id);
    });
  }

  static Future<Room?> editRoom(BuildContext context, String id, String name, String? note) async {
    Room? room;
    await Future.delayed(const Duration(seconds: 2), () {
      room = context.read<RoomsProvider>().updateRoom(id, name, note);
      context.read<TasksProvider>().updateRoom(id, name);
    });
    return room;
  }

  static Future<List<Task>> getCompletedTasks(BuildContext context, Room room) async {
    List<Task> tasks = [];
    await Future.delayed(const Duration(seconds: 2), () {
      // todo api call
      tasks = List.generate(10, (i) {
        return Task.named(
            id: const Uuid().v4(),
            name: 'Completed Task ${i + 1}',
            priority: (i % 5) + 1,
            effort: (i % 3) + 1,
            createdBy: 'createdBy',
            room: room.convert(),
            isCompleted: true,
            creationDate: DateTime.now());
      });
    });
    return tasks;
  }
}
