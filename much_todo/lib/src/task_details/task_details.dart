import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/create_task/create_task.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/edit_task/edit_task.dart';
import 'package:much_todo/src/services/task_service.dart';
import 'package:much_todo/src/task_details/links_card_read_only.dart';
import 'package:much_todo/src/task_details/contacts_card_read_only.dart';
import 'package:much_todo/src/task_details/photos_card_read_only.dart';
import 'package:much_todo/src/task_details/room_card_read_only.dart';
import 'package:much_todo/src/task_details/tags_card_read_only.dart';
import 'package:much_todo/src/widgets/priority_indicator.dart';
import 'package:much_todo/src/utils/utils.dart';

class TaskDetails extends StatefulWidget {
  final Task task;

  const TaskDetails({super.key, required this.task});

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

enum TaskOptions { edit, duplicate, delete }

enum StatusOptions {
  notStarted(1, 'Not Started', Icon(Icons.cancel)),
  started(2, 'Started', Icon(Icons.pending)),
  completed(3, 'Completed', Icon(Icons.check));

  const StatusOptions(this.value, this.label, this.icon);

  final int value;
  final String label;
  final Icon icon;
}

class _TaskDetailsState extends State<TaskDetails> {
  late Task _task;
  StatusOptions _status = StatusOptions.notStarted;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoSizeText('Task Details'),
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
                  value: TaskOptions.duplicate,
                  child: ListTile(
                    title: Text('Duplicate'),
                    leading: Icon(Icons.copy),
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
              ];
            },
            onSelected: (TaskOptions result) => onOptionSelected(result),
          )
        ],
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  ListTile(
                    title: AutoSizeText(_task.name),
                    subtitle: _task.note != null ? Text(_task.note!) : null,
                  ),
                  Visibility(
                    visible: _task.completeBy != null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            getDueByDate(),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                  labelText: 'Status',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<StatusOptions>(
                                    value: _status,
                                    onChanged: (StatusOptions? value) {
                                      setState(() {
                                        _status = value!;
                                        // todo launch popup to select date
                                      });
                                    },
                                    items: StatusOptions.values
                                        .map<DropdownMenuItem<StatusOptions>>((StatusOptions value) {
                                      return DropdownMenuItem<StatusOptions>(value: value, child: Text(value.label));
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Card(
                          child: ListTile(
                            title: Align(
                              alignment: Alignment.topLeft,
                              child: PriorityIndicator(task: widget.task),
                            ),
                            contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
                            subtitle: const Text(
                              'Priority',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Card(
                          child: ListTile(
                            title: Text(getEffortTitle()),
                            contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
                            subtitle: const Text(
                              'Effort',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      if (_task.estimatedCost != null)
                        Flexible(
                          child: Card(
                            child: ListTile(
                              title: Text(NumberFormat.currency(symbol: '\$').format(_task.estimatedCost)),
                              subtitle: const Text(
                                'Estimated Cost',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                      Flexible(child: RoomCardReadOnly(selectedRoom: _task.room)),
                    ],
                  ),
                  if (_task.tags.isNotEmpty) TagsCardReadOnly(tags: _task.tags),
                  if (_task.contacts.isNotEmpty) ContactCardReadOnly(contacts: _task.contacts),
                  if (_task.links.isNotEmpty) LinksCardReadOnly(links: _task.links),
                  if (_task.photos.isNotEmpty) PhotosCardReadOnly(photos: _task.photos),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String getDueByDate() {
    if (_task.completeBy == null) {
      return '';
    } else {
      return 'Due ${DateFormat.yMd().format(_task.completeBy!)}';
    }
  }

  String getEffortTitle() {
    if (_task.effort == Task.lowEffort) {
      return 'Low';
    } else if (_task.effort == Task.mediumEffort) {
      return 'Medium';
    } else {
      return 'High';
    }
  }

  double getPriorityPercentage() {
    // lower priority is more important, so we want linear indicator to be reversed
    return (6 - _task.priority) / 5;
  }

  double getEffortPercentage() {
    return _task.effort / 3;
  }

  onOptionSelected(TaskOptions result) {
    switch (result) {
      case TaskOptions.edit:
        editTask();
        break;
      case TaskOptions.duplicate:
        duplicateTask();
        break;
      case TaskOptions.delete:
        promptDeleteTask();
        break;
    }
  }

  void promptDeleteTask() {
    showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deleteTask();
                },
                child: const Text('DELETE'),
              )
            ],
            insetPadding: const EdgeInsets.all(8.0),
            title: const Text('Delete Task'),
            content: const Text('Are you sure you wish to delete this task?'),
          );
        });
  }

  Future<void> deleteTask() async {
    var deleted = await TaskService.deleteTask(context, widget.task);
    if (context.mounted && deleted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> editTask() async {
    Task? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTask(
          task: _task,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _task = result;
      });
    }
  }

  Future<void> duplicateTask() async {
    List<Task>? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateTask(
          task: _task,
        ),
      ),
    );
    if (result != null && result.isNotEmpty && context.mounted) {
      var msg = result.length == 1 ? 'Task created' : '${result.length} Tasks created';
      showSnackbar(msg, context);
    }
  }

// todo allow for notifications?
}
