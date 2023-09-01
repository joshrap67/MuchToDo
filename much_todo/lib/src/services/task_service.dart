import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/repositories/tasks/requests/complete_task_request.dart';
import 'package:much_todo/src/repositories/tasks/requests/create_tasks_request.dart';
import 'package:much_todo/src/repositories/tasks/requests/set_task_photos_request.dart';
import 'package:much_todo/src/repositories/tasks/requests/set_task_progress_request.dart';
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
      List<Contact> contacts = const []}) async {
    Task? updatedTask;
    try {
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

  static Future<Task?> createTask(BuildContext context, String name, int priority, int effort, Room room,
      {double? estimatedCost,
      String? note,
      DateTime? completeBy,
      List<String> links = const [],
      List<Tag> tags = const [],
      List<Contact> contacts = const []}) async {
    Task? createdTask;
    try {
      createdTask = await TaskRepository.createTask(CreateTasksRequest(
        name,
        priority,
        effort,
        tags.map((e) => e.id).toList(),
        contacts.map((e) => e.id).toList(),
        room.id,
        estimatedCost,
        note,
        links,
        false,
        completeBy,
      ));
      if (context.mounted) {
        context.read<TasksProvider>().addTask(createdTask);
        context.read<RoomsProvider>().addTask(createdTask);
        context.read<UserProvider>().addTask(createdTask);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem creating the task', context);
      }
    }

    return createdTask;
  }

  static Future<Task?> setTaskPhotos(
      BuildContext context, String taskId, List<String> photosToUpload, List<String> deletedPhotos) async {
    Task? task;
    try {
      task = await TaskRepository.setTaskPhotos(
        taskId,
        SetTaskPhotosRequest(photosToUpload: photosToUpload, deletedPhotos: deletedPhotos),
      );
      if (context.mounted) {
        context.read<TasksProvider>().updateTask(task);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem creating tasks', context);
      }
    }
    return task;
  }

  static Future<void> setTaskProgress(BuildContext context, String taskId, bool inProgress) async {
    try {
      // blind send
      context.read<TasksProvider>().updateTaskProgress(taskId, inProgress);
      await TaskRepository.setTaskProgress(
        taskId,
        SetTaskProgressRequest(inProgress: inProgress),
      );
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem setting the task\'s progress', context);
      }
    }
  }

  static Future<void> completeTask(BuildContext context, Task task, DateTime completionDate) async {
    try {
      await TaskRepository.completeTask(task.id, CompleteTaskRequest(completeDate: completionDate));
      if (context.mounted) {
        context.read<TasksProvider>().removeTask(task);
        context.read<RoomsProvider>().removeTask(task);
        context.read<UserProvider>().removeTask(task);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem completing the task', context);
      }
    }
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
