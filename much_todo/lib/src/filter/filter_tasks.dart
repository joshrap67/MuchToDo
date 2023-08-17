import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/filter/contact_card_filter.dart';
import 'package:much_todo/src/filter/tags_card_filter.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/loading_button.dart';
import 'package:provider/provider.dart';

class FilterTasks extends StatefulWidget {
  const FilterTasks({super.key});

  @override
  State<FilterTasks> createState() => _FilterTasksState();
}

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

class _FilterTasksState extends State<FilterTasks> {
  SortOptions _sortByValue = SortOptions.creationDate;
  SortDirection _sortDirectionValue = SortDirection.descending;

  EqualityComparisons _priorityEquality = EqualityComparisons.equalTo;
  PriorityFilter? _priorityFilter;

  EffortFilter? _effortFilter;
  EqualityComparisons _costEquality = EqualityComparisons.equalTo;

  DateTime? _completeByFilter;
  EqualityComparisons _completeByEquality = EqualityComparisons.equalTo;

  DateTime? _creationDateFilter;
  EqualityComparisons _creationDateEquality = EqualityComparisons.equalTo;

  DateTime? _completionDateFilter;
  EqualityComparisons _completionDateEquality = EqualityComparisons.equalTo;

  bool _includeInactive = false;
  bool _showOnlyInProgress = false;
  List<Tag> _selectedTags = [];
  List<Contact> _selectedContacts = [];
  String? _roomIdFilter;

  final List<DropdownMenuItem<SortOptions>> _sortEntries = <DropdownMenuItem<SortOptions>>[];
  final List<DropdownMenuItem<EqualityComparisons>> _equalityEntries = <DropdownMenuItem<EqualityComparisons>>[];
  final List<DropdownMenuItem<PriorityFilter>> _priorityEntries = <DropdownMenuItem<PriorityFilter>>[];
  final List<DropdownMenuItem<EffortFilter>> _effortEntries = <DropdownMenuItem<EffortFilter>>[];
  final List<DropdownMenuItem<String>> _roomEntries = <DropdownMenuItem<String>>[];
  final TextEditingController _costFilterController = TextEditingController();
  final TextEditingController _completeByFilterController = TextEditingController();
  final TextEditingController _creationDateFilterController = TextEditingController();
  final TextEditingController _completionDateFilterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (var value in SortOptions.values) {
      _sortEntries.add(DropdownMenuItem<SortOptions>(
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
                        onChange: (tags) {
                          setState(() {
                            _selectedTags = tags;
                          });
                        }),
                    ContactCardFilter(
                        contacts: _selectedContacts,
                        onChange: (contacts) {
                          setState(() {
                            _selectedContacts = contacts;
                          });
                        }),
                    CheckboxListTile(
                      value: _includeInactive,
                      onChanged: (bool? value) {
                        setState(() {
                          _includeInactive = value ?? false;
                        });
                      },
                      title: const Text('Include Completed Tasks'),
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
                                items: _equalityEntries,
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
                                items: _equalityEntries,
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
                    Card(
                      child: Row(
                        children: [
                          const Flexible(
                            flex: 2,
                            fit: FlexFit.tight,
                            child: Text(
                              'Completion Date',
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
                                value: _completionDateEquality,
                                onChanged: (value) {
                                  setState(() {
                                    _completionDateEquality = value!;
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
                                controller: _completionDateFilterController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.date_range),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: _completionDateFilterController.text.isNotEmpty
                                      ? IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _completionDateFilterController.clear();
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
                                      _completionDateFilter = pickDate;
                                      _completionDateFilterController.text = DateFormat('yyyy-MM-dd').format(pickDate);
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

  Future<void> onSubmit() async {}
}
