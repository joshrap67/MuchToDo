import 'package:much_todo/src/utils/enums.dart';

class FilterTaskOptions {
  TaskSortOption sortByValue = TaskSortOption.creationDate;
  SortDirection sortDirectionValue = SortDirection.descending;

  EqualityComparison priorityEquality = EqualityComparison.equalTo;
  PriorityFilter? priorityFilter;

  EffortFilter? effortFilter;
  EqualityComparison costEquality = EqualityComparison.equalTo;

  DateEqualityComparison completeByEquality = DateEqualityComparison.equalTo;
  DateTime? completeBy;

  DateEqualityComparison creationDateEquality = DateEqualityComparison.equalTo;
  DateTime? creationDate;

  bool showOnlyInProgress = false;
  List<String> selectedTags = [];
  List<String> selectedContacts = [];
  String? roomIdFilter;
  double? estimatedCost;

  FilterTaskOptions.named({
    required this.sortByValue,
    required this.sortDirectionValue,
    this.priorityEquality = EqualityComparison.equalTo,
    this.priorityFilter,
    this.effortFilter,
    this.roomIdFilter,
    this.costEquality = EqualityComparison.equalTo,
    this.estimatedCost,
    this.selectedTags = const [],
    this.selectedContacts = const [],
    this.showOnlyInProgress = false,
    this.completeByEquality = DateEqualityComparison.equalTo,
    this.completeBy,
    this.creationDateEquality = DateEqualityComparison.equalTo,
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
