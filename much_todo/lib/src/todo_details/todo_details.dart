import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/todo.dart';
import 'package:much_todo/src/edit_todo/edit_todo.dart';
import 'package:much_todo/src/todo_details/links_card_read_only.dart';
import 'package:much_todo/src/todo_details/people_card_read_only.dart';
import 'package:much_todo/src/todo_details/photos_card_read_only.dart';
import 'package:much_todo/src/todo_details/room_card_read_only.dart';
import 'package:much_todo/src/todo_details/tags_card_read_only.dart';

import '../utils/utils.dart';

class TodoDetails extends StatefulWidget {
  final Todo todo;

  const TodoDetails({super.key, required this.todo});

  @override
  State<TodoDetails> createState() => _TodoDetailsState();
}

enum TodoOptions { edit, duplicate, delete }

class _TodoDetailsState extends State<TodoDetails> {
  late Todo _todo;

  @override
  void initState() {
    super.initState();
    _todo = widget.todo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoSizeText('To Do Details'),
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
              return <PopupMenuEntry<TodoOptions>>[
                const PopupMenuItem<TodoOptions>(
                  value: TodoOptions.edit,
                  child: ListTile(
                    title: Text('Edit'),
                    leading: Icon(Icons.edit),
                    contentPadding: EdgeInsets.all(0),
                  ),
                ),
                const PopupMenuItem<TodoOptions>(
                  value: TodoOptions.duplicate,
                  child: ListTile(
                    title: Text('Duplicate'),
                    leading: Icon(Icons.copy),
                    contentPadding: EdgeInsets.all(0),
                  ),
                ),
                const PopupMenuItem<TodoOptions>(
                  value: TodoOptions.delete,
                  child: ListTile(
                    title: Text('Delete'),
                    leading: Icon(Icons.delete),
                    contentPadding: EdgeInsets.all(0),
                  ),
                ),
              ];
            },
            onSelected: (TodoOptions result) => onOptionSelected(result),
          )
        ],
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: AutoSizeText(_todo.name),
                      subtitle: _todo.note != null ? Text(_todo.note!) : null,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: _todo.completeBy != null
                              ? Text(
                                  getDueByDate(),
                                  style: const TextStyle(fontSize: 11),
                                )
                              : const Text(''),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.pending),
                          label: const Text('START'),
                          onPressed: () {},
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('COMPLETE'),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Flexible(
                        child: Card(
                          child: ListTile(
                            title: Text(_todo.priority.toString()),
                            contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
                            subtitle: const Text('Priority'),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Card(
                          child: ListTile(
                            title: Text(getEffortTitle()),
                            contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
                            subtitle: const Text('Effort'),
                          ),
                        ),
                      )
                    ],
                  ),
                  Row(
                    children: [
                      if (_todo.estimatedCost != null)
                        Flexible(
                          child: Card(
                            child: ListTile(
                              title: Text(NumberFormat.currency(symbol: '\$').format(_todo.estimatedCost)),
                              subtitle: const Text('Estimated Cost'),
                            ),
                          ),
                        ),
                      Flexible(child: RoomCardReadOnly(selectedRoom: _todo.room)),
                    ],
                  ),
                  if (_todo.tags.isNotEmpty) TagsCardReadOnly(tags: _todo.tags),
                  if (_todo.people.isNotEmpty) PeopleCardReadOnly(people: _todo.people),
                  if (_todo.links.isNotEmpty) LinksCardReadOnly(links: _todo.links),
                  if (_todo.photos.isNotEmpty) PhotosCardReadOnly(photos: _todo.photos),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String getDueByDate() {
    if (_todo.completeBy == null) {
      return '';
    } else {
      return 'Due ${DateFormat.yMd().format(_todo.completeBy!)}';
    }
  }

  String getEffortTitle() {
    if (_todo.effort == Todo.lowEffort) {
      return 'Low';
    } else if (_todo.effort == Todo.mediumEffort) {
      return 'Medium';
    } else {
      return 'High';
    }
  }

  double getPriorityPercentage() {
    // lower priority is more important, so we want linear indicator to be reversed
    return (6 - _todo.priority) / 5;
  }

  double getEffortPercentage() {
    return _todo.effort / 3;
  }

  onOptionSelected(TodoOptions result) {
    switch (result) {
      case TodoOptions.edit:
        editTodo();
        break;
      case TodoOptions.duplicate:
        break;
      case TodoOptions.delete:
        promptDeleteTodo();
        break;
    }
  }

  void promptDeleteTodo() {
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
                },
                child: const Text('DELETE'),
              )
            ],
            insetPadding: const EdgeInsets.all(8.0),
            title: const Text('Delete To Do'),
            content: const Text('Are you sure you wish to delete this To Do?'),
          );
        });
  }

  Future<void> editTodo() async {
    Todo? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditTodo(
          todo: _todo,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _todo = result;
      });
    }
  }

// todo allow for notifications?
}
