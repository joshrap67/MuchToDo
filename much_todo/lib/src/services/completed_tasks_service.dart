import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:uuid/uuid.dart';

class CompletedTaskService {
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
