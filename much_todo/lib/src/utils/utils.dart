import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/completed_task.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/utils/enums.dart';
import 'package:url_launcher/url_launcher.dart';

void hideKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}

void showSnackbar(String message, BuildContext context, {int milliseconds = 1500}) {
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
        child: AlertDialog.adaptive(
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

String getEffortTitle(num effort) {
  if (effort == Task.lowEffort) {
    return 'Low';
  } else if (effort == Task.mediumEffort) {
    return 'Medium';
  } else {
    return 'High';
  }
}

double getPriorityPercentage(int priority) {
  // lower priority is more important, so we want display indicator to be reversed
  return (6 - priority) / 5;
}

double getEffortPercentage(int effort) {
  return effort / 3;
}

bool equalityCheckNumber(EqualityComparison equalityType, num filterValue, num taskValue) {
  switch (equalityType) {
    case EqualityComparison.equalTo:
      if (taskValue != filterValue) {
        return false;
      } else {
        return true;
      }
    case EqualityComparison.greaterThan:
      if (taskValue <= filterValue) {
        return false;
      } else {
        return true;
      }
    case EqualityComparison.greaterThanOrEqualTo:
      if (taskValue < filterValue) {
        return false;
      } else {
        return true;
      }
    case EqualityComparison.lessThan:
      if (taskValue >= filterValue) {
        return false;
      } else {
        return true;
      }
    case EqualityComparison.lessThanOrEqualTo:
      if (taskValue > filterValue) {
        return false;
      } else {
        return true;
      }
  }
}

bool equalityCheckDate(DateEqualityComparison equalityType, DateTime filterValue, DateTime taskValue) {
  switch (equalityType) {
    case DateEqualityComparison.equalTo:
      if (taskValue != filterValue) {
        return false;
      } else {
        return true;
      }
    case DateEqualityComparison.after:
      if (taskValue.isBefore(filterValue)) {
        return false;
      } else {
        return true;
      }
    case DateEqualityComparison.before:
      if (taskValue.isAfter(filterValue)) {
        return false;
      } else {
        return true;
      }
  }
}

void sortTasks(List<Task> tasks, TaskSortOption sortBy, SortDirection sortDirection) {
  // initially ascending
  switch (sortBy) {
    case TaskSortOption.name:
      tasks.sort((a, b) => a.name.compareTo(b.name));
      break;
    case TaskSortOption.priority:
      tasks.sort((a, b) => a.priority.compareTo(b.priority));
      break;
    case TaskSortOption.effort:
      tasks.sort((a, b) => a.effort.compareTo(b.effort));
      break;
    case TaskSortOption.room:
      tasks.sort((a, b) => a.room.name.compareTo(b.room.name));
      break;
    case TaskSortOption.cost:
      tasks.sort((a, b) => a.estimatedCost?.compareTo(b.estimatedCost ?? 0.0) ?? -1);
      break;
    case TaskSortOption.creationDate:
      tasks.sort((a, b) => a.creationDate.compareTo(b.creationDate));
      break;
    case TaskSortOption.dueBy:
      tasks.sort((a, b) => a.completeBy?.compareTo(b.completeBy ?? DateTime(1970)) ?? -1);
      break;
    case TaskSortOption.inProgress:
      tasks.sort((a, b) {
        if (b.inProgress) {
          // ones that are in progress are on top in ascending
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

void sortCompletedTasks(List<CompletedTask> tasks, CompletedTaskSortOption sortBy, SortDirection sortDirection) {
  // initially ascending
  switch (sortBy) {
    case CompletedTaskSortOption.name:
      tasks.sort((a, b) => a.name.compareTo(b.name));
      break;
    case CompletedTaskSortOption.priority:
      tasks.sort((a, b) => a.priority.compareTo(b.priority));
      break;
    case CompletedTaskSortOption.effort:
      tasks.sort((a, b) => a.effort.compareTo(b.effort));
      break;
    case CompletedTaskSortOption.room:
      tasks.sort((a, b) => a.roomName.compareTo(b.roomName));
      break;
    case CompletedTaskSortOption.cost:
      tasks.sort((a, b) => a.estimatedCost?.compareTo(b.estimatedCost ?? 0.0) ?? -1);
      break;
    case CompletedTaskSortOption.completionDate:
      tasks.sort((a, b) => a.completionDate.compareTo(b.completionDate));
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

Future<void> launchEmail(BuildContext context, String? email) async {
  if (email == null) {
    showSnackbar('Email is empty.', context);
    return;
  }

  var uri = Uri(scheme: 'mailto', path: email);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    if (context.mounted) {
      showSnackbar('Could not launch email.', context);
    }
  }
}

Future<void> launchPhone(BuildContext context, String? phoneNumber) async {
  if (phoneNumber == null) {
    showSnackbar('Phone number is empty.', context);
    return;
  }

  var uri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    if (context.mounted) {
      showSnackbar('Could not launch number.', context);
    }
  }
}
