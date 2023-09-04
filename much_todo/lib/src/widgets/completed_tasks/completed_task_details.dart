import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/completed_task.dart';
import 'package:much_todo/src/screens/task_details/links_card_read_only.dart';
import 'package:much_todo/src/services/completed_tasks_service.dart';
import 'package:much_todo/src/widgets/completed_tasks/contacts_card_completed_task.dart';
import 'package:much_todo/src/widgets/priority_indicator.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/completed_tasks/tags_card_completed_task.dart';

class CompletedTaskDetails extends StatefulWidget {
  final CompletedTask task;

  const CompletedTaskDetails({super.key, required this.task});

  @override
  State<CompletedTaskDetails> createState() => _CompletedTaskDetailsState();
}

class _CompletedTaskDetailsState extends State<CompletedTaskDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          widget.task.name,
          minFontSize: 10,
          maxLines: 1,
        ),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(onPressed: promptDeleteTask, icon: const Icon(Icons.delete)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Card(
                                child: ListTile(
                                  title: Align(
                                    alignment: Alignment.topLeft,
                                    child: PriorityIndicator(priority: widget.task.priority),
                                  ),
                                  contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
                                  subtitle: const Text(
                                    'Priority',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Card(
                                child: ListTile(
                                  title: Text(getEffortTitle(widget.task.effort)),
                                  contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
                                  subtitle: const Text(
                                    'Effort',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        if (widget.task.note != null && widget.task.note!.isNotEmpty)
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  child: ListTile(
                                    title: Text(widget.task.note!),
                                    subtitle: const Text(
                                      'Note',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                child: ListTile(
                                  title: Text(DateFormat.yMd().format(widget.task.completionDate)),
                                  subtitle: const Text(
                                    'Completed Date',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            if (widget.task.estimatedCost != null)
                              Flexible(
                                child: Card(
                                  child: ListTile(
                                    title: Text(NumberFormat.currency(symbol: '\$').format(widget.task.estimatedCost)),
                                    subtitle: const Text(
                                      'Estimated Cost',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                              ),
                            Flexible(
                              child: Card(
                                child: ListTile(
                                  title: Text(widget.task.roomName),
                                  subtitle: const Text(
                                    'Room',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (widget.task.tags.isNotEmpty) TagsCardCompletedTask(tags: widget.task.tags),
                        if (widget.task.contacts.isNotEmpty) ContactCardCompletedTask(contacts: widget.task.contacts),
                        if (widget.task.links.isNotEmpty) LinksCardReadOnly(links: widget.task.links),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void promptDeleteTask() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog.adaptive(
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteTask();
              },
              child: const Text('DELETE'),
            )
          ],
          title: const Text('Delete Task'),
          content: const Text('Are you sure you wish to delete this completed task? This action is irreversible.'),
        );
      },
    );
  }

  Future<void> deleteTask() async {
    showLoadingDialog(context, msg: 'Deleting...');
    var result = await CompletedTaskService.deleteCompletedTask(widget.task);
    if (context.mounted) {
      closePopup(context);

      if (result.success) {
        Navigator.of(context).pop(true);
      } else {
        showSnackbar(result.errorMessage!, context);
      }
    }
  }
}
