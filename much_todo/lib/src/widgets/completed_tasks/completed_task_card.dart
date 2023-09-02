import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/completed_task.dart';
import 'package:much_todo/src/widgets/completed_tasks/completed_task_details.dart';
import 'package:much_todo/src/widgets/priority_indicator.dart';

class CompletedTaskCard extends StatefulWidget {
  final CompletedTask task;
  final VoidCallback onDelete;
  final VoidCallback? onLongPress;

  const CompletedTaskCard({super.key, required this.task, required this.onDelete, this.onLongPress});

  @override
  State<CompletedTaskCard> createState() => _CompletedTaskCardState();
}

class _CompletedTaskCardState extends State<CompletedTaskCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onLongPress: () {
          if (widget.onLongPress != null) {
            widget.onLongPress!();
          }
        },
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
              subtitle: Text(widget.task.roomName),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                  child: Text(
                    'Completed: ${DateFormat.yMd().format(widget.task.completionDate)}',
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
      ),
    );
  }

  Future<void> openTask() async {
    bool? deleted = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CompletedTaskDetails(task: widget.task)),
    );
    if (deleted != null && deleted) {
      widget.onDelete();
    }
  }
}
