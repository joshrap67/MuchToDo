import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/todo.dart';
import 'package:much_todo/src/todo_details/links_card_read_only.dart';
import 'package:much_todo/src/todo_details/people_card_read_only.dart';
import 'package:much_todo/src/todo_details/photos_card_read_only.dart';
import 'package:much_todo/src/todo_details/room_card_read_only.dart';
import 'package:much_todo/src/todo_details/tags_card_read_only.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class TodoDetails extends StatefulWidget {
  final Todo todo;

  const TodoDetails({super.key, required this.todo});

  @override
  State<TodoDetails> createState() => _TodoDetailsState();
}

class _TodoDetailsState extends State<TodoDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To Do Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              widget.todo.name,
              style: const TextStyle(fontSize: 40),
            ),
            Text(
              getDueByDate(),
              style: const TextStyle(fontSize: 26),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: [
                  const Text('Priority'),
                  LinearPercentIndicator(
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 12.0, 0, 0),
                    child: Text('Effort'),
                  ),
                  LinearPercentIndicator(
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
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                    child: RoomCardReadOnly(selectedRoom: getRoom()),
                  ),
                  if (widget.todo.tags.isNotEmpty) TagsCardReadOnly(tags: widget.todo.tags),
                  if (widget.todo.professionals.isNotEmpty) PeopleCardReadOnly(people: widget.todo.professionals),
                  if (widget.todo.links.isNotEmpty) LinksCardReadOnly(links: widget.todo.links),
                  if (widget.todo.pictures.isNotEmpty) PhotosCardReadOnly(photos: widget.todo.pictures),
                ],
              ),
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

// todo allow for notifications?
}
