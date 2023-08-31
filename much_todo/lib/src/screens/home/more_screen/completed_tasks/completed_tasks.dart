import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/completed_task.dart';
import 'package:much_todo/src/services/completed_tasks_service.dart';
import 'package:much_todo/src/widgets/completed_task_card.dart';
import 'package:much_todo/src/widgets/skeletons/completed_tasks_skeleton.dart';

class CompletedTasks extends StatefulWidget {
  const CompletedTasks({super.key});

  @override
  State<CompletedTasks> createState() => _CompletedTasksState();
}

class _CompletedTasksState extends State<CompletedTasks> {
  late bool _loading = false;
  late List<CompletedTask> _completedTasks;

  @override
  void initState() {
    super.initState();
    getCompletedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoSizeText(
          'All Completed Tasks',
          minFontSize: 10,
          maxLines: 1,
        ),
        scrolledUnderElevation: 0,
      ),
      body: !_loading
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: _completedTasks.length,
                      itemBuilder: (ctx, index) {
                        var task = _completedTasks[index];
                        return CompletedTaskCard(
                          task: task,
                          onDelete: () => onDelete(task.id),
                        );
                      },
                    ),
                  ),
                ),
              ],
            )
          : const Center(
              child: CompletedTasksSkeleton(),
            ),
    );
  }

  Future<void> getCompletedTasks() async {
    setState(() {
      _loading = true;
    });
    List<CompletedTask> tasks = await CompletedTaskService.getAllCompletedTasks(context);
    setState(() {
      _completedTasks = tasks;
      _loading = false;
    });
  }

  void onDelete(String taskId) {
    setState(() {
      _completedTasks.removeWhere((element) => element.id == taskId);
    });
  }
}
