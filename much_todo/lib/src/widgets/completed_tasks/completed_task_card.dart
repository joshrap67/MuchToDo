import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/completed_task.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/completed_tasks/completed_task_details.dart';
import 'package:much_todo/src/widgets/priority_indicator.dart';

class CompletedTaskCard extends StatefulWidget {
  final CompletedTask task;
  final bool showRoom;
  final VoidCallback onDelete;
  final VoidCallback? onLongPress;

  const CompletedTaskCard(
      {super.key, this.showRoom = true, required this.task, required this.onDelete, this.onLongPress});

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
                  Tooltip(
                    message: 'Priority',
                    child: PriorityIndicator(priority: widget.task.priority),
                  ),
                ],
              ),
              title: Text(
                widget.task.name,
                style: const TextStyle(fontSize: 20),
              ),
              subtitle: widget.showRoom
                  ? Text(
                      widget.task.roomName,
                      style: const TextStyle(fontSize: 12),
                    )
                  : null,
              contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
              trailing: Text(DateFormat.yMd().format(widget.task.completionDate)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
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
      ),
    );
  }

  Future<void> openTask() async {
    var deleted = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(builder: (context) => CompletedTaskDetails(task: widget.task)),
    );
    if (deleted != null && deleted) {
      widget.onDelete();
    }
  }
}
