import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/completed_task.dart';

class SelectedCompletedTaskCard extends StatefulWidget {
  final CompletedTask task;
  final VoidCallback? onLongPress;

  const SelectedCompletedTaskCard({super.key, required this.task, this.onLongPress});

  @override
  State<SelectedCompletedTaskCard> createState() => _SelectedCompletedTaskCardState();
}

class _SelectedCompletedTaskCardState extends State<SelectedCompletedTaskCard> {
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
                Visibility(
                  visible: false,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('OPEN'),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
