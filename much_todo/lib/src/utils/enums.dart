import 'package:flutter/material.dart';

enum TaskSortOption {
  name(0, 'Name'),
  priority(1, 'Priority'),
  effort(2, 'Effort'),
  room(3, 'Room Name'),
  cost(4, 'Estimated Cost'),
  creationDate(5, 'Creation Date'),
  completeBy(6, 'Complete By'),
  inProgress(7, 'In Progress');

  const TaskSortOption(this.value, this.label);

  static TaskSortOption tryParse(int value) {
    var result = TaskSortOption.name;
    try {
      result = TaskSortOption.values[value];
    } catch (_) {}
    return result;
  }

  final int value;
  final String label;
}

enum CompletedTaskSortOption {
  name(0, 'Name'),
  priority(1, 'Priority'),
  effort(2, 'Effort'),
  room(3, 'Room Name'),
  cost(4, 'Estimated Cost'),
  completionDate(5, 'Completion Date');

  const CompletedTaskSortOption(this.value, this.label);

  final int value;
  final String label;
}

enum RoomSortOption {
  name(0, 'Name'),
  taskCount(1, 'Task Count'),
  totalCost(2, 'Total Cost'),
  creationDate(3, 'Creation Date');

  const RoomSortOption(this.value, this.label);

  final int value;
  final String label;
}

enum SortDirection {
  descending(0, Icon(Icons.arrow_downward)),
  ascending(1, Icon(Icons.arrow_upward));

  const SortDirection(this.value, this.widget);

  static SortDirection tryParse(int value) {
    var result = SortDirection.descending;
    try {
      result = SortDirection.values[value];
    } catch (_) {}
    return result;
  }

  final int value;
  final Widget widget;
}

enum EqualityType {
  greaterThan(0, '>'),
  greaterThanOrEqualTo(1, '≥'),
  equalTo(2, '='),
  lessThan(3, '<'),
  lessThanOrEqualTo(4, '≤');

  const EqualityType(this.value, this.label);

  final int value;
  final String label;
}

enum DateEqualityType {
  after(0, '>'),
  equalTo(1, '='),
  before(2, '<');

  const DateEqualityType(this.value, this.label);

  final int value;
  final String label;
}

enum PriorityFilter {
  one(1, '1'),
  two(2, '2'),
  three(3, '3'),
  four(4, '4'),
  five(5, '5');

  const PriorityFilter(this.value, this.label);

  final int value;
  final String label;
}

enum EffortFilter {
  low(1, 'Low'),
  medium(2, 'Medium'),
  high(3, 'High');

  const EffortFilter(this.value, this.label);

  final int value;
  final String label;
}
