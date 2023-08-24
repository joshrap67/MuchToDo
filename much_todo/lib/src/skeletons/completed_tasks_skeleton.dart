import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/task_list/task_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CompletedTasksSkeleton extends StatefulWidget {
  const CompletedTasksSkeleton({super.key});

  @override
  State<CompletedTasksSkeleton> createState() => _CompletedTasksSkeletonState();
}

class _CompletedTasksSkeletonState extends State<CompletedTasksSkeleton> {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                itemCount: 15,
                itemBuilder: (ctx, index) {
                  return TaskCard(
                    task: Task.named(
                        id: index.toString(),
                        name: 'Dummy Task Name',
                        priority: 1,
                        effort: 1,
                        createdBy: 'createdBy',
                        room: TaskRoom('id', 'Dummy Room Name'),
                        completeBy: DateTime.now(),
                        creationDate: DateTime.now()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
