import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/repositories/tasks/requests/create_tasks_request.dart';
import 'package:much_todo/src/repositories/tasks/requests/update_task_request.dart';
import 'package:much_todo/src/repositories/tasks/task_repository.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/tag.dart';

class TaskService {
  static Future<void> getAllTasks(BuildContext context) async {
    try {
      context.read<TasksProvider>().setLoading(true);
      var tasks = await TaskRepository.getAllTasksByUser();
      if (context.mounted) {
        context.read<TasksProvider>().setTasks(tasks);
      }
    } on Exception {
      if (context.mounted) {
        showSnackbar('There was a problem loading tasks', context);
      }
    } finally {
      if (context.mounted) {
        context.read<TasksProvider>().setLoading(false);
      }
    }
  }

  static Future<Task?> editTask(
      BuildContext context, Task originalTask, String name, int priority, int effort, Room room,
      {double? estimatedCost,
      String? note,
      DateTime? completeBy,
      List<String> links = const [],
      List<Tag> tags = const [],
      List<Contact> contacts = const [],
      List<XFile> photos = const []}) async {
    // todo pass in original

    Task? updatedTask;
    try {
      // todo upload photos to cloud
      updatedTask = await TaskRepository.updateTask(
          originalTask.id,
          UpdateTaskRequest(
            name,
            priority,
            effort,
            estimatedCost,
            tags.map((e) => e.id).toList(),
            contacts.map((e) => e.id).toList(),
            room.id,
            note,
            links,
            [],
            completeBy,
          ));
      if (context.mounted) {
        context.read<TasksProvider>().updateTask(updatedTask);
        context.read<RoomsProvider>().updateTask(updatedTask, originalTask.room.id);
        context.read<UserProvider>().updateTask(updatedTask);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem updating the task', context);
      }
    }

    return updatedTask;
  }

  static Future<List<Task>?> createTasks(BuildContext context, String name, int priority, int effort, List<Room> rooms,
      {double? estimatedCost,
      String? note,
      DateTime? completeBy,
      List<String> links = const [],
      List<Tag> tags = const [],
      List<Contact> contacts = const [],
      List<XFile> photos = const []}) async {
    List<Task>? createdTasks;
    try {
      // todo upload photos to cloud
      createdTasks = await TaskRepository.createTasks(CreateTasksRequest(
        name,
        priority,
        effort,
        tags.map((e) => e.id).toList(),
        contacts.map((e) => e.id).toList(),
        rooms.map((e) => e.id).toList(),
        estimatedCost,
        note,
        links,
        [],
        false,
        completeBy,
      ));
      if (context.mounted) {
        context.read<TasksProvider>().addTasks(createdTasks);
        context.read<RoomsProvider>().addTasks(createdTasks);
        context.read<UserProvider>().addTasks(createdTasks);
      }
    } catch (_) {
      if (context.mounted) {
        showSnackbar('There was a problem creating tasks', context);
      }
    }

    return createdTasks;
  }

  static Future<bool> deleteTask(BuildContext context, Task task) async {
    try {
      await TaskRepository.deleteTask(task.id);
      if (context.mounted) {
        context.read<TasksProvider>().removeTask(task);
        context.read<RoomsProvider>().removeTask(task);
        context.read<UserProvider>().removeTask(task);
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem deleting the task', context);
      }
      return false;
    }
  }
}
