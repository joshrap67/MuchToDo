import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/todo.dart';
import 'package:much_todo/src/todo_details/todo_details.dart';

class TodoCard extends StatefulWidget {
  final Todo todo;

  const TodoCard({super.key, required this.todo});

  @override
  State<TodoCard> createState() => _TodoCardState();
}

class _TodoCardState extends State<TodoCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                getIcon(),
                const Text('Priority'),
              ],
            ),
            title: Text(widget.todo.name),
            subtitle: Text(getRoom()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                child: Text(
                  getDueByDate(),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              TextButton(
                onPressed: openTodo,
                child: const Text('OPEN'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Icon getIcon() {
    if (widget.todo.priority == 1) {
      return Icon(Icons.looks_one, color: Colors.red[100]);
    } else if (widget.todo.priority == 2) {
      return Icon(Icons.looks_two, color: Colors.red[200]);
    } else if (widget.todo.priority == 3) {
      return Icon(Icons.looks_3, color: Colors.red[300]);
    } else if (widget.todo.priority == 4) {
      return Icon(Icons.looks_4, color: Colors.red[400]);
    } else {
      return Icon(Icons.looks_5, color: Colors.red[500]);
    }
  }

  String getRoom() {
    if (widget.todo.roomId == null) {
      return 'No associated room';
    } else {
      return 'Room 1'; // todo dictionary lookup
    }
  }

  String getDueByDate() {
    if (widget.todo.completeBy == null) {
      return '';
    } else {
      return 'Due ${DateFormat.yMd().format(widget.todo.completeBy!)}';
    }
  }

  String getTitle() {
    if (widget.todo.completeBy != null) {
      return '${widget.todo.name} - Due by ${DateFormat.yMd().format(widget.todo.completeBy!)}';
    } else {
      return widget.todo.name;
    }
  }

  Future<void> openTodo() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TodoDetails(todo: widget.todo)),
    );
  }
}
