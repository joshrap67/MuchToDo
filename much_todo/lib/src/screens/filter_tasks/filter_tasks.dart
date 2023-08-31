import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/screens/filter_tasks/contact_card_filter.dart';
import 'package:much_todo/src/screens/filter_tasks/filter_task_options.dart';
import 'package:much_todo/src/screens/filter_tasks/tags_card_filter.dart';
import 'package:much_todo/src/utils/enums.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/loading_button.dart';
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
  final TextEditingController _costFilterController = TextEditingController();
  final TextEditingController _completeByFilterController = TextEditingController();
  final TextEditingController _creationDateFilterController = TextEditingController();

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
        _costFilterController.text = filters.estimatedCost?.toString() ?? '';
        _costEquality = filters.costEquality;
        _selectedContacts =
            context.read<UserProvider>().contacts.where((x) => filters.selectedContacts.any((y) => y == x.id)).toList();
        _selectedTags =
            context.read<UserProvider>().tags.where((x) => filters.selectedTags.any((y) => y == x.id)).toList();
        _showOnlyInProgress = filters.showOnlyInProgress;
        _completeByFilter = filters.completeBy;
        _completeByEquality = filters.completeByEquality;
        if (_completeByFilter != null) {
          _completeByFilterController.text = DateFormat('yyyy-MM-dd').format(_completeByFilter!);
        }

        _creationDateFilter = filters.creationDate;
        _creationDateEquality = filters.creationDateEquality;
        if (_creationDateFilter != null) {
          _creationDateFilterController.text = DateFormat('yyyy-MM-dd').format(_creationDateFilter!);
        }

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
                    Card(
                      child: Row(
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
                              child: IconButton(
                                icon: _sortDirectionValue == SortDirection.descending
                                    ? const Icon(Icons.arrow_downward_sharp)
                                    : const Icon(Icons.arrow_upward_sharp),
                                tooltip: _sortDirectionValue == SortDirection.descending ? 'Descending' : 'Ascending',
                                onPressed: () {
                                  if (_sortDirectionValue == SortDirection.descending) {
                                    _sortDirectionValue = SortDirection.ascending;
                                  } else {
                                    _sortDirectionValue = SortDirection.descending;
                                  }
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Card(
                      child: Row(
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
                    ),
                    Card(
                      child: Row(
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
                    ),
                    Card(
                      child: Row(
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
                    ),
                    Card(
                      child: Row(
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
                              child: TextFormField(
                                controller: _costFilterController,
                                onChanged: (_) {
                                  setState(() {});
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  CurrencyTextInputFormatter(locale: 'en', symbol: '', enableNegative: false)
                                ],
                                decoration: InputDecoration(
                                  border: const OutlineInputBorder(),
                                  label: const Text('\$'),
                                  suffixIcon: _costFilterController.text.isEmpty
                                      ? null
                                      : IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () => setState(
                                            () {
                                              _costFilterController.clear();
                                            },
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TagsCardFilter(
                        tags: _selectedTags,
                        key: ValueKey(_selectedTags),
                        onChange: (tags) {
                          setState(() {
                            _selectedTags = tags;
                          });
                        }),
                    ContactCardFilter(
                        contacts: _selectedContacts,
                        key: ValueKey(_selectedContacts),
                        onChange: (contacts) {
                          setState(() {
                            _selectedContacts = contacts;
                          });
                        }),
                    CheckboxListTile(
                      value: _showOnlyInProgress,
                      onChanged: (bool? value) {
                        setState(() {
                          _showOnlyInProgress = value ?? false;
                        });
                      },
                      title: const Text('Only Include In Progress Tasks'),
                    ),
                    Card(
                      child: Row(
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
                              child: TextFormField(
                                controller: _completeByFilterController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.date_range),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: _completeByFilterController.text.isNotEmpty
                                      ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _completeByFilter = null;
                                              _completeByFilterController.clear();
                                            });
                                          },
                                          icon: const Icon(Icons.clear),
                                        )
                                      : null,
                                ),
                                onTap: () async {
                                  hideKeyboard();
                                  DateTime? pickDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2010),
                                      lastDate: DateTime(2100));
                                  if (pickDate != null) {
                                    setState(() {
                                      _completeByFilter = pickDate;
                                      _completeByFilterController.text = DateFormat('yyyy-MM-dd').format(pickDate);
                                    });
                                  }
                                  hideKeyboard();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      child: Row(
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
                              child: TextFormField(
                                controller: _creationDateFilterController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.date_range),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: _creationDateFilterController.text.isNotEmpty
                                      ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _creationDateFilter = null;
                                              _creationDateFilterController.clear();
                                            });
                                          },
                                          icon: const Icon(Icons.clear),
                                        )
                                      : null,
                                ),
                                onTap: () async {
                                  hideKeyboard();
                                  DateTime? pickDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2010),
                                      lastDate: DateTime(2100));
                                  if (pickDate != null) {
                                    setState(() {
                                      _creationDateFilter = pickDate;
                                      _creationDateFilterController.text = DateFormat('yyyy-MM-dd').format(pickDate);
                                    });
                                  }
                                  hideKeyboard();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
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
      estimatedCost: _costFilterController.text.isNotEmpty ? double.parse(_costFilterController.text) : null,
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
