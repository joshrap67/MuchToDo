import 'package:flutter/material.dart';

enum SortOptions {
  name(0, 'Name'),
  priority(1, 'Priority'),
  effort(2, 'Effort'),
  room(2, 'Room Name'),
  cost(2, 'Estimated Cost'),
  creationDate(2, 'Creation Date'),
  dueBy(2, 'Due By'),
  completed(2, 'Completed'),
  inProgress(2, 'In Progress');

  const SortOptions(this.value, this.label);

  final int value; // using since i will probably want to store these in local prefs
  final String label;
}

enum SortDirection {
  descending(0, Icon(Icons.arrow_downward)),
  ascending(1, Icon(Icons.arrow_upward));

  const SortDirection(this.value, this.widget);

  final int value; // using since i will probably want to store these in local prefs
  final Widget widget;
}

enum EqualityComparisons {
  greaterThan(0, '>'),
  greaterThanOrEqualTo(1, '≥'),
  equalTo(2, '='),
  lessThan(3, '<'),
  lessThanOrEqualTo(4, '≤');

  const EqualityComparisons(this.value, this.label);

  final int value; // using since i will probably want to store these in local prefs
  final String label;
}

enum DateEqualityComparisons {
  after(0, '>'),
  equalTo(1, '='),
  before(2, '<');

  const DateEqualityComparisons(this.value, this.label);

  final int value; // using since i will probably want to store these in local prefs
  final String label;
}

enum PriorityFilter {
  one(1, '1'),
  two(2, '2'),
  three(3, '3'),
  four(4, '4'),
  five(5, '5');

  const PriorityFilter(this.value, this.label);

  final int value; // using since i will probably want to store these in local prefs
  final String label;
}

enum EffortFilter {
  one(1, 'Low'),
  two(2, 'Medium'),
  three(3, 'High');

  const EffortFilter(this.value, this.label);

  final int value; // using since i will probably want to store these in local prefs
  final String label;
}

class FilterTaskOptions {
  SortOptions sortByValue = SortOptions.creationDate;
  SortDirection sortDirectionValue = SortDirection.descending;

  EqualityComparisons priorityEquality = EqualityComparisons.equalTo;
  PriorityFilter? priorityFilter;

  EffortFilter? effortFilter;
  EqualityComparisons costEquality = EqualityComparisons.equalTo;

  DateEqualityComparisons completeByEquality = DateEqualityComparisons.equalTo;
  DateTime? completeBy;

  DateEqualityComparisons creationDateEquality = DateEqualityComparisons.equalTo;
  DateTime? creationDate;

  DateEqualityComparisons completionDateEquality = DateEqualityComparisons.equalTo;
  DateTime? completionDate;

  bool showOnlyInProgress = false;
  List<String> selectedTags = [];
  List<String> selectedContacts = [];
  String? roomIdFilter;
  double? estimatedCost;

  FilterTaskOptions.named({
    required this.sortByValue,
    required this.sortDirectionValue,
    this.priorityEquality = EqualityComparisons.equalTo,
    this.priorityFilter,
    this.effortFilter,
    this.roomIdFilter,
    this.costEquality = EqualityComparisons.equalTo,
    this.estimatedCost,
    this.selectedTags = const [],
    this.selectedContacts = const [],
    this.showOnlyInProgress = false,
    this.completeByEquality = DateEqualityComparisons.equalTo,
    this.completeBy,
    this.creationDateEquality = DateEqualityComparisons.equalTo,
    this.creationDate,
    this.completionDateEquality = DateEqualityComparisons.equalTo,
    this.completionDate, // todo delete
  });

  int getFilterCount() {
    int count = 0;
    if (priorityFilter != null) {
      count++;
    }
	if (effortFilter != null) {
		count++;
	}
	if (roomIdFilter != null) {
		count++;
	}
	if (estimatedCost != null) {
		count++;
	}
	if (selectedTags.isNotEmpty) {
		count++;
	}
	if (selectedContacts.isNotEmpty) {
		count++;
	}
	if (showOnlyInProgress) {
		count++;
	}
	if (completeBy != null) {
		count++;
	}
	if (creationDate != null) {
		count++;
	}


	return count;
  }
}
