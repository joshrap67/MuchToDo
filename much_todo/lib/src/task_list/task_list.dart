import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:much_todo/src/create_task/create_task.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/filter/filter_tasks.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/task_details/task_details.dart';
import 'package:much_todo/src/task_list/task_card.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _diceController;

  bool _showFab = true;
  bool _bounceDice = false;
  Timer showFabDebounce = Timer(const Duration(seconds: 1), () {});

  Future<void> debounceShowFab() async {}

  @override
  void initState() {
    setDiceController();

    // need to wait for controller to be attached to list. When user scrolls hide the FAB so it doesn't block a card
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
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _diceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tasks = getTasks();
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
                      onChanged: (val) {
                        setState(() {});
                      },
                      controller: _searchController,
                      trailing: <Widget>[
                        IconButton(
                          onPressed: () {
                            filterTasks();
                          },
                          tooltip: 'Filter',
                          icon: const Icon(Icons.filter_list_sharp),
                        ),
                        Visibility(
                          visible: !_bounceDice,
                          child: IconButton(
                            onPressed: pickRandomTask,
                            icon: SvgPicture.asset(
                              'assets/icons/dice.svg',
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn),
                            ),
                            tooltip: 'Open Random Task',
                          ),
                        ),
                        Visibility(
                          visible: _bounceDice,
                          child: ScaleTransition(
                            scale: Tween(begin: 0.75, end: 1.25).animate(
                              CurvedAnimation(
                                parent: _diceController,
                                curve: Curves.elasticOut,
                              ),
                            ),
                            child: IconButton(
                              onPressed: () {},
                              isSelected: false,
                              icon: SvgPicture.asset(
                                'assets/icons/dice.svg',
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            tasks.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      key: const PageStorageKey('task-list'),
                      itemCount: tasks.length,
                      padding: const EdgeInsets.only(bottom: 65),
                      shrinkWrap: true,
                      controller: _scrollController,
                      itemBuilder: (ctx, index) {
                        var task = tasks[index];
                        // todo swipe left to delete, swipe right to edit?
                        return TaskCard(task: task);
                      },
                    ),
                  )
                : const Center(
                    child: Text('No tasks'),
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

  List<Task> getTasks() {
    if (_searchController.text.isNotEmpty) {
      return context
          .read<TasksProvider>()
          .tasks
          .where((element) => element.name.contains(_searchController.text))
          .toList();
    } else {
      return context.watch<TasksProvider>().tasks;
    }
  }

  Future<void> launchAddTask() async {
    List<Task>? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTask()),
    );
    hideKeyboard();
    if (result != null && result.isNotEmpty && context.mounted) {
      var msg = result.length == 1 ? 'Task created' : '${result.length} Tasks created';
      showSnackbar(msg, context);
    }
  }

  Future<void> pickRandomTask() async {
    var tasks = context.read<TasksProvider>().tasks;
    hideKeyboard();
    setState(() {
      _bounceDice = true;
      // there is probably a better way of doing this but for now this works
      setDiceController();
    });
    await Future.delayed(const Duration(seconds: 2), () {});
    setState(() {
      _bounceDice = false;
    });

    var random = Random();
    var index = random.nextInt(tasks.length);

    if (context.mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TaskDetails(task: tasks[index])),
      );
    }
  }

  Future<void> filterTasks() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FilterTasks()),
    );
  }

  void setDiceController() {
    _diceController = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _diceController.repeat(reverse: true);
  }
}
