import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/filter/filter_task_options.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:uuid/uuid.dart';

class TasksProvider with ChangeNotifier {
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  FilterTaskOptions _filters =
      FilterTaskOptions.named(sortByValue: SortOptions.creationDate, sortDirectionValue: SortDirection.descending);

  List<Task> get allTasks => [..._allTasks]; // spread since otherwise widgets could bypass mutation methods
  List<Task> get filteredTasks => [..._filteredTasks];

  bool get isLoading => _isLoading;

  FilterTaskOptions get filters => _filters;

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(
      const Duration(seconds: 5),
      () {
        _allTasks = List.generate(10, (i) {
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
              UserProvider.initialData.contacts
                  .sublist((UserProvider.initialData.tags.length ~/ 2))
                  .map((e) => e.convert())
                  .toList(),
              false,
              false,
              DateTime.now(),
              DateTime.now().toUtc());
        });
      },
    );
    _isLoading = false;
    filterAndNotify();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setTasks(List<Task> tasks) {
    _allTasks = tasks;
    filterAndNotify();
  }

  void addTask(Task task) {
    _allTasks.add(task);
    filterAndNotify();
  }

  void addTasks(List<Task> tasks) {
    _allTasks.addAll(tasks);
    filterAndNotify();
  }

  void updateTask(Task task) {
    var index = _allTasks.indexWhere((element) => element.id == task.id);
    if (index >= 0) {
      _allTasks[index] = task;
    }
    filterAndNotify();
  }

  void removeTask(Task task) {
    _allTasks.removeWhere((t) => t.id == task.id);
    filterAndNotify();
  }

  void removeTagFromTasks(Tag tag) {
    for (var task in _allTasks) {
      task.tags.removeWhere((t) => t.id == tag.id);
    }
    filterAndNotify();
  }

  void updateTagForTasks(Tag tag) {
    for (var task in _allTasks) {
      var index = task.tags.indexWhere((t) => t.id == tag.id);
      if (index >= 0) {
        task.tags[index] = tag.convert();
      }
    }
    filterAndNotify();
  }

  void updateContactForTasks(Contact contact) {
    for (var task in _allTasks) {
      var index = task.contacts.indexWhere((p) => p.id == contact.id);
      if (index >= 0) {
        task.contacts[index] = contact.convert();
      }
    }
    filterAndNotify();
  }

  void removeContactFromTasks(Contact contact) {
    for (var task in _allTasks) {
      task.contacts.removeWhere((p) => p.id == contact.id);
    }
    filterAndNotify();
  }

  void updateRoom(String id, String name) {
    for (var task in _allTasks) {
      if (task.room.id == id) {
        task.room.name = name;
      }
    }
    filterAndNotify();
  }

  void removeTasksFromRoomId(String id) {
    _allTasks.removeWhere((t) => t.room.id == id);
    filterAndNotify();
  }

  void clearTasks() {
    _allTasks = [];
    _filteredTasks = [];
    notifyListeners();
  }

  void setFilters(FilterTaskOptions options) {
    _filters = options;
    filterAndNotify();
  }

  void filterAndNotify() {
    filterTasks();
    notifyListeners();
  }

  void filterTasks() {
    var filtered = _allTasks.where((task) {
      if (_filters.priorityFilter != null) {
        bool match = equalityCheckInt(_filters.priorityEquality, _filters.priorityFilter!.value, task.priority);
        if (!match) {
          return false;
        }
      }
      if (_filters.effortFilter != null) {
        bool match = equalityCheckInt(EqualityComparisons.equalTo, _filters.effortFilter!.value, task.effort);
        if (!match) {
          return false;
        }
      }
      if (_filters.roomIdFilter != null) {
        if (task.room.id != _filters.roomIdFilter!) {
          return false;
        }
      }
      if (_filters.estimatedCost != null) {
        if (task.estimatedCost == null) {
          return false; // if specifying to filter by a cost and a task has no cost, it shouldn't be shown in result
        }
        bool match = equalityCheckDouble(_filters.costEquality, _filters.estimatedCost!, task.estimatedCost!);
        if (!match) {
          return false;
        }
      }
      if (_filters.selectedTags.isNotEmpty) {
        bool match = task.tags.any((t) => _filters.selectedTags.contains(t.id));
        if (!match) {
          return false;
        }
      }
      if (_filters.selectedContacts.isNotEmpty) {
        bool match = task.contacts.any((c) => _filters.selectedContacts.contains(c.id));
        if (!match) {
          return false;
        }
      }
      if (_filters.showOnlyInProgress) {
        if (!task.inProgress) {
          return false;
        }
      }
      if (_filters.completeBy != null) {
        if (task.completeBy == null) {
          return false; // if specifying to filter by a date and a task has no complete by date, it shouldn't be shown in result
        }
        bool match = equalityCheckDate(_filters.completeByEquality, _filters.completeBy!, task.completeBy!);
        if (!match) {
          return false;
        }
      }
      if (_filters.creationDate != null) {
        bool match = equalityCheckDate(_filters.creationDateEquality, _filters.creationDate!, task.creationDate);
        if (!match) {
          return false;
        }
      }
      if (_filters.completionDate != null) {
        // todo i need to decide if this is going to be a date instead of a bool on the domain
        // if (task.isCompleted) {
        //   return false; // if specifying to filter by a date and a task has no complete by date, it shouldn't be shown in result
        // }
        // bool match = equalityCheckDate(options.creationDateEquality, options.creationDate!, task.creationDate!);
        // if (!match) {
        //   return false;
        // }
      }
      return true;
    }).toList();
    sortTasks(filtered, filters.sortByValue, filters.sortDirectionValue);
    _filteredTasks = filtered;
  }
}
