import 'package:flutter/material.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:uuid/uuid.dart';

class TasksProvider with ChangeNotifier {
  static final List<Task> initialData = List.generate(10, (i) {
    return Task(
        const Uuid().v4(),
        const Uuid().v4(),
        'Task ${i + 1}',
        UserProvider.initialData.tags
            .sublist((UserProvider.initialData.tags.length ~/ 2))
            .map((e) => e.convert())
            .toList(),
        (i % 5) + 1,
        (i % 3) + 1,
        RoomsProvider.initialData.first.convert(),
        45.2,
        'Items needed: hammer, paint, screwdriver, nails, wrench, painter\'s tape',
        ['https://www.amazon.com/Celebrity-Cutouts-Danny-DeVito-Cutout/dp/B01AACB8J4/'],
        ['https://upload.wikimedia.org/wikipedia/commons/0/0c/American_Shorthair.jpg', 'https://rb.gy/yk4ed'],
        UserProvider.initialData.people
            .sublist((UserProvider.initialData.tags.length ~/ 2))
            .map((e) => e.convert())
            .toList(),
        false,
        false,
        DateTime.now(),
        DateTime.now().toUtc());
  });

  final List<Task> _tasks = initialData;

  List<Task> get tasks => [..._tasks]; // spread since otherwise widgets could bypass mutation methods

  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
  }

  void addTasks(List<Task> tasks) {
    _tasks.addAll(tasks);
    // todo sort/filter according to current filter/sort values
    notifyListeners();
  }

  void updateTask(Task task) {
    var index = _tasks.indexWhere((element) => element.id == task.id);
    if (index >= 0) {
      _tasks[index] = task;
    }
    notifyListeners();
  }

  void removeTask(Task task) {
    _tasks.removeWhere((t) => t.id == task.id);
    notifyListeners();
  }
}
