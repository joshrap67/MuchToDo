import 'package:much_todo/src/utils/enums.dart';

class FilterTaskOptions {
  TaskSortOption sortByValue = TaskSortOption.creationDate;
  SortDirection sortDirectionValue = SortDirection.descending;

  // this could be confusing since a lower number is a higher priority. Going to keep it though since i assume a power user who would be using this will understand
  EqualityType priorityEquality = EqualityType.equalTo;
  PriorityFilter? priority;

  EffortFilter? effort;
  EqualityType costEquality = EqualityType.equalTo;

  DateEqualityType completeByEquality = DateEqualityType.equalTo;
  DateTime? completeBy;

  DateEqualityType creationDateEquality = DateEqualityType.equalTo;
  DateTime? creationDate;

  bool showOnlyInProgress = false;
  List<String> selectedTags = [];
  List<String> selectedContacts = [];
  String? roomId;
  double? estimatedCost;

  FilterTaskOptions.named({
    required this.sortByValue,
    required this.sortDirectionValue,
    this.priorityEquality = EqualityType.equalTo,
    this.priority,
    this.effort,
    this.roomId,
    this.costEquality = EqualityType.equalTo,
    this.estimatedCost,
    this.selectedTags = const [],
    this.selectedContacts = const [],
    this.showOnlyInProgress = false,
    this.completeByEquality = DateEqualityType.equalTo,
    this.completeBy,
    this.creationDateEquality = DateEqualityType.equalTo,
    this.creationDate,
  });

  int getFilterCount() {
    int count = 0;
    if (priority != null) {
      count++;
    }
    if (effort != null) {
      count++;
    }
    if (roomId != null) {
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
