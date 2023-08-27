import 'dart:convert';

import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/network/api_gateway.dart';
import 'package:much_todo/src/repositories/tasks/requests/create_tasks_request.dart';
import 'package:much_todo/src/repositories/tasks/requests/update_task_request.dart';

class TaskRepository {
  static Future<List<Task>> getAllTasksByUser() async {
    final apiResult = await ApiGateway.get('/tasks');
    if (apiResult.success) {
      var tasks = <Task>[];
      Iterable decodedJsonList = jsonDecode(apiResult.data);
      for (var jsonTask in decodedJsonList) {
        tasks.add(Task.fromJson(jsonTask));
      }
      return tasks;
    } else {
      throw Exception('There was a problem getting tasks.');
    }
  }

  static Future<List<Task>> createTasks(CreateTasksRequest request) async {
    final apiResult = await ApiGateway.post('/tasks', request);
    if (apiResult.success) {
      var tasks = <Task>[];
      Iterable decodedJsonList = jsonDecode(apiResult.data);
      for (var jsonTask in decodedJsonList) {
        tasks.add(Task.fromJson(jsonTask));
      }
      return tasks;
    } else {
      throw Exception('There was a problem creating tasks.');
    }
  }

  static Future<Task> updateTask(String taskId, UpdateTaskRequest request) async {
    final apiResult = await ApiGateway.put('/tasks/$taskId', request);
    if (apiResult.success) {
      var decodedJson = jsonDecode(apiResult.data);
      return Task.fromJson(decodedJson);
    } else {
      throw Exception('There was a problem updating the task.');
    }
  }

  static Future<bool> deleteTask(String taskId) async {
    final apiResult = await ApiGateway.delete('/tasks/$taskId');
    if (apiResult.success) {
      return true;
    } else {
      throw Exception('There was a problem deleting the task.');
    }
  }
}
