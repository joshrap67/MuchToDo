import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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
import 'package:much_todo/src/utils/result.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/tag.dart';

class TaskService {
  static Future<void> getAllTasksBlindSend(BuildContext context) async {
    try {
      context.read<TasksProvider>().setLoading(true);
      var tasks = await TaskRepository.getAllTasksByUser();
      if (context.mounted) {
        context.read<TasksProvider>().setTasks(tasks);
      }
    } on Exception catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      if (context.mounted) {
        showSnackbar('There was a problem loading tasks', context);
      }
    } finally {
      if (context.mounted) {
        context.read<TasksProvider>().setLoading(false);
      }
    }
  }

  static Future<Result<Task>> createTask(BuildContext context, String name, int priority, int effort, Room room,
      {double? estimatedCost,
      String? note,
      DateTime? completeBy,
      List<String> links = const [],
      List<Tag> tags = const [],
      List<Contact> contacts = const []}) async {
    var result = Result<Task>();
    try {
      var createdTask = await TaskRepository.createTask(CreateTasksRequest(
        name.trim(),
        priority,
        effort,
        tags.map((e) => e.id).toList(),
        contacts.map((e) => e.id).toList(),
        room.id,
        estimatedCost,
        note?.trim(),
        links,
        false,
        completeBy,
      ));
      result.setData(createdTask);
      if (context.mounted) {
        context.read<TasksProvider>().addTask(createdTask);
        context.read<RoomsProvider>().addTask(createdTask);
        context.read<UserProvider>().addTask(createdTask);
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      result.setErrorMessage('There was a problem creating the task');
    }

    return result;
  }

  static Future<Result<Task>> editTask(
      BuildContext context, Task originalTask, String name, int priority, int effort, Room room,
      {double? estimatedCost,
      String? note,
      DateTime? completeBy,
      List<String> links = const [],
      List<Tag> tags = const [],
      List<Contact> contacts = const []}) async {
    var result = Result<Task>();
    try {
      var updatedTask = await TaskRepository.updateTask(
        originalTask.id,
        UpdateTaskRequest(
          name.trim(),
          priority,
          effort,
          estimatedCost,
          tags.map((e) => e.id).toList(),
          contacts.map((e) => e.id).toList(),
          room.id,
          note?.trim(),
          links,
          completeBy,
        ),
      );
      result.setData(updatedTask);
      if (context.mounted) {
        context.read<TasksProvider>().updateTask(updatedTask);
        context.read<RoomsProvider>().updateTask(updatedTask, originalTask.room.id);
        context.read<UserProvider>().updateTask(updatedTask);
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      result.setErrorMessage('There was a problem updating the task');
    }

    return result;
  }

  static Future<Result<Task>> setTaskPhotos(
      BuildContext context, String taskId, List<String> photosToUpload, List<String> deletedPhotos) async {
    var result = Result<Task>();
    try {
      var task = await TaskRepository.setTaskPhotos(
        taskId,
        SetTaskPhotosRequest(photosToUpload: photosToUpload, deletedPhotos: deletedPhotos),
      );
      result.setData(task);
      if (context.mounted) {
        context.read<TasksProvider>().updateTask(task);
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      result.setErrorMessage('There was a problem setting the task photos');
    }
    return result;
  }

  static Future<void> setTaskProgressBlindSend(BuildContext context, String taskId, bool inProgress) async {
    try {
      // blind send
      context.read<TasksProvider>().updateTaskProgress(taskId, inProgress);
      await TaskRepository.setTaskProgress(
        taskId,
        SetTaskProgressRequest(inProgress: inProgress),
      );
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      if (context.mounted) {
        showSnackbar('There was a problem setting the task\'s progress', context);
      }
    }
  }

  static Future<Result<void>> completeTask(BuildContext context, Task task, DateTime completionDate,
      {bool notifyOnFailure = false}) async {
    var result = Result();
    try {
      await TaskRepository.completeTask(task.id, CompleteTaskRequest(completeDate: completionDate));
      if (context.mounted) {
        context.read<TasksProvider>().removeTask(task);
        context.read<RoomsProvider>().removeTask(task);
        context.read<UserProvider>().removeTask(task);
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      result.setErrorMessage('There was a problem completing the task');
      if (context.mounted && notifyOnFailure) {
        // if method was used in a blind send, do this to get the correct data back to the ui
        context.read<TasksProvider>().notify();
      }
    }
    return result;
  }

  static Future<Result<void>> deleteTask(BuildContext context, Task task, {bool notifyOnFailure = false}) async {
    var result = Result();
    try {
      await TaskRepository.deleteTask(task.id);
      if (context.mounted) {
        context.read<TasksProvider>().removeTask(task);
        context.read<RoomsProvider>().removeTask(task);
        context.read<UserProvider>().removeTask(task);
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      result.setErrorMessage('There was a problem deleting the task');
      if (context.mounted && notifyOnFailure) {
        // if method was used in a blind send, do this to get the correct data back to the ui
        context.read<TasksProvider>().notify();
      }
    }

    return result;
  }
}
