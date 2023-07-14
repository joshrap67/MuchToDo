import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/todo.dart';

class TodoCard extends StatelessWidget {
  final Todo todo;

  const TodoCard({super.key, required this.todo});

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
            title: Text(todo.name),
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
                child: const Text('OPEN'),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Icon getIcon() {
    if (todo.priority == 1) {
      return const Icon(Icons.looks_one);
    } else if (todo.priority == 2) {
      return Icon(Icons.looks_two, color: Colors.red[200]);
    } else if (todo.priority == 3) {
      return Icon(Icons.looks_3, color: Colors.red[300]);
    } else if (todo.priority == 4) {
      return Icon(Icons.looks_4, color: Colors.red[400]);
    } else {
      return Icon(Icons.looks_5, color: Colors.red[500]);
    }
  }

  String getRoom() {
    if (todo.roomId == null) {
      return 'No associated room';
    } else {
      return 'Room 1'; // todo dictionary lookup
    }
  }

  String getDueByDate() {
    if (todo.completeBy == null) {
      return '';
    } else {
      return 'Due by ${DateFormat.yMd().format(todo.completeBy!)}';
    }
  }

  String getTitle() {
    if (todo.completeBy != null) {
      return '${todo.name} - Due by ${DateFormat.yMd().format(todo.completeBy!)}';
    } else {
      return todo.name;
    }
  }
}
