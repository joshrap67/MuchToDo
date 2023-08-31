import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/completed_task.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/services/completed_tasks_service.dart';
import 'package:much_todo/src/widgets/completed_task_card.dart';
import 'package:much_todo/src/widgets/skeletons/completed_tasks_skeleton.dart';

class RoomCompletedTasks extends StatefulWidget {
  final Room room;

  const RoomCompletedTasks({super.key, required this.room});

  @override
  State<RoomCompletedTasks> createState() => _RoomCompletedTasksState();
}

class _RoomCompletedTasksState extends State<RoomCompletedTasks> {
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
        title: AutoSizeText(
          '${widget.room.name} Completed Tasks',
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
    List<CompletedTask> tasks = await CompletedTaskService.getCompletedTasksByRoom(context, widget.room);
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
