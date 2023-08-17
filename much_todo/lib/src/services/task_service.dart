import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:much_todo/src/domain/person.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/tag.dart';

class TaskService {
  static Task editTask(
      BuildContext context, String id, String name, int priority, int effort, String createdBy, Room room,
      {double? estimatedCost,
      String? note,
      DateTime? completeBy,
      List<String> links = const [],
      List<Tag> tags = const [],
      List<Person> people = const [],
      List<XFile> photos = const []}) {
    // todo upload photos to cloud
    var task = Task.named(
        id: id,
        name: name.trim(),
        priority: priority,
        effort: effort,
        createdBy: createdBy,
        tags: tags.map((e) => e.convert()).toList(),
        estimatedCost: estimatedCost,
        completeBy: completeBy,
        inProgress: false,
        isCompleted: false,
        links: links,
        note: note,
        people: people.map((e) => e.convert()).toList(),
        room: room.convert(),
        creationDate: DateTime.now().toUtc());
    context.read<TasksProvider>().updateTask(task);
    context.read<RoomsProvider>().updateTask(task);
    context.read<UserProvider>().updateTask(task);

    return task;
  }

  static List<Task> createTasks(
      BuildContext context, String name, int priority, int effort, String createdBy, List<Room> rooms,
      {double? estimatedCost,
      String? note,
      DateTime? completeBy,
      List<String> links = const [],
      List<Tag> tags = const [],
      List<Person> people = const [],
      List<XFile> photos = const []}) {
    // todo upload photos to cloud
    // todo grab userid here instead of requiring it in method
    List<Task> createdTasks = [];
    if (rooms.isEmpty) {
      throw Exception('Room cannot be empty');
    }

    for (var room in rooms) {
      var task = Task.named(
          id: const Uuid().v4(),
          name: name.trim(),
          priority: priority,
          effort: effort,
          createdBy: createdBy,
          tags: tags.map((e) => e.convert()).toList(),
          estimatedCost: estimatedCost,
          completeBy: completeBy,
          inProgress: false,
          isCompleted: false,
          links: links,
          note: note,
          people: people.map((e) => e.convert()).toList(),
          room: room.convert(),
          creationDate: DateTime.now().toUtc());
      createdTasks.add(task);
    }
    context.read<TasksProvider>().addTasks(createdTasks);
    context.read<RoomsProvider>().addTasks(createdTasks);
    context.read<UserProvider>().addTasks(createdTasks);

    return createdTasks;
  }

  static void deleteTask(BuildContext context, Task task) {
    context.read<TasksProvider>().removeTask(task);
    context.read<RoomsProvider>().removeTask(task);
    context.read<UserProvider>().removeTask(task);
  }
}
