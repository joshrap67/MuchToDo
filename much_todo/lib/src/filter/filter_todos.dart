import 'package:flutter/material.dart';

class FilterTodos extends StatefulWidget {
  const FilterTodos({super.key});

  @override
  State<FilterTodos> createState() => _FilterTodosState();
}

enum SortOptions {
  name(0, 'Name'),
  priority(1, 'Priority'),
  effort(2, 'Effort'),
  room(2, 'Room Name'),
  cost(2, 'Approximate Cost'),
  creationDate(2, 'Creation Date'),
  dueBy(2, 'Due By'),
  completed(2, 'Completed'),
  inProgress(2, 'In Progress');

  const SortOptions(this.value, this.label);

  final int value; // using since i will probably want to store these in local prefs
  final String label;
}

enum EqualityComparisons {
  greaterThan(0, 'Greater Than'),
  greaterThanOrEqualTo(1, 'Greater Than or Equal To'),
  equalTo(2, 'Equal To'),
  lessThan(3, 'Less Than'),
  lessThanOrEqualTo(4, 'Less Than or Equal To');

  const EqualityComparisons(this.value, this.label);

  final int value; // using since i will probably want to store these in local prefs
  final String label;
}

enum PriorityFilter {
  greaterThan(0, '1'),
  greaterThanOrEqualTo(1, '2'),
  equalTo(2, '3'),
  lessThan(3, '4'),
  lessThanOrEqualTo(4, '5');

  const PriorityFilter(this.value, this.label);

  final int value; // using since i will probably want to store these in local prefs
  final String label;
}

class _FilterTodosState extends State<FilterTodos> {
  SortOptions _sortByValue = SortOptions.creationDate;
  EqualityComparisons _priorityEquality = EqualityComparisons.equalTo;
  PriorityFilter? _priorityFilter;

  final List<DropdownMenuItem<SortOptions>> _sortEntries = <DropdownMenuItem<SortOptions>>[];
  final List<DropdownMenuItem<EqualityComparisons>> _equalityEntries = <DropdownMenuItem<EqualityComparisons>>[];
  final List<DropdownMenuItem<PriorityFilter>> _priorityEntries = <DropdownMenuItem<PriorityFilter>>[];

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter To Dos'),
      ),
      body: Column(
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
                    'Priority',
                    textAlign: TextAlign.center,
                  ),
                ),
                Flexible(
                  flex: 3,
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
                  flex: 2,
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
          // sort by
          // priority filter >, >=, ==, <=, <
          // effort filter >, >=, ==, <=, <
          // filter by room
          // filter by cost? >, >=, ==, <=, <
          // select tags
          // select people
          // is completed
          // in progress
          // complete by >, >=, ==, <=, <
          // creation date >, >=, ==, <=, <
        ],
      ),
    );
  }
}
