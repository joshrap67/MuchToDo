import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/screens/filter_tasks/filter_task_options.dart';
import 'package:much_todo/src/utils/enums.dart';
import 'package:much_todo/src/widgets/form_widgets/date_picker.dart';
import 'package:much_todo/src/widgets/form_widgets/money_input.dart';
import 'package:much_todo/src/widgets/loading_button.dart';
import 'package:much_todo/src/widgets/form_widgets/pending_contacts_selector.dart';
import 'package:much_todo/src/widgets/form_widgets/pending_tags_selector.dart';
import 'package:much_todo/src/widgets/sort_direction_button.dart';
import 'package:provider/provider.dart';

class FilterTasks extends StatefulWidget {
  const FilterTasks({super.key});

  @override
  State<FilterTasks> createState() => _FilterTasksState();
}

class _FilterTasksState extends State<FilterTasks> {
  TaskSortOptions _sortByValue = TaskSortOptions.creationDate;
  SortDirection _sortDirectionValue = SortDirection.descending;

  EqualityComparisons _priorityEquality = EqualityComparisons.equalTo;
  PriorityFilter? _priorityFilter;

  EffortFilter? _effortFilter;

  double? _costFilter;
  EqualityComparisons _costEquality = EqualityComparisons.equalTo;

  DateTime? _completeByFilter;
  DateEqualityComparisons _completeByEquality = DateEqualityComparisons.equalTo;

  DateTime? _creationDateFilter;
  DateEqualityComparisons _creationDateEquality = DateEqualityComparisons.equalTo;

  bool _showOnlyInProgress = false;
  List<Tag> _selectedTags = [];
  List<Contact> _selectedContacts = [];
  String? _roomIdFilter;

  final List<DropdownMenuItem<TaskSortOptions>> _sortEntries = <DropdownMenuItem<TaskSortOptions>>[];
  final List<DropdownMenuItem<EqualityComparisons>> _equalityEntries = <DropdownMenuItem<EqualityComparisons>>[];
  final List<DropdownMenuItem<DateEqualityComparisons>> _dateEqualityEntries =
      <DropdownMenuItem<DateEqualityComparisons>>[];
  final List<DropdownMenuItem<PriorityFilter>> _priorityEntries = <DropdownMenuItem<PriorityFilter>>[];
  final List<DropdownMenuItem<EffortFilter>> _effortEntries = <DropdownMenuItem<EffortFilter>>[];
  final List<DropdownMenuItem<String>> _roomEntries = <DropdownMenuItem<String>>[];

  @override
  void initState() {
    super.initState();
    for (var value in TaskSortOptions.values) {
      _sortEntries.add(DropdownMenuItem<TaskSortOptions>(
        value: value,
        child: Text(value.label),
      ));
    }

    for (var value in EqualityComparisons.values) {
      _equalityEntries.add(DropdownMenuItem<EqualityComparisons>(
        value: value,
        child: Text(value.label),
      ));
    }
    for (var value in DateEqualityComparisons.values) {
      _dateEqualityEntries.add(DropdownMenuItem<DateEqualityComparisons>(
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FilterTaskOptions filters = context.read<TasksProvider>().filters;
        _sortByValue = filters.sortByValue;
        _sortDirectionValue = filters.sortDirectionValue;
        _priorityFilter = filters.priorityFilter;
        _priorityEquality = filters.priorityEquality;
        _effortFilter = filters.effortFilter;
        _roomIdFilter = filters.roomIdFilter;
        _costEquality = filters.costEquality;
        _selectedContacts =
            context.read<UserProvider>().contacts.where((x) => filters.selectedContacts.any((y) => y == x.id)).toList();
        _selectedTags =
            context.read<UserProvider>().tags.where((x) => filters.selectedTags.any((y) => y == x.id)).toList();
        _showOnlyInProgress = filters.showOnlyInProgress;
        _costFilter = filters.estimatedCost;

        _completeByFilter = filters.completeBy;
        _completeByEquality = filters.completeByEquality;

        _creationDateFilter = filters.creationDate;
        _creationDateEquality = filters.creationDateEquality;

        setState(() {});
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      var rooms = context.read<RoomsProvider>().rooms;
      for (var room in rooms) {
        _roomEntries.add(DropdownMenuItem<String>(
          value: room.id,
          child: Text(room.name),
        ));
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Tasks'),
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
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
                              value: _sortByValue,
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
                              isExpanded: true,
                              value: _priorityEquality,
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
                              // todo these widgets are really annoying and might just need to use 3rd party lib. focus won't go away, and menu opens with offset relative to initial value
                              items: _priorityEntries,
                              isExpanded: true,
                              value: _priorityFilter,

                              decoration: InputDecoration(
                                suffixIcon: _priorityFilter == null
                                    ? null
                                    : IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () => setState(
                                          () {
                                            _priorityFilter = null;
                                          },
                                        ),
                                      ),
                              ),
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
                              isExpanded: true,
                              value: _effortFilter,
                              decoration: InputDecoration(
                                suffixIcon: _effortFilter == null
                                    ? null
                                    : IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () => setState(
                                          () {
                                            _effortFilter = null;
                                          },
                                        ),
                                      ),
                              ),
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
                              isExpanded: true,
                              value: _roomIdFilter,
                              decoration: InputDecoration(
                                suffixIcon: _roomIdFilter == null
                                    ? null
                                    : IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () => setState(
                                          () {
                                            _roomIdFilter = null;
                                          },
                                        ),
                                      ),
                              ),
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
                              isExpanded: true,
                              value: _costEquality,
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
                              amount: _costFilter,
                              showClear: true,
                              onChange: (amount) {
                                setState(() {
                                  _costFilter = amount;
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
                              isExpanded: true,
                              value: _completeByEquality,
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
                              isExpanded: true,
                              value: _creationDateEquality,
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LoadingButton(
              onSubmit: onSubmit,
              label: 'APPLY FILTERS',
              icon: const Icon(Icons.check),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onSubmit() async {
    FilterTaskOptions options = FilterTaskOptions.named(
      sortByValue: _sortByValue,
      sortDirectionValue: _sortDirectionValue,
      priorityEquality: _priorityEquality,
      priorityFilter: _priorityFilter,
      effortFilter: _effortFilter,
      roomIdFilter: _roomIdFilter,
      costEquality: _costEquality,
      estimatedCost: _costFilter,
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
}