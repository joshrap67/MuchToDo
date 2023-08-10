import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:much_todo/src/create_task/create_task.dart';
import 'package:much_todo/src/filter/filter_tasks.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/task_details/task_details.dart';
import 'package:much_todo/src/task_list/task_card.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

import '../domain/task.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<Task> _tasks = [];
  bool _showFab = true;
  Timer showFabDebounce = Timer(const Duration(seconds: 1), () {});

  Future<void> debounceShowFab() async {}

  @override
  void initState() {
    // need to wait for controller to be attached to list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.position.isScrollingNotifier.addListener(() {
        showFabDebounce.cancel();
        if (_scrollController.position.isScrollingNotifier.value && _showFab) {
          // second conditional check is to avoid constant re-renders
          setState(() {
            _showFab = false;
          });
        } else if (!_scrollController.position.isScrollingNotifier.value && !_showFab) {
          showFabDebounce = Timer(const Duration(milliseconds: 800), () {
            setState(() {
              _showFab = true;
            });
          });
        }
      });
      setState(() {
        _tasks = context.read<TasksProvider>().tasks;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: SearchBar(
                      leading: const Icon(Icons.search),
                      trailing: <Widget>[
                        IconButton(
                          onPressed: () {
                            filterTasks();
                          },
                          icon: const Icon(Icons.filter_list_sharp),
                          // label: const Text(''),
                        )
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: pickRandomTask,
                    icon: const Icon(Icons.casino_rounded),
					  tooltip: 'Open Random Task',
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                key: const PageStorageKey('task-list'),
                itemCount: _tasks.length,
                padding: const EdgeInsets.only(bottom: 65),
                shrinkWrap: true,
                controller: _scrollController,
                itemBuilder: (ctx, index) {
                  var task = _tasks[index];
                  // todo swipe left to delete, swipe right to edit?
                  return TaskCard(task: task);
                },
              ),
            ),
          ],
        ),
        Visibility(
          visible: true,
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: _showFab
                    ? FloatingActionButton(
                        onPressed: launchAddTask,
                        child: const Icon(Icons.add),
                      )
                    : null,
              ),
            ),
          ),
        )
      ],
    );
  }

  Future<void> launchAddTask() async {
    List<Task>? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTask()),
    );
    hideKeyboard();
    // todo since using provider, this is not needed. just call method to get tasks with current filters
    if (result != null && result.isNotEmpty) {
      setState(() {
        _tasks.addAll(result);
        showSnackbar('${result.length} Tasks created.', context);
      });
    }
  }

  Future<void> pickRandomTask() async {
    var random = Random();
    var index = random.nextInt(_tasks.length);
    hideKeyboard();
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TaskDetails(task: _tasks[index])),
    );
  }

  Future<void> filterTasks() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FilterTasks()),
    );
  }
}
