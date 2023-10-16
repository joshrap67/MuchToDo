import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/completed_task.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/tag.dart';
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

bool equalityCheckNumber(EqualityType equalityType, num filterValue, num taskValue) {
  switch (equalityType) {
    case EqualityType.equalTo:
      return taskValue == filterValue;
    case EqualityType.greaterThan:
      return taskValue > filterValue;
    case EqualityType.greaterThanOrEqualTo:
      return taskValue >= filterValue;
    case EqualityType.lessThan:
      return taskValue < filterValue;
    case EqualityType.lessThanOrEqualTo:
      return taskValue <= filterValue;
  }
}

bool equalityCheckDate(DateEqualityType equalityType, DateTime filterValue, DateTime taskValue) {
  // really annoying how there is no just pure compare dates ignore time...
  var filterDate = DateTime.utc(filterValue.year, filterValue.month, filterValue.day);
  var taskDate = DateTime.utc(taskValue.year, taskValue.month, taskValue.day);
  switch (equalityType) {
    case DateEqualityType.equalTo:
      return taskDate.isAtSameMomentAs(filterDate);
    case DateEqualityType.after:
      return taskDate.isAfter(filterDate);
    case DateEqualityType.before:
      return taskDate.isBefore(filterDate);
  }
}

int compareToBool(bool a, bool b) {
  if (a == b) {
    return 0;
  } else if (a) {
    return -1;
  }
  return 1;
}

void sortTasks(List<Task> tasks, TaskSortOption sortBy, SortDirection sortDirection) {
  switch (sortBy) {
    case TaskSortOption.name:
      tasks.sort((a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()) * (sortDirection == SortDirection.descending ? -1 : 1));
      break;
    case TaskSortOption.priority:
      tasks.sort((a, b) => a.priority.compareTo(b.priority) * (sortDirection == SortDirection.descending ? -1 : 1));
      break;
    case TaskSortOption.effort:
      tasks.sort((a, b) => a.effort.compareTo(b.effort) * (sortDirection == SortDirection.descending ? -1 : 1));
      break;
    case TaskSortOption.room:
      tasks.sort((a, b) =>
          a.room.name.toLowerCase().compareTo(b.room.name.toLowerCase()) *
          (sortDirection == SortDirection.descending ? -1 : 1));
      break;
    case TaskSortOption.cost:
      tasks.sort((a, b) {
        var estimatedCostA = a.estimatedCost ?? 0.0;
        var estimatedCostB = b.estimatedCost ?? 0.0;
        return estimatedCostA.compareTo(estimatedCostB) * (sortDirection == SortDirection.descending ? -1 : 1);
      });
      break;
    case TaskSortOption.creationDate:
      tasks.sort(
          (a, b) => a.creationDate.compareTo(b.creationDate) * (sortDirection == SortDirection.descending ? -1 : 1));
      break;
    case TaskSortOption.completeBy:
      tasks.sort((a, b) {
        var completeByA = a.completeBy ?? DateTime(1970);
        var completeByB = b.completeBy ?? DateTime(1970);
        return completeByA.compareTo(completeByB) * (sortDirection == SortDirection.descending ? -1 : 1);
      });
      break;
    case TaskSortOption.inProgress:
      tasks.sort(
          (a, b) => compareToBool(a.inProgress, b.inProgress) * (sortDirection == SortDirection.descending ? -1 : 1));
      break;
  }
}

void sortTagsAlpha(List<Tag> tags) {
  tags.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}

void sortContactsAlpha(List<Contact> contacts) {
  contacts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
}

void sortCompletedTasks(List<CompletedTask> tasks, CompletedTaskSortOption sortBy, SortDirection sortDirection) {
  switch (sortBy) {
    case CompletedTaskSortOption.name:
      tasks.sort((a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()) * (sortDirection == SortDirection.descending ? -1 : 1));
      break;
    case CompletedTaskSortOption.priority:
      tasks.sort((a, b) => a.priority.compareTo(b.priority) * (sortDirection == SortDirection.descending ? -1 : 1));
      break;
    case CompletedTaskSortOption.effort:
      tasks.sort((a, b) => a.effort.compareTo(b.effort) * (sortDirection == SortDirection.descending ? -1 : 1));
      break;
    case CompletedTaskSortOption.room:
      tasks.sort((a, b) =>
          a.roomName.toLowerCase().compareTo(b.roomName.toLowerCase()) *
          (sortDirection == SortDirection.descending ? -1 : 1));
      break;
    case CompletedTaskSortOption.cost:
      tasks.sort((a, b) {
        var estimatedCostA = a.cost ?? 0.0;
        var estimatedCostB = b.cost ?? 0.0;
        return estimatedCostA.compareTo(estimatedCostB) * (sortDirection == SortDirection.descending ? -1 : 1);
      });
      break;
    case CompletedTaskSortOption.completionDate:
      tasks.sort((a, b) =>
          a.completionDate.compareTo(b.completionDate) * (sortDirection == SortDirection.descending ? -1 : 1));
      break;
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

Color getDropdownColor(BuildContext context) {
  return ElevationOverlay.applySurfaceTint(
      Theme.of(context).colorScheme.background, Theme.of(context).colorScheme.surfaceTint, 10);
}
