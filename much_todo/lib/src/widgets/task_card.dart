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
                Tooltip(
                  message: 'Priority',
                  child: PriorityIndicator(priority: widget.task.priority),
                ),
              ],
            ),
            title: Text(widget.task.name),
            trailing: widget.task.inProgress
                ? Tooltip(
                    message: 'In Progress',
                    child: ImageIcon(
                      const AssetImage('assets/icons/in-progress.png'),
                      color: Theme.of(context).iconTheme.color,
                    ),
                  )
                : null,
            subtitle: widget.showRoom ? Text(widget.task.room.name) : const Text(''),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              widget.task.completeBy != null
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
                      child: Text(
                        'Due ${DateFormat.yMd().format(widget.task.completeBy!)}',
                        style: TextStyle(
                            fontSize: 11,
                            // bold if a week before due date or already passed
                            fontWeight:
                                widget.task.completeBy!.difference(DateTime.now()).inDays < 7 ? FontWeight.bold : null),
                      ),
                    )
                  : const Text(''),
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

  String getTitle() {
    if (widget.task.completeBy != null) {
      return '${widget.task.name} - Due by ${DateFormat.yMd().format(widget.task.completeBy!)}';
    } else {
      return widget.task.name;
    }
  }

  void openTask() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetails(task: widget.task)),
    );
  }
}
