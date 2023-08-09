import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:uuid/uuid.dart';

import '../createTodo/create_todo.dart';
import '../domain/todo.dart';
import '../filter/filter_todos.dart';
import '../todo_list/todo_card.dart';
import '../utils/utils.dart';

class RoomsListTodos extends StatefulWidget {
  final List<Todo> todos;
  final Room room;

  const RoomsListTodos({super.key, required this.room, required this.todos});

  @override
  State<RoomsListTodos> createState() => _RoomsListTodosState();
}

class _RoomsListTodosState extends State<RoomsListTodos> {
  late List<Todo> _todos;

  SortOptions _sortByValue = SortOptions.creationDate;
  SortDirection _sortDirectionValue = SortDirection.descending;
  bool _includeInactive = false;
  final List<DropdownMenuItem<SortOptions>> _sortEntries = <DropdownMenuItem<SortOptions>>[];

  @override
  void initState() {
    super.initState();
    // for testing purposes todo remove
    widget.todos.add(Todo.named(
        id: Uuid().v4(), name: 'Inactive', priority: 1, effort: 1, createdBy: 'createdBy', isCompleted: true, room: TodoRoom('id', 'Name')));
    _todos = [...widget.todos];
    sortAndFilterTodos();
    for (var value in SortOptions.values) {
      _sortEntries.add(DropdownMenuItem<SortOptions>(
        value: value,
        child: Text(value.label),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        Card(
          child: ListTile(
            title: Text(getTitle()),
            subtitle: Text(getSubTitle()),
            trailing: IconButton(
              onPressed: filterTodos,
              icon: const Icon(Icons.filter_list_sharp),
            ),
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 1, 8),
          ),
        ),
        Expanded(
          child: Scrollbar(
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (ctx, index) {
                var todo = _todos[index];
                return TodoCard(
                  todo: todo,
                  showRoom: false,
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: launchAddTodo,
            icon: const Icon(Icons.add),
            label: const Text('CREATE NEW TODO'),
          ),
        )
      ],
    );
  }

  Future<void> launchAddTodo() async {
	  List<Todo>? result = await Navigator.push(
		  context,
		  MaterialPageRoute(builder: (context) => CreateTodo(room: widget.room,)),
	  );
	  // todo need to verify todo list gets this todo properly with the provider. i don't think it will since i need to manually tell it to rebuild
	  if (result != null && result.isNotEmpty) {
		  setState(() {
			  _todos.addAll(result);
			  showSnackbar('${result.length} To Dos created.', context);
		  });
	  }
  }

  String getTitle() {
    return _todos.isEmpty ? 'Room has no associated To Dos' : '${_todos.length} To Dos';
  }

  String getSubTitle() {
    // todo need to make clear on todo list that it only includes aggregated cost of non completed ones
    var totalCost = 0.0;
    for (var e in _todos) {
      if (e.estimatedCost != null) {
        totalCost += e.estimatedCost!;
      }
    }
    return _todos.isEmpty ? '' : '${NumberFormat.currency(symbol: '\$').format(totalCost)} Total Estimated Cost';
  }

  void filterTodos() {
    // todo max amount check
    showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'OK');
                  sortAndFilterTodos();
                  setState(() {});
                },
                child: const Text('APPLY'),
              )
            ],
            insetPadding: const EdgeInsets.all(8.0),
            title: const Text('Filter & Sort'),
            content: StatefulBuilder(
              builder: (statefulContext, setState) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
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
                      CheckboxListTile(
                        value: _includeInactive,
                        onChanged: (bool? value) {
                          setState(() {
                            _includeInactive = value ?? false;
                          });
                        },
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                        title: const Text('Include Completed To Dos'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        });
  }

  void sortAndFilterTodos() {
    var todos = widget.todos.where((element) => _includeInactive || !element.isCompleted).toList();
    // initially ascending
    switch (_sortByValue) {
      case SortOptions.name:
        todos.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOptions.priority:
        // todo ugh so ascending in this case will be 1..5 but it might be confusing since its not ascending in terms of semantic priority but the actual nubmer (lower number is higher priortity)
        todos.sort((a, b) => a.priority.compareTo(b.priority));
        break;
      case SortOptions.effort:
        todos.sort((a, b) => a.effort.compareTo(b.effort));
        break;
      case SortOptions.room:
        todos.sort((a, b) => a.room?.name.compareTo(b.room?.name ?? '') ?? -1); // todo ugh
        break;
      case SortOptions.cost:
        todos.sort((a, b) => a.estimatedCost?.compareTo(b.estimatedCost ?? 0.0) ?? -1); // todo ugh
        break;
      case SortOptions.creationDate:
        todos.sort((a, b) => a.creationDate?.compareTo(b.creationDate ?? DateTime(1970)) ?? -1); // todo ugh
        break;
      case SortOptions.dueBy:
        todos.sort((a, b) => a.completeBy?.compareTo(b.completeBy ?? DateTime(1970)) ?? -1); // todo ugh
        break;
      case SortOptions.inProgress:
        todos.sort((a, b) {
          if (b.inProgress) {
            // ones that are in progress are on top in ascending
            return 1;
          }
          return -1;
        });
        break;
      case SortOptions.completed:
        todos.sort((a, b) {
          if (b.isCompleted) {
            // ones that are completed are on top in ascending
            return 1;
          }
          return -1;
        });
        break;
    }
    if (_sortDirectionValue == SortDirection.descending) {
      todos = todos.reversed.toList();
    }

    _todos = todos;
  }
}
