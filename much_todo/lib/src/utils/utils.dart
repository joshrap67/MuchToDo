import 'package:flutter/material.dart';
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

String getEffortTitle(int effort) {
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

bool equalityCheckNumber(EqualityComparisons equalityType, num filterValue, num taskValue) {
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

void sortTasks(List<Task> tasks, TaskSortOptions sortBy, SortDirection sortDirection) {
  // initially ascending
  switch (sortBy) {
    case TaskSortOptions.name:
      tasks.sort((a, b) => a.name.compareTo(b.name));
      break;
    case TaskSortOptions.priority:
      tasks.sort((a, b) => a.priority.compareTo(b.priority));
      break;
    case TaskSortOptions.effort:
      tasks.sort((a, b) => a.effort.compareTo(b.effort));
      break;
    case TaskSortOptions.room:
      tasks.sort((a, b) => a.room.name.compareTo(b.room.name));
      break;
    case TaskSortOptions.cost:
      tasks.sort((a, b) => a.estimatedCost?.compareTo(b.estimatedCost ?? 0.0) ?? -1);
      break;
    case TaskSortOptions.creationDate:
      tasks.sort((a, b) => a.creationDate.compareTo(b.creationDate));
      break;
    case TaskSortOptions.dueBy:
      tasks.sort((a, b) => a.completeBy?.compareTo(b.completeBy ?? DateTime(1970)) ?? -1);
      break;
    case TaskSortOptions.inProgress:
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

Future<void> launchEmail(BuildContext context, String? email) async {
  if (email == null) {
    showSnackbar('Email is empty.', context);
    return;
  }

  final Uri uri = Uri(scheme: 'mailto', path: email);
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

  final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    if (context.mounted) {
      showSnackbar('Could not launch number.', context);
    }
  }
}
