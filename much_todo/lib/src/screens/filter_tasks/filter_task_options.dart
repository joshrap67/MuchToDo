import 'package:much_todo/src/utils/enums.dart';

class FilterTaskOptions {
  TaskSortOptions sortByValue = TaskSortOptions.creationDate;
  SortDirection sortDirectionValue = SortDirection.descending;

  EqualityComparisons priorityEquality = EqualityComparisons.equalTo;
  PriorityFilter? priorityFilter;

  EffortFilter? effortFilter;
  EqualityComparisons costEquality = EqualityComparisons.equalTo;

  DateEqualityComparisons completeByEquality = DateEqualityComparisons.equalTo;
  DateTime? completeBy;

  DateEqualityComparisons creationDateEquality = DateEqualityComparisons.equalTo;
  DateTime? creationDate;

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
