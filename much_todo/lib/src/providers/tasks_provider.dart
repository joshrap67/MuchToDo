import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/screens/filter_tasks/filter_task_options.dart';
import 'package:much_todo/src/utils/enums.dart';
import 'package:much_todo/src/utils/utils.dart';

class TasksProvider with ChangeNotifier {
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  bool _isLoading = true;
  FilterTaskOptions _filters = FilterTaskOptions.named(
    sortByValue: TaskSortOption.creationDate,
    sortDirectionValue: SortDirection.descending,
  );

  List<Task> get allTasks => [..._allTasks];

  List<Task> get filteredTasks => [..._filteredTasks];

  bool get isLoading => _isLoading;

  FilterTaskOptions get filters => _filters;

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

  void updateTask(Task task) {
    var index = _allTasks.indexWhere((element) => element.id == task.id);
    if (index >= 0) {
      _allTasks[index] = task;
    }
    filterAndNotify();
  }

  void updateTaskProgress(String taskId, bool inProgress) {
    var index = _allTasks.indexWhere((element) => element.id == taskId);
    if (index >= 0) {
      _allTasks[index].inProgress = inProgress;
    }
    filterAndNotify();
  }

  void removeTask(Task task) {
    _allTasks.removeWhere((t) => t.id == task.id);
    filterAndNotify();
  }

  void notify() {
    notifyListeners();
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

  void updateContactForTasks(String id, String name, String email, String phoneNumber) {
    for (var task in _allTasks) {
      var index = task.contacts.indexWhere((p) => p.id == id);
      if (index >= 0) {
        task.contacts[index].update(name, email, phoneNumber);
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
        bool match = equalityCheckNumber(_filters.priorityEquality, _filters.priorityFilter!.value, task.priority);
        if (!match) {
          return false;
        }
      }
      if (_filters.effortFilter != null) {
        bool match = equalityCheckNumber(EqualityComparison.equalTo, _filters.effortFilter!.value, task.effort);
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
        bool match = equalityCheckNumber(_filters.costEquality, _filters.estimatedCost!, task.estimatedCost!);
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
      return true;
    }).toList();
    sortTasks(filtered, filters.sortByValue, filters.sortDirectionValue);
    _filteredTasks = filtered;
  }
}
