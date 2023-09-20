import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/screens/task_details/task_details.dart';
import 'package:much_todo/src/utils/utils.dart';
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
            title: Text(
              widget.task.name,
              style: const TextStyle(fontSize: 18),
            ),
            leadingAndTrailingTextStyle: widget.task.completeBy != null
                ? TextStyle(
                    fontSize: 11,
                    // bold if a week before due date or already passed
                    fontWeight: widget.task.completeBy!.difference(DateTime.now()).inDays < 7 ? FontWeight.bold : null)
                : null,
            contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
            trailing: widget.task.completeBy != null
                ? Text(
                    'Due ${DateFormat.yMd().format(widget.task.completeBy!)}',
                    style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
                  )
                : null,
            subtitle: widget.showRoom
                ? Text(
                    widget.task.room.name,
                    style: const TextStyle(fontSize: 12),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                widget.task.inProgress
                    ? Tooltip(
                        message: 'In Progress',
                        child: ImageIcon(
                          const AssetImage('assets/icons/in-progress.png'),
                          color: Theme.of(context).iconTheme.color,
                        ),
                      )
                    : Text(
                        '${getEffortTitle(widget.task.effort)} Effort',
                        style: const TextStyle(
                          fontSize: 10,
                        ),
                      ),
                TextButton(
                  onPressed: openTask,
                  child: const Text('OPEN'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void openTask() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetails(task: widget.task)),
    );
  }
}
