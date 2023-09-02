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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: getBottomLeftWidgets(),
                    ),
                  ),
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

  List<Widget> getBottomLeftWidgets() {
    List<Widget> widgets = [];
    if (widget.task.completeBy != null) {
      widgets.add(
        Text(
          'Due ${DateFormat.yMd().format(widget.task.completeBy!)}',
          style: TextStyle(
              fontSize: 11,
              // bold if a week before due date or already passed todo test?
              fontWeight: DateTime.now().difference(widget.task.completeBy!).inDays > -7 ? FontWeight.bold : null),
        ),
      );
    }
    if (widget.task.tags.isNotEmpty) {
      var toolTip = '';
      for (final tag in widget.task.tags) {
        toolTip += '${tag.name}\n';
      }
      var padding =
          widget.task.completeBy != null ? const EdgeInsets.symmetric(horizontal: 14.0) : const EdgeInsets.all(0.0);
      widgets.add(Padding(
        padding: padding,
        child: Tooltip(
          message: toolTip.trim(),
          child: Chip(
            label: Text(
              '${widget.task.tags.length} tags',
              style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
            ),
            backgroundColor: Theme.of(context).colorScheme.tertiary,
            deleteIconColor: Theme.of(context).colorScheme.onTertiary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: const VisualDensity(horizontal: 0.0, vertical: -4),
          ),
        ),
      ));
    }
    return widgets;
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
