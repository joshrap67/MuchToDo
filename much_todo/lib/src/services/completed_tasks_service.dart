import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/completed_task.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/repositories/completed_tasks/completed_task_repository.dart';
import 'package:much_todo/src/utils/utils.dart';

class CompletedTaskService {
  static Future<List<CompletedTask>> getCompletedTasksByRoom(BuildContext context, Room room) async {
    List<CompletedTask> tasks = [];
    try {
      tasks = await CompletedTaskRepository.getAllCompletedTasksByRoom(room.id);
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem getting completed tasks for this room', context);
      }
    }
    return tasks;
  }

  static Future<List<CompletedTask>> getAllCompletedTasks(BuildContext context) async {
	  List<CompletedTask> tasks = [];
	  try {
		  tasks = await CompletedTaskRepository.getAllCompletedTasksByUser();
	  } catch (e) {
		  if (context.mounted) {
			  showSnackbar('There was a problem getting completed tasks', context);
		  }
	  }
	  return tasks;
  }

  static Future<bool> deleteCompletedTask(BuildContext context, CompletedTask task) async {
    try {
      await CompletedTaskRepository.deleteCompletedTask(task.id);
      return true;
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem deleting the completed task', context);
      }
      return false;
    }
  }
}
