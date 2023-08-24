import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/services/rooms_service.dart';
import 'package:much_todo/src/skeletons/completed_tasks_skeleton.dart';
import 'package:much_todo/src/task_list/task_card.dart';

class RoomCompletedTasks extends StatefulWidget {
  final Room room;

  const RoomCompletedTasks({super.key, required this.room});

  @override
  State<RoomCompletedTasks> createState() => _RoomCompletedTasksState();
}

class _RoomCompletedTasksState extends State<RoomCompletedTasks> {
  late Future<List<Task>> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = getRoomTasks();
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
      body: FutureBuilder<List<Task>>(
        future: _tasks,
        builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
          if (snapshot.hasData) {
            var tasks = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (ctx, index) {
                        var task = tasks[index];
                        return TaskCard(
                            task: task,
                            showRoom: false); // todo need to handle if they change it from completed to not completed
                      },
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const CompletedTasksSkeleton();
          }
        },
      ),
    );
  }

  Future<List<Task>> getRoomTasks() async {
    List<Task> tasks = await RoomsService.getCompletedTasks(context, widget.room);
    setState(() {});
    return tasks;
  }
}
