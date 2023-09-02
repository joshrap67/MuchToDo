import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/completed_task.dart';
import 'package:much_todo/src/widgets/completed_tasks/completed_task_details.dart';
import 'package:much_todo/src/widgets/priority_indicator.dart';

class MinimalCompletedTaskCard extends StatefulWidget {
  final CompletedTask task;
  final VoidCallback? onLongPress;

  const MinimalCompletedTaskCard({super.key, required this.task, this.onLongPress});

  @override
  State<MinimalCompletedTaskCard> createState() => _MinimalCompletedTaskCardState();
}

class _MinimalCompletedTaskCardState extends State<MinimalCompletedTaskCard> {
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
              title: Text(widget.task.name),
              subtitle: Text(widget.task.roomName),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 12.0),
                  child: Text(
                    'Completed: ${DateFormat.yMd().format(widget.task.completionDate)}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
