import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:much_todo/src/domain/completed_task.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/repositories/completed_tasks/completed_task_repository.dart';
import 'package:much_todo/src/repositories/completed_tasks/requests/delete_completed_tasks_request.dart';
import 'package:much_todo/src/utils/result.dart';

class CompletedTaskService {
  static Future<Result<List<CompletedTask>>> getCompletedTasksByRoom(Room room) async {
    var result = Result<List<CompletedTask>>();
    List<CompletedTask> tasks = [];
    try {
      tasks = await CompletedTaskRepository.getAllCompletedTasksByRoom(room.id);
      result.setData(tasks);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      result.setErrorMessage('There was a problem getting completed tasks for this room');
    }
    return result;
  }

  static Future<Result<List<CompletedTask>>> getAllCompletedTasks() async {
    var result = Result<List<CompletedTask>>();
    List<CompletedTask> tasks = [];
    try {
      tasks = await CompletedTaskRepository.getAllCompletedTasksByUser();
      result.setData(tasks);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      result.setErrorMessage('There was a problem getting completed tasks');
    }
    return result;
  }

  static Future<Result<void>> deleteCompletedTasks(List<String> taskIds) async {
    var result = Result();
    try {
      await CompletedTaskRepository.deleteCompletedTasks(DeleteCompletedTasksRequest(taskIds: taskIds));
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      result.setErrorMessage('There was a problem deleting the completed tasks');
    }
    return result;
  }

  static Future<Result<void>> deleteCompletedTask(CompletedTask task) async {
    var result = Result();
    try {
      await CompletedTaskRepository.deleteCompletedTask(task.id);
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      result.setErrorMessage('There was a problem deleting the completed task');
    }
    return result;
  }
}
