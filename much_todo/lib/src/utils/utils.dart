import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/filter/filter_task_options.dart';
import 'package:much_todo/src/utils/globals.dart';

void hideKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

extension StringExtensions on String? {
  bool isNullOrEmpty() {
    // todo makes no sense as extension since null would throw exception trying to invoke this method
    return this == null || this!.isEmpty;
  }

  bool isNotNullOrEmpty() {
    return this != null && this!.isNotEmpty;
  }
}

void showSnackbar(String message, BuildContext context, {int milliseconds = 3000}) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  final snackBar = SnackBar(
    content: Text(message),
    duration: Duration(milliseconds: milliseconds),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showLoadingDialog(BuildContext context, {String msg = 'Loading...', bool dismissible = false}) {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => dismissible,
        child: AlertDialog(
          title: Text(msg),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(8.0),
                child: LinearProgressIndicator(),
              )
            ],
          ),
        ),
      );
    },
  );
}

void closePopup(BuildContext context) {
	Navigator.of(context, rootNavigator: true).pop('dialog');
}

String? validNewTag(String? tagName, List<Tag> tags) {
  if (tagName == null || tagName.isEmpty) {
    return 'Name is required.';
  } else if (tags.any((x) => x.name == tagName)) {
    return 'Tag already exists';
  } else {
    return null;
  }
}

String? validRoomName(String? name, List<Room> rooms) {
  if (name == null || name.isEmpty) {
    return 'Required';
  }
  if (rooms.any((r) => r.name == name)) {
    // todo don't do this?
    return 'Room name already exists';
  }
  return null;
}

String? validRoomEditName(String? name, String originalName, List<Room> rooms) {
  if (name != null && name == originalName) {
    return null;
  }

  if (name == null || name.isEmpty) {
    return 'Required';
  }
  if (rooms.any((r) => r.name == name)) {
    return 'Room name already exists';
  }
  return null;
}

String? validRoomNote(String? note) {
  if (note != null && note.length > Constants.maxRoomNoteLength) {
    return 'Note too large';
  }
  return null;
}

bool equalityCheckInt(EqualityComparisons equalityType, int filterValue, int taskValue) {
  switch (equalityType) {
    case EqualityComparisons.equalTo:
      if (taskValue != filterValue) {
        return false;
      } else {
        return true;
      }
    case EqualityComparisons.greaterThan:
      if (taskValue <= filterValue) {
        return false;
      } else {
        return true;
      }
    case EqualityComparisons.greaterThanOrEqualTo:
      if (taskValue < filterValue) {
        return false;
      } else {
        return true;
      }
    case EqualityComparisons.lessThan:
      if (taskValue >= filterValue) {
        return false;
      } else {
        return true;
      }
    case EqualityComparisons.lessThanOrEqualTo:
      if (taskValue > filterValue) {
        return false;
      } else {
        return true;
      }
  }
}

bool equalityCheckDouble(EqualityComparisons equalityType, double filterValue, double taskValue) {
  switch (equalityType) {
    case EqualityComparisons.equalTo:
      if (taskValue != filterValue) {
        return false;
      } else {
        return true;
      }
    case EqualityComparisons.greaterThan:
      if (taskValue <= filterValue) {
        return false;
      } else {
        return true;
      }
    case EqualityComparisons.greaterThanOrEqualTo:
      if (taskValue < filterValue) {
        return false;
      } else {
        return true;
      }
    case EqualityComparisons.lessThan:
      if (taskValue >= filterValue) {
        return false;
      } else {
        return true;
      }
    case EqualityComparisons.lessThanOrEqualTo:
      if (taskValue > filterValue) {
        return false;
      } else {
        return true;
      }
  }
}

bool equalityCheckDate(DateEqualityComparisons equalityType, DateTime filterValue, DateTime taskValue) {
  switch (equalityType) {
    case DateEqualityComparisons.equalTo:
      if (taskValue != filterValue) {
        return false;
      } else {
        return true;
      }
    case DateEqualityComparisons.after:
      if (taskValue.isBefore(filterValue)) {
        return false;
      } else {
        return true;
      }
    case DateEqualityComparisons.before:
      if (taskValue.isAfter(filterValue)) {
        return false;
      } else {
        return true;
      }
  }
}

void sortTasks(List<Task> tasks, SortOptions sortBy, SortDirection sortDirection) {
  // initially ascending
  switch (sortBy) {
    case SortOptions.name:
      tasks.sort((a, b) => a.name.compareTo(b.name));
      break;
    case SortOptions.priority:
      tasks.sort((a, b) => a.priority.compareTo(b.priority));
      break;
    case SortOptions.effort:
      tasks.sort((a, b) => a.effort.compareTo(b.effort));
      break;
    case SortOptions.room:
      tasks.sort((a, b) => a.room.name.compareTo(b.room.name));
      break;
    case SortOptions.cost:
      tasks.sort((a, b) => a.estimatedCost?.compareTo(b.estimatedCost ?? 0.0) ?? -1); // todo ugh
      break;
    case SortOptions.creationDate:
      tasks.sort((a, b) => a.creationDate.compareTo(b.creationDate));
      break;
    case SortOptions.dueBy:
      tasks.sort((a, b) => a.completeBy?.compareTo(b.completeBy ?? DateTime(1970)) ?? -1); // todo ugh
      break;
    case SortOptions.inProgress:
      tasks.sort((a, b) {
        if (b.inProgress) {
          // ones that are in progress are on top in ascending
          return 1;
        }
        return -1;
      });
      break;
    case SortOptions.completed:
      tasks.sort((a, b) {
        if (b.isCompleted) {
          // ones that are completed are on top in ascending
          return 1;
        }
        return -1;
      });
      break;
  }
  if (sortDirection == SortDirection.descending) {
    for (var i = 0; i < tasks.length / 2; i++) {
      var temp = tasks[i];
      tasks[i] = tasks[tasks.length - 1 - i];
      tasks[tasks.length - 1 - i] = temp;
    }
  }
}
