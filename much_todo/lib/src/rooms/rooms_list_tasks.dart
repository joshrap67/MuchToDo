import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:uuid/uuid.dart';
import 'package:much_todo/src/create_task/create_task.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/filter/filter_tasks.dart';
import 'package:much_todo/src/task_list/task_card.dart';
import 'package:much_todo/src/utils/utils.dart';

class RoomsListTasks extends StatefulWidget {
  final List<Task> tasks;
  final Room room;

  const RoomsListTasks({super.key, required this.room, required this.tasks});

  @override
  State<RoomsListTasks> createState() => _RoomsListTasksState();
}

class _RoomsListTasksState extends State<RoomsListTasks> {
  late List<Task> _tasks;

  SortOptions _sortByValue = SortOptions.creationDate;
  SortDirection _sortDirectionValue = SortDirection.descending;
  bool _includeInactive = false;
  final List<DropdownMenuItem<SortOptions>> _sortEntries = <DropdownMenuItem<SortOptions>>[];

  @override
  void initState() {
    super.initState();
    // for testing purposes todo remove
    widget.tasks.add(Task.named(
        id: const Uuid().v4(),
        name: 'Inactive',
        priority: 1,
        effort: 1,
        createdBy: 'createdBy',
        isCompleted: true,
        room: TaskRoom('id', 'Name')));
    _tasks = [...widget.tasks];
    sortAndFilterTasks();
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
        ListTile(
          title: Text(
            getTitle(),
            style: const TextStyle(fontSize: 22),
          ),
          subtitle: getSubTitle(),
          trailing: IconButton(
            onPressed: filterTasks,
            icon: const Icon(Icons.filter_list_sharp),
          ),
          contentPadding: const EdgeInsets.fromLTRB(16, 8, 1, 8),
        ),
        Expanded(
          child: Scrollbar(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (ctx, index) {
                var task = _tasks[index];
                return TaskCard(task: task, showRoom: false);
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: launchAddTask,
            icon: const Icon(Icons.add),
            label: const Text('CREATE NEW TASK'),
          ),
        )
      ],
    );
  }

  Future<void> launchAddTask() async {
    List<Task>? result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateTask(
                room: widget.room,
              )),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _tasks.addAll(result);
        showSnackbar('${result.length} Tasks created.', context);
      });
    }
  }

  String getTitle() {
    return _tasks.isEmpty ? 'Room has no associated Tasks' : '${_tasks.length} Tasks';
  }

  Widget? getSubTitle() {
    // todo need to make clear on task list that it only includes aggregated cost of non completed ones
    var totalCost = 0.0;
    for (var e in _tasks) {
      if (e.estimatedCost != null) {
        totalCost += e.estimatedCost!;
      }
    }
    return _tasks.isNotEmpty
        ? Text(
            '${NumberFormat.currency(symbol: '\$').format(totalCost)} Total Estimated Cost',
            style: const TextStyle(fontSize: 12),
          )
        : null;
  }

  void filterTasks() {
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
                  sortAndFilterTasks();
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
                        title: const Text('Include Completed Tasks'),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        });
  }

  void sortAndFilterTasks() {
    var tasks = widget.tasks.where((element) => _includeInactive || !element.isCompleted).toList();
    // initially ascending
    switch (_sortByValue) {
      case SortOptions.name:
        tasks.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOptions.priority:
        tasks.sort((a, b) => a.priority.compareTo(b.priority));
        break;
      case SortOptions.effort:
        tasks.sort((a, b) => a.effort.compareTo(b.effort));
        break;
      case SortOptions.room:
        tasks.sort((a, b) => a.room.name.compareTo(b.room.name));
        break;
      case SortOptions.cost:
        tasks.sort((a, b) => a.estimatedCost?.compareTo(b.estimatedCost ?? 0.0) ?? -1); // todo ugh
        break;
      case SortOptions.creationDate:
        tasks.sort((a, b) => a.creationDate?.compareTo(b.creationDate ?? DateTime(1970)) ?? -1); // todo ugh
        break;
      case SortOptions.dueBy:
        tasks.sort((a, b) => a.completeBy?.compareTo(b.completeBy ?? DateTime(1970)) ?? -1); // todo ugh
        break;
      case SortOptions.inProgress:
        tasks.sort((a, b) {
          if (b.inProgress) {
            // ones that are in progress are on top in ascending
            return 1;
          }
          return -1;
        });
        break;
      case SortOptions.completed:
        tasks.sort((a, b) {
          if (b.isCompleted) {
            // ones that are completed are on top in ascending
            return 1;
          }
          return -1;
        });
        break;
    }
    if (_sortDirectionValue == SortDirection.descending) {
      tasks = tasks.reversed.toList();
    }

    _tasks = tasks;
  }
}
