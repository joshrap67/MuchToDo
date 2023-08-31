import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/screens/create_task/create_task.dart';
import 'package:much_todo/src/utils/enums.dart';
import 'package:provider/provider.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/widgets/task_card.dart';
import 'package:much_todo/src/utils/utils.dart';

class RoomTasksList extends StatefulWidget {
  final Room room;

  const RoomTasksList({super.key, required this.room});

  @override
  State<RoomTasksList> createState() => _RoomTasksListState();
}

class _RoomTasksListState extends State<RoomTasksList> {
  late List<Task> _tasks;

  TaskSortOptions _sortByValue = TaskSortOptions.creationDate;
  SortDirection _sortDirectionValue = SortDirection.descending;
  final List<DropdownMenuItem<TaskSortOptions>> _sortEntries = <DropdownMenuItem<TaskSortOptions>>[];

  @override
  void initState() {
    super.initState();
    for (var value in TaskSortOptions.values) {
      _sortEntries.add(DropdownMenuItem<TaskSortOptions>(
        value: value,
        child: Text(value.label),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    getRoomTasks();
    return Column(
      children: [
        if (_tasks.isNotEmpty)
          ListTile(
            title: Text(
              getTitle(),
              style: const TextStyle(fontSize: 22),
            ),
            subtitle: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                getSubTitle(),
                if (widget.room.note != null && widget.room.note!.isNotEmpty)
                  Text(
                    widget.room.note!,
                    style: const TextStyle(fontSize: 12),
                  )
              ],
            ),
            trailing: IconButton(
              onPressed: promptSortTasks,
              icon: const Icon(Icons.sort),
            ),
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 1, 8),
          ),
        if (_tasks.isNotEmpty)
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
        if (_tasks.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'Room has no tasks',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: OutlinedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(32.0),
              ),
            ),
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
        ),
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        showSnackbar('${result.length} Tasks created.', context);
      });
    }
  }

  void getRoomTasks() {
    _tasks = context.watch<TasksProvider>().allTasks.where((element) => element.room.id == widget.room.id).toList();
    sortRoomTasks(); // todo this will be called too often
  }

  String getTitle() {
    return _tasks.isEmpty ? 'Room has no tasks' : '${_tasks.length} Tasks';
  }

  Widget getSubTitle() {
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
        : const Text('');
  }

  void promptSortTasks() {
    showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog.adaptive(
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'OK');
                  sortRoomTasks();
                  setState(() {});
                },
                child: const Text('APPLY'),
              )
            ],
            title: const Text('Sort Tasks'),
            content: StatefulBuilder(
              builder: (statefulContext, setState) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InputDecorator(
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                labelText: 'Sort By',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<TaskSortOptions>(
                                  value: _sortByValue,
                                  onChanged: (TaskSortOptions? value) {
                                    setState(() {
                                      _sortByValue = value!;
                                    });
                                  },
                                  items: TaskSortOptions.values.map<DropdownMenuItem<TaskSortOptions>>((TaskSortOptions value) {
                                    return DropdownMenuItem<TaskSortOptions>(value: value, child: Text(value.label));
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          Padding(
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
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        });
  }

  void sortRoomTasks() {
    var tasks = _tasks;
    sortTasks(tasks, _sortByValue, _sortDirectionValue);

    _tasks = tasks;
  }
}
