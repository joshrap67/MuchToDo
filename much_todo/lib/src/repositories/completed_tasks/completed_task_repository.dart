import 'dart:convert';

import 'package:much_todo/src/domain/completed_task.dart';
import 'package:much_todo/src/repositories/api_gateway.dart';
import 'package:much_todo/src/repositories/completed_tasks/requests/delete_completed_tasks_request.dart';

class CompletedTaskRepository {
  static const baseUrl = 'completed-tasks';

  static Future<List<CompletedTask>> getAllCompletedTasksByUser() async {
    final apiResult = await ApiGateway.get(baseUrl);
    if (apiResult.success) {
      var tasks = <CompletedTask>[];
      var decodedJsonList = jsonDecode(apiResult.data);
      for (var jsonTask in decodedJsonList) {
        tasks.add(CompletedTask.fromJson(jsonTask));
      }
      return tasks;
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<List<CompletedTask>> getAllCompletedTasksByRoom(String roomId) async {
    final apiResult = await ApiGateway.get(baseUrl, queryParams: {'roomId': roomId});
    if (apiResult.success) {
      var tasks = <CompletedTask>[];
      var decodedJsonList = jsonDecode(apiResult.data);
      for (var jsonTask in decodedJsonList) {
        tasks.add(CompletedTask.fromJson(jsonTask));
      }
      return tasks;
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<bool> deleteCompletedTask(String completedTaskId) async {
    final apiResult = await ApiGateway.delete('$baseUrl/$completedTaskId');
    if (apiResult.success) {
      return true;
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<bool> deleteCompletedTasks(DeleteCompletedTasksRequest request) async {
    final apiResult = await ApiGateway.post('$baseUrl/delete-many', request);
    if (apiResult.success) {
      return true;
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<bool> deleteAllCompletedTasks() async {
    final apiResult = await ApiGateway.delete('$baseUrl/all');
    if (apiResult.success) {
      return true;
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }
}
