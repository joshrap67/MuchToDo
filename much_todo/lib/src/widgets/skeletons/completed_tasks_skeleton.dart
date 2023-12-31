import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/completed_task.dart';
import 'package:much_todo/src/widgets/completed_tasks/completed_task_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CompletedTasksSkeleton extends StatelessWidget {
  const CompletedTasksSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text('10 Total Tasks'),
            subtitle: Text(
              '100.00 Total Cost',
              style: TextStyle(fontSize: 12),
            ),
          ),
          Expanded(
            child: Scrollbar(
              child: ListView.builder(
                itemCount: 15,
                itemBuilder: (ctx, index) {
                  return CompletedTaskCard(
                    task: CompletedTask.named(
                      id: index.toString(),
                      name: 'Dummy Task Name',
                      priority: 1,
                      effort: 1,
                      createdBy: 'createdBy',
                      roomName: 'Dummy Room Name',
                      roomId: 'ABC',
                      completionDate: DateTime.now(),
                    ),
                    onDelete: () {},
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
