import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/screens/filter_tasks/filter_task_options.dart';
import 'package:much_todo/src/utils/enums.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/form_widgets/date_picker.dart';
import 'package:much_todo/src/widgets/form_widgets/money_input.dart';
import 'package:much_todo/src/widgets/form_widgets/pending_contacts_selector.dart';
import 'package:much_todo/src/widgets/form_widgets/pending_tags_selector.dart';
import 'package:much_todo/src/widgets/loading_button.dart';
import 'package:much_todo/src/widgets/sort_direction_button.dart';
import 'package:provider/provider.dart';

class FilterTasks extends StatefulWidget {
  const FilterTasks({super.key});

  @override
  State<FilterTasks> createState() => _FilterTasksState();
}

class _FilterTasksState extends State<FilterTasks> {
  final List<DropdownMenuItem<TaskSortOption>> _sortEntries = <DropdownMenuItem<TaskSortOption>>[];
  final List<DropdownMenuItem<EqualityType>> _equalityEntries = <DropdownMenuItem<EqualityType>>[];
  final List<DropdownMenuItem<DateEqualityType>> _dateEqualityEntries = <DropdownMenuItem<DateEqualityType>>[];
  final List<DropdownMenuItem<PriorityFilter>> _priorityEntries = <DropdownMenuItem<PriorityFilter>>[];
  final List<DropdownMenuItem<EffortFilter>> _effortEntries = <DropdownMenuItem<EffortFilter>>[];
  final List<DropdownMenuItem<String>> _roomEntries = <DropdownMenuItem<String>>[];

  TaskSortOption _sortByValue = TaskSortOption.creationDate;
  SortDirection _sortDirectionValue = SortDirection.descending;

  EqualityType _priorityEquality = EqualityType.equalTo;
  PriorityFilter? _priorityFilter;

  EffortFilter? _effortFilter;

  EqualityType _costEquality = EqualityType.equalTo;
  double? _estimatedCostFilter;

  DateEqualityType _completeByEquality = DateEqualityType.equalTo;
  DateTime? _completeByFilter;

  DateEqualityType _creationDateEquality = DateEqualityType.equalTo;
  DateTime? _creationDateFilter;

  bool _showOnlyInProgress = false;
  List<Tag> _selectedTags = [];
  List<Contact> _selectedContacts = [];
  String? _roomIdFilter;

  @override
  void initState() {
    super.initState();
    for (var value in TaskSortOption.values) {
      _sortEntries.add(DropdownMenuItem<TaskSortOption>(
        value: value,
        child: Text(value.label),
      ));
    }
    for (var value in EqualityType.values) {
      _equalityEntries.add(DropdownMenuItem<EqualityType>(
        value: value,
        child: Text(value.label),
      ));
    }
    for (var value in DateEqualityType.values) {
      _dateEqualityEntries.add(DropdownMenuItem<DateEqualityType>(
        value: value,
        child: Text(value.label),
      ));
    }
    for (var value in PriorityFilter.values) {
      _priorityEntries.add(DropdownMenuItem<PriorityFilter>(
        value: value,
        child: Text(value.label),
      ));
    }
    for (var value in EffortFilter.values) {
      _effortEntries.add(DropdownMenuItem<EffortFilter>(
        value: value,
        child: Text(value.label),
      ));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var rooms = context.read<RoomsProvider>().rooms.toList();
      rooms.sort((a, b) => a.name.compareTo(b.name));
      for (var room in rooms) {
        _roomEntries.add(DropdownMenuItem<String>(
          value: room.id,
          child: Text(room.name),
        ));
      }

      FilterTaskOptions filters = context.read<TasksProvider>().filters;
      _sortByValue = filters.sortByValue;
      _sortDirectionValue = filters.sortDirectionValue;
      _priorityFilter = filters.priority;
      _priorityEquality = filters.priorityEquality;
      _effortFilter = filters.effort;
      _roomIdFilter = filters.roomId;
      _costEquality = filters.costEquality;
      _selectedContacts =
          context.read<UserProvider>().contacts.where((x) => filters.selectedContacts.any((y) => y == x.id)).toList();
      _selectedTags =
          context.read<UserProvider>().tags.where((x) => filters.selectedTags.any((y) => y == x.id)).toList();
      _showOnlyInProgress = filters.showOnlyInProgress;
      _estimatedCostFilter = filters.estimatedCost;

      _completeByFilter = filters.completeBy;
      _completeByEquality = filters.completeByEquality;

      _creationDateFilter = filters.creationDate;
      _creationDateEquality = filters.creationDateEquality;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoSizeText(
          'Filter Tasks',
          minFontSize: 10,
        ),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        scrolledUnderElevation: 0,
        actions: [
          Visibility(
            visible: getFilterCount() > 0,
            child: TextButton.icon(
              onPressed: clearFilters,
              icon: Icon(Icons.clear, color: Theme.of(context).colorScheme.onSecondaryContainer),
              label: Text(
                'CLEAR ALL',
                style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
              ),
            ),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => hideKeyboard(),
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Text(
                        'Sort By',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField(
                          items: _sortEntries,
                          isExpanded: true,
                          dropdownColor: getDropdownColor(context),
                          value: _sortByValue,
                          onTap: () {
                            hideFocus();
                          },
                          onChanged: (value) {
                            setState(() {
                              _sortByValue = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SortDirectionButton(
                          sortDirection: _sortDirectionValue,
                          onChange: (sort) {
                            setState(() {
                              _sortDirectionValue = sort;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    const Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Text(
                        'Priority',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField(
                          items: _equalityEntries,
                          dropdownColor: getDropdownColor(context),
                          isExpanded: true,
                          value: _priorityEquality,
                          onTap: () {
                            hideFocus();
                          },
                          onChanged: (value) {
                            setState(() {
                              _priorityEquality = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField(
                          items: _priorityEntries,
                          dropdownColor: getDropdownColor(context),
                          isExpanded: true,
                          value: _priorityFilter,
                          decoration: InputDecoration(
                            suffixIcon: _priorityFilter == null
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () => setState(() {
                                      _priorityFilter = null;
                                    }),
                                  ),
                          ),
                          onTap: () {
                            hideFocus();
                          },
                          onChanged: (value) {
                            setState(() {
                              _priorityFilter = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Text(
                        'Effort',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField(
                          items: _effortEntries,
                          dropdownColor: getDropdownColor(context),
                          isExpanded: true,
                          value: _effortFilter,
                          decoration: InputDecoration(
                            suffixIcon: _effortFilter == null
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () => setState(() {
                                      _effortFilter = null;
                                    }),
                                  ),
                          ),
                          onTap: () {
                            hideFocus();
                          },
                          onChanged: (value) {
                            setState(() {
                              _effortFilter = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Text(
                        'Room',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Flexible(
                      flex: 5,
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField(
                          items: _roomEntries,
                          dropdownColor: getDropdownColor(context),
                          isExpanded: true,
                          value: _roomIdFilter,
                          menuMaxHeight: 500,
                          decoration: InputDecoration(
                            suffixIcon: _roomIdFilter == null
                                ? null
                                : IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () => setState(() {
                                      _roomIdFilter = null;
                                    }),
                                  ),
                          ),
                          onTap: () {
                            hideFocus();
                          },
                          onChanged: (value) {
                            setState(() {
                              _roomIdFilter = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Text(
                        'Cost',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField(
                          items: _equalityEntries,
                          dropdownColor: getDropdownColor(context),
                          isExpanded: true,
                          value: _costEquality,
                          onTap: () {
                            hideFocus();
                          },
                          onChanged: (value) {
                            setState(() {
                              _costEquality = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 4,
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MoneyInput(
                          hintText: '\$',
                          amount: _estimatedCostFilter,
                          showClear: true,
                          onChange: (amount) {
                            setState(() {
                              _estimatedCostFilter = amount;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                PendingTagsSelector(
                  tags: _selectedTags,
                  key: ValueKey(_selectedTags),
                  showAdd: false,
                  onChange: (tags) {
                    _selectedTags = [...tags];
                  },
                ),
                PendingContactsSelector(
                  contacts: _selectedContacts,
                  key: ValueKey(_selectedContacts),
                  showAdd: false,
                  onChange: (contacts) {
                    _selectedContacts = [...contacts];
                  },
                ),
                CheckboxListTile(
                  value: _showOnlyInProgress,
                  onChanged: (bool? value) {
                    setState(() {
                      _showOnlyInProgress = value ?? false;
                    });
                  },
                  title: const Text('Only Include In Progress Tasks'),
                ),
                Row(
                  children: [
                    const Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Text(
                        'Complete By',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField(
                          items: _dateEqualityEntries,
                          dropdownColor: getDropdownColor(context),
                          isExpanded: true,
                          value: _completeByEquality,
                          onTap: () {
                            hideFocus();
                          },
                          onChanged: (value) {
                            setState(() {
                              _completeByEquality = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DatePicker(
                          key: ValueKey(_completeByFilter),
                          selectedDate: _completeByFilter,
                          initialDate: _completeByFilter,
                          firstDate: DateTime(1000),
                          onChange: (date) {
                            setState(() {
                              _completeByFilter = date;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: Text(
                        'Creation Date',
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButtonFormField(
                          items: _dateEqualityEntries,
                          dropdownColor: getDropdownColor(context),
                          isExpanded: true,
                          value: _creationDateEquality,
                          onTap: () {
                            hideFocus();
                          },
                          onChanged: (value) {
                            setState(() {
                              _creationDateEquality = value!;
                            });
                          },
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      fit: FlexFit.tight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DatePicker(
                          key: ValueKey(_creationDateFilter),
                          selectedDate: _creationDateFilter,
                          initialDate: _creationDateFilter,
                          firstDate: DateTime(1000),
                          onChange: (date) {
                            setState(() {
                              _creationDateFilter = date;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 4),
        child: LoadingButton(
          onSubmit: applyFilters,
          label: getFilterCount() > 0 ? 'APPLY FILTERS (${getFilterCount()})' : 'APPLY FILTERS',
          icon: const Icon(Icons.check),
        ),
      ),
    );
  }

  void hideFocus() {
    // necessary to hide focus after selecting dropdown option, for some reason the hideKeyboard method doesn't work
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> applyFilters() async {
    FilterTaskOptions options = FilterTaskOptions.named(
      sortByValue: _sortByValue,
      sortDirectionValue: _sortDirectionValue,
      priorityEquality: _priorityEquality,
      priority: _priorityFilter,
      effort: _effortFilter,
      roomId: _roomIdFilter,
      costEquality: _costEquality,
      estimatedCost: _estimatedCostFilter,
      selectedTags: _selectedTags.map((t) => t.id).toList(),
      selectedContacts: _selectedContacts.map((c) => c.id).toList(),
      showOnlyInProgress: _showOnlyInProgress,
      completeByEquality: _completeByEquality,
      completeBy: _completeByFilter,
      creationDateEquality: _creationDateEquality,
      creationDate: _creationDateFilter,
    );
    context.read<TasksProvider>().setFilters(options);
    Navigator.pop(context, true);
  }

  void clearFilters() {
    setState(() {
      _priorityFilter = null;
      _effortFilter = null;
      _roomIdFilter = null;
      _estimatedCostFilter = null;
      _selectedTags = [];
      _selectedContacts = [];
      _showOnlyInProgress = false;
      _completeByFilter = null;
      _creationDateFilter = null;
    });
  }

  int getFilterCount() {
    int count = 0;
    if (_priorityFilter != null) {
      count++;
    }
    if (_effortFilter != null) {
      count++;
    }
    if (_roomIdFilter != null) {
      count++;
    }
    if (_estimatedCostFilter != null) {
      count++;
    }
    if (_selectedTags.isNotEmpty) {
      count++;
    }
    if (_selectedContacts.isNotEmpty) {
      count++;
    }
    if (_showOnlyInProgress) {
      count++;
    }
    if (_completeByFilter != null) {
      count++;
    }
    if (_creationDateFilter != null) {
      count++;
    }

    return count;
  }
}
