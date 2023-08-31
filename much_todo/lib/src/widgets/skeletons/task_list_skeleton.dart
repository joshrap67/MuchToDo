import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/widgets/task_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TaskListSkeleton extends StatelessWidget {
  const TaskListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: SearchBar(
                    leading: const Icon(Icons.search),
                    onChanged: (val) {},
                    trailing: <Widget>[
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.filter_list_sharp,
                          )),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.filter_list_sharp,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 15,
              itemBuilder: (context, index) {
                return TaskCard(
                  task: Task.named(
                      id: index.toString(),
                      name: 'Dummy Task Name',
                      priority: 1,
                      effort: 1,
                      createdBy: 'createdBy',
                      room: TaskRoom('id', 'Room Name'),
                      completeBy: DateTime.now(),
                      creationDate: DateTime.now()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
