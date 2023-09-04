import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/screens/create_task/create_task.dart';
import 'package:much_todo/src/widgets/completed_tasks/completed_tasks.dart';
import 'package:much_todo/src/services/rooms_service.dart';
import 'package:much_todo/src/utils/enums.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/utils/validation.dart';
import 'package:much_todo/src/widgets/sort_direction_button.dart';
import 'package:much_todo/src/widgets/task_card.dart';
import 'package:provider/provider.dart';

class RoomDetails extends StatefulWidget {
  final Room room;

  const RoomDetails({super.key, required this.room});

  @override
  State<RoomDetails> createState() => _RoomDetailsState();
}

enum TaskOptions { edit, delete, showCompletedTasks }

class _RoomDetailsState extends State<RoomDetails> {
  late Room _room;
  late List<Task> _tasks;

  TaskSortOption _sortByValue = TaskSortOption.creationDate;
  SortDirection _sortDirectionValue = SortDirection.descending;
  final List<DropdownMenuItem<TaskSortOption>> _sortEntries = <DropdownMenuItem<TaskSortOption>>[];

  @override
  void initState() {
    super.initState();
    for (var value in TaskSortOption.values) {
      _sortEntries.add(DropdownMenuItem<TaskSortOption>(
        value: value,
        child: Text(value.label),
      ));
    }
    _room = widget.room;
  }

  @override
  Widget build(BuildContext context) {
    getRoomTasks();
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(_room.name),
        scrolledUnderElevation: 0,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More',
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15.0),
              ),
            ),
            itemBuilder: (context) {
              hideKeyboard();
              return <PopupMenuEntry<TaskOptions>>[
                const PopupMenuItem<TaskOptions>(
                  value: TaskOptions.edit,
                  child: ListTile(
                    title: Text('Edit'),
                    leading: Icon(Icons.edit),
                    contentPadding: EdgeInsets.all(0),
                  ),
                ),
                const PopupMenuItem<TaskOptions>(
                  value: TaskOptions.delete,
                  child: ListTile(
                    title: Text('Delete'),
                    leading: Icon(Icons.delete),
                    contentPadding: EdgeInsets.all(0),
                  ),
                ),
                const PopupMenuItem<TaskOptions>(
                  value: TaskOptions.showCompletedTasks,
                  child: ListTile(
                    title: Text('Completed Tasks'),
                    leading: Icon(Icons.done),
                    contentPadding: EdgeInsets.all(0),
                  ),
                ),
              ];
            },
            onSelected: (TaskOptions result) => onOptionSelected(result),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
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
                      if (_room.note != null && _room.note!.isNotEmpty)
                        Text(
                          _room.note!,
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
                        padding: const EdgeInsets.only(bottom: 75),
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
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: launchAddTask,
        label: const Text('CREATE NEW TASK'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  onOptionSelected(TaskOptions result) {
    switch (result) {
      case TaskOptions.edit:
        promptEditRoom();
        break;
      case TaskOptions.delete:
        promptDeleteRoom();
        break;
      case TaskOptions.showCompletedTasks:
        showCompletedRooms();
        break;
    }
  }

  Future<void> promptEditRoom() async {
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    final nameController = TextEditingController(text: _room.name);
    final noteController = TextEditingController(text: _room.note);

    await showDialog<void>(
      context: context,
      barrierDismissible: !isLoading,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setState) {
            return AlertDialog.adaptive(
              actions: <Widget>[
                if (!isLoading)
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('CANCEL'),
                  ),
                TextButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      await editRoom(dialogContext, nameController.text, noteController.text);
                      setState(() {
                        isLoading = false;
                      });
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    }
                  },
                  child: isLoading ? const CircularProgressIndicator() : const Text('SAVE'),
                )
              ],
              insetPadding: const EdgeInsets.all(8.0),
              title: const Text('Edit Room'),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: MediaQuery.of(dialogContext).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Room name *'),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.name,
                        controller: nameController,
                        validator: validRoomName,
                      ),
                      const Padding(padding: EdgeInsets.all(8)),
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Note'),
                          border: OutlineInputBorder(),
                        ),
                        controller: noteController,
                        validator: validRoomNote,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void getRoomTasks() {
    _tasks = context.watch<TasksProvider>().allTasks.where((element) => element.room.id == _room.id).toList();
    sortRoomTasks();
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
    return Text(
      '${NumberFormat.currency(symbol: '\$').format(totalCost)} Total Estimated Cost',
      style: const TextStyle(fontSize: 12),
    );
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
                              child: DropdownButton<TaskSortOption>(
                                value: _sortByValue,
                                onChanged: (TaskSortOption? value) {
                                  setState(() {
                                    _sortByValue = value!;
                                  });
                                },
                                items:
                                    TaskSortOption.values.map<DropdownMenuItem<TaskSortOption>>((TaskSortOption value) {
                                  return DropdownMenuItem<TaskSortOption>(value: value, child: Text(value.label));
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        Padding(
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
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void sortRoomTasks() {
    var tasks = _tasks;
    sortTasks(tasks, _sortByValue, _sortDirectionValue);

    _tasks = tasks;
  }

  Future<void> launchAddTask() async {
    Task? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTask(
          room: _room,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        showSnackbar('Task created', context);
      });
    }
  }

  Future<void> editRoom(BuildContext context, String name, String? note) async {
    hideKeyboard();
    var result = await RoomsService.editRoom(context, _room.id, name, note);
    if (result.success) {
      setState(() {
        _room.update(name.trim(), note?.trim());
      });
    } else if (context.mounted) {
      showSnackbar(result.errorMessage!, context);
    }
  }

  void showCompletedRooms() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompletedTasks(room: _room),
      ),
    );
  }

  void promptDeleteRoom() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog.adaptive(
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteRoom();
              },
              child: const Text('DELETE'),
            )
          ],
          title: const Text('Delete Room'),
          content: const Text(
            'Are you sure you wish to delete this room?\n\nALL tasks associated with this room will be deleted!',
          ),
        );
      },
    );
  }

  Future<void> deleteRoom() async {
    showLoadingDialog(context, msg: 'Deleting...');
    var result = await RoomsService.deleteRoom(context, _room);
    if (context.mounted && result.success) {
      closePopup(context);
      Navigator.of(context).pop();
    } else if (context.mounted && result.failure) {
      closePopup(context);
      showSnackbar(result.errorMessage!, context);
    }
  }
}
