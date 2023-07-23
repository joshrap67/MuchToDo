import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/todo.dart';
import 'package:much_todo/src/edit_todo/edit_todo.dart';
import 'package:much_todo/src/todo_details/links_card_read_only.dart';
import 'package:much_todo/src/todo_details/people_card_read_only.dart';
import 'package:much_todo/src/todo_details/photos_card_read_only.dart';
import 'package:much_todo/src/todo_details/room_card_read_only.dart';
import 'package:much_todo/src/todo_details/tags_card_read_only.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../utils/utils.dart';

class TodoDetails extends StatefulWidget {
  final Todo todo;

  const TodoDetails({super.key, required this.todo});

  @override
  State<TodoDetails> createState() => _TodoDetailsState();
}

enum TodoOptions { edit, duplicate }

class _TodoDetailsState extends State<TodoDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoSizeText('To Do Details'),
        actions: [
          IconButton(onPressed: promptDeleteTodo, icon: const Icon(Icons.delete)),
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
                PopupMenuItem<TodoOptions>(
                  value: TodoOptions.edit,
                  child: ListTile(
                    title: const Text('Edit'),
                    leading: const Icon(Icons.edit),
                    contentPadding: const EdgeInsets.all(0),
                    onTap: editTodo,
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
              ];
            },
            onSelected: (TodoOptions result) => onOptionSelected(result),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(
                    title: AutoSizeText(widget.todo.name),
                    subtitle: widget.todo.note != null ? Text(widget.todo.note!) : null,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                        child: widget.todo.completeBy != null
                            ? Text(
                                getDueByDate(),
                                style: const TextStyle(fontSize: 11),
                              )
                            : const Text(''),
                      ),
                      TextButton(
                        child: const Text('COMPLETE TO DO'),
                        onPressed: () {
                          /* ... */
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Text('Priority'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: LinearPercentIndicator(
                    lineHeight: 20.0,
                    leading: const Text("Lowest"),
                    trailing: const Text("Highest"),
                    percent: getPriorityPercentage(),
                    center: Text(
                      widget.todo.priority.toString(),
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    barRadius: const Radius.circular(15.0),
                    backgroundColor: const Color(0xffb8c7cb),
                    progressColor: Colors.red[300],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 12.0, 0, 0),
                  child: Text('Effort'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: LinearPercentIndicator(
                    lineHeight: 20.0,
                    leading: const Text("Lowest"),
                    trailing: const Text("Highest"),
                    percent: getEffortPercentage(),
                    center: Text(
                      widget.todo.priority.toString(),
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    barRadius: const Radius.circular(15.0),
                    backgroundColor: const Color(0xffb8c7cb),
                    progressColor: Colors.green[400],
                  ),
                ),
                const Padding(padding: EdgeInsets.fromLTRB(0, 12, 0, 0)),
                if (widget.todo.approximateCost != null)
                  Card(
                    child: ListTile(
                      title: Text('\$${widget.todo.approximateCost}'),
                      subtitle: const Text('Approximate Cost'),
                    ),
                  ),
                RoomCardReadOnly(selectedRoom: getRoom()),
                if (widget.todo.tags.isNotEmpty) TagsCardReadOnly(tags: widget.todo.tags),
                if (widget.todo.professionals.isNotEmpty) PeopleCardReadOnly(people: widget.todo.professionals),
                if (widget.todo.links.isNotEmpty) LinksCardReadOnly(links: widget.todo.links),
                if (widget.todo.pictures.isNotEmpty) PhotosCardReadOnly(photos: widget.todo.pictures),
              ],
            )
          ],
        ),
      ),
    );
  }

  Room? getRoom() {
    if (widget.todo.roomId == null) {
      return null;
    } else {
      return Room('a', 'Bedroom', []);
    }
  }

  String getDueByDate() {
    if (widget.todo.completeBy == null) {
      return '';
    } else {
      return 'Due ${DateFormat.yMd().format(widget.todo.completeBy!)}';
    }
  }

  double getPriorityPercentage() {
    return widget.todo.priority / 5;
  }

  double getEffortPercentage() {
    return widget.todo.effort / 5;
  }

  onOptionSelected(TodoOptions result) {}

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
          todo: widget.todo,
        ),
      ),
    );
  }

// todo allow for notifications?
}
