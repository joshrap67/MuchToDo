import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/screens/task_details/task_details.dart';
import 'package:much_todo/src/widgets/priority_indicator.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final bool showRoom;

  const TaskCard({super.key, required this.task, this.showRoom = true});

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
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
                PriorityIndicator(priority: widget.task.priority),
                const Text('Priority'),
              ],
            ),
            title: Text(widget.task.name),
            subtitle: widget.showRoom ? Text(getRoom()) : const Text(''),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                child: Text(
                  getBottomLeftWidget(),
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              TextButton(
                onPressed: openTask,
                child: const Text('OPEN'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // todo show one row of tags? if overflow say something like (+2)
  String getRoom() {
    return widget.task.room.name;
  }

  String getBottomLeftWidget() {
    if (widget.task.completeBy == null) {
      return '';
    } else {
      return 'Due ${DateFormat.yMd().format(widget.task.completeBy!)}';
    }
    // todo bold when close to date? if past date indicate?
  }

  String getTitle() {
    if (widget.task.completeBy != null) {
      return '${widget.task.name} - Due by ${DateFormat.yMd().format(widget.task.completeBy!)}';
    } else {
      return widget.task.name;
    }
  }

  Future<void> openTask() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetails(task: widget.task)),
    );
  }
}
