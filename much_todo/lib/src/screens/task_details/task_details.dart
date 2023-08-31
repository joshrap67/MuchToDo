import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/task.dart' as task_domain;
import 'package:much_todo/src/screens/create_task/create_task.dart';
import 'package:much_todo/src/screens/edit_task/edit_task.dart';
import 'package:much_todo/src/screens/task_details/contacts_card_read_only.dart';
import 'package:much_todo/src/screens/task_details/links_card_read_only.dart';
import 'package:much_todo/src/screens/task_details/photos_card_read_only.dart';
import 'package:much_todo/src/screens/task_details/room_card_read_only.dart';
import 'package:much_todo/src/screens/task_details/tags_card_read_only.dart';
import 'package:much_todo/src/services/task_service.dart';
import 'package:much_todo/src/widgets/priority_indicator.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/skeletons/photos_card_skeleton.dart';

class TaskDetails extends StatefulWidget {
  final task_domain.Task task;

  const TaskDetails({super.key, required this.task});

  @override
  State<TaskDetails> createState() => _TaskDetailsState();
}

enum TaskOptions { edit, duplicate, delete }

enum StatusOptions {
  notStarted(1, 'Not Started', Icon(Icons.cancel)),
  started(2, 'In Progress', Icon(Icons.pending));

  const StatusOptions(this.value, this.label, this.icon);

  final int value;
  final String label;
  final Icon icon;
}

class _TaskDetailsState extends State<TaskDetails> {
  late task_domain.Task _task;
  StatusOptions _status = StatusOptions.notStarted;
  late Future<List<String>> _photoUrls; // doing it like this to avoid hassle of having awaits everywhere to get url

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    _photoUrls = loadPhotos();
    if (_task.inProgress) {
      _status = StatusOptions.started;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: getAppBarTitle(),
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
      body: Column(
        children: [
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                                              setStatus(value);
                                            });
                                          },
                                          items: StatusOptions.values
                                              .map<DropdownMenuItem<StatusOptions>>((StatusOptions value) {
                                            return DropdownMenuItem<StatusOptions>(
                                                value: value, child: Text(value.label));
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
                                    child: PriorityIndicator(priority: _task.priority),
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
                                  title: Text(getEffortTitle(_task.effort)),
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
                        if (_task.note != null && _task.note!.isNotEmpty)
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  child: ListTile(
                                    title: Text(_task.note!),
                                    subtitle: const Text(
                                      'Note',
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
                            Flexible(
                              child: RoomCardReadOnly(selectedRoom: _task.room),
                            ),
                            // todo allow click to go to room?
                          ],
                        ),
                        if (_task.tags.isNotEmpty) TagsCardReadOnly(tags: _task.tags),
                        if (_task.contacts.isNotEmpty) ContactCardReadOnly(contacts: _task.contacts),
                        if (_task.links.isNotEmpty) LinksCardReadOnly(links: _task.links),
                        FutureBuilder(
                            future: _photoUrls,
                            builder: (BuildContext context, AsyncSnapshot<List<String>> photos) {
                              if (photos.hasData && !photos.hasError) {
                                return PhotosCardReadOnly(
                                  photos: photos.data!,
                                  taskId: _task.id,
                                  onSetPhotos: (task) => onPhotosUpdated(task),
                                );
                              } else if (photos.hasError) {
                                return const Center(child: Icon(Icons.broken_image));
                              } else {
                                return const PhotoCardSkeleton();
                              }
                            }),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
            child: ElevatedButton.icon(
              onPressed: promptCompleteTask,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
              ),
              icon: const Icon(Icons.done),
              label: const Text('COMPLETE TASK'),
            ),
          )
        ],
      ),
    );
  }

  Widget getAppBarTitle() {
    if (_task.completeBy != null) {
      return ListTile(
        title: AutoSizeText(
          _task.name,
          minFontSize: 10,
          maxLines: 1,
        ),
        subtitle: Text('Due ${DateFormat.yMd().format(_task.completeBy!)}'),
        contentPadding: EdgeInsets.zero,
      );
    } else {
      return AutoSizeText(
        _task.name,
        minFontSize: 10,
        maxLines: 1,
      );
    }
  }

  void setStatus(StatusOptions status) {
    TaskService.setTaskProgress(context, _task.id, status == StatusOptions.started);
  }

  Future<List<String>> loadPhotos() async {
    if (_task.photos.isEmpty) {
      return [];
    }
    final storageRef = FirebaseStorage.instance.ref();
    try {
      var urls = <String>[];
      for (var photo in _task.photos) {
        var url = await storageRef.child(photo).getDownloadURL();
        urls.add(url);
      }
      return urls;
    } catch (e) {
      return Future.error('error');
    }
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
          return AlertDialog.adaptive(
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

  Future<void> promptCompleteTask() async {
    DateTime? pickDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1800),
        helpText: 'Select Completion Date',
        lastDate: DateTime(2100));
    if (pickDate != null) {
      if (context.mounted) {
        showLoadingDialog(context, msg: 'Completing...');
        await TaskService.completeTask(context, _task, pickDate);
        if (context.mounted) {
          closePopup(context);
          Navigator.of(context).pop; // todo not popping for some reason...
        }
      }
    }
  }

  Future<void> deleteTask() async {
    showLoadingDialog(context, msg: 'Deleting...');
    var deleted = await TaskService.deleteTask(context, _task);
    if (context.mounted) {
      closePopup(context);
    }
    if (context.mounted && deleted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> editTask() async {
    task_domain.Task? result = await Navigator.push(
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

  Future<void> onPhotosUpdated(task_domain.Task? task) async {
    if (task != null) {
      setState(() {
        _task = task;
        _photoUrls = loadPhotos();
      });
    }
  }

  Future<void> duplicateTask() async {
    // todo route to new task?
    List<task_domain.Task>? result = await Navigator.push(
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
}
