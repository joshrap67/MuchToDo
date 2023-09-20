import 'dart:convert';

import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/repositories/api_gateway.dart';
import 'package:much_todo/src/repositories/tasks/requests/complete_task_request.dart';
import 'package:much_todo/src/repositories/tasks/requests/create_tasks_request.dart';
import 'package:much_todo/src/repositories/tasks/requests/set_task_photos_request.dart';
import 'package:much_todo/src/repositories/tasks/requests/set_task_progress_request.dart';
import 'package:much_todo/src/repositories/tasks/requests/update_task_request.dart';

class TaskRepository {
  static const baseUrl = 'tasks';

  static Future<List<Task>> getAllTasksByUser() async {
    final apiResult = await ApiGateway.get(baseUrl, forceTokenRefresh: true);
    if (apiResult.success) {
      var tasks = <Task>[];
      var decodedJsonList = jsonDecode(apiResult.data);
      for (var jsonTask in decodedJsonList) {
        tasks.add(Task.fromJson(jsonTask));
      }
      return tasks;
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<Task> createTask(CreateTasksRequest request) async {
    final apiResult = await ApiGateway.post(baseUrl, request);
    if (apiResult.success) {
      Map<String, dynamic> decodedJson = jsonDecode(apiResult.data);
      return Task.fromJson(decodedJson);
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<Task> updateTask(String taskId, UpdateTaskRequest request) async {
    final apiResult = await ApiGateway.put('$baseUrl/$taskId', body: request);
    if (apiResult.success) {
      var decodedJson = jsonDecode(apiResult.data);
      return Task.fromJson(decodedJson);
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<bool> deleteTask(String taskId) async {
    final apiResult = await ApiGateway.delete('$baseUrl/$taskId');
    if (apiResult.success) {
      return true;
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<Task> setTaskPhotos(String taskId, SetTaskPhotosRequest request) async {
    final apiResult = await ApiGateway.post('$baseUrl/$taskId/photos', request);
    if (apiResult.success) {
      var decodedJson = jsonDecode(apiResult.data);
      return Task.fromJson(decodedJson);
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<bool> setTaskProgress(String taskId, SetTaskProgressRequest request) async {
    final apiResult = await ApiGateway.put('$baseUrl/$taskId/progress', body: request);
    if (apiResult.success) {
      return true;
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<bool> completeTask(String taskId, CompleteTaskRequest request) async {
    final apiResult = await ApiGateway.post('$baseUrl/$taskId/complete', request);
    if (apiResult.success) {
      return true;
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }
}
