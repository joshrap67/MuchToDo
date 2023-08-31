import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/screens/create_task/create_task.dart';
import 'package:much_todo/src/screens/filter_tasks/filter_tasks.dart';
import 'package:much_todo/src/screens/task_details/task_details.dart';
import 'package:much_todo/src/widgets/skeletons/task_list_skeleton.dart';
import 'package:much_todo/src/widgets/task_card.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  late AnimationController _diceController;

  bool _showFab = true;
  bool _bounceDice = false;

  @override
  void initState() {
    super.initState();
    setDiceController();
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
    super.build(context);
    var tasks = getTasks();
    if (context.watch<TasksProvider>().isLoading) {
      return const TaskListSkeleton();
    } else {
      return NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          var direction = notification.direction;
          setState(() {
            if (direction == ScrollDirection.reverse) {
              _showFab = false;
            } else if (direction == ScrollDirection.forward) {
              _showFab = true;
            }
          });
          return true;
        },
        child: Stack(
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
                            Badge(
                              label: Text(context.watch<TasksProvider>().filters.getFilterCount().toString()),
                              isLabelVisible: context.watch<TasksProvider>().filters.getFilterCount() > 0,
                              alignment: Alignment.bottomRight,
                              backgroundColor: Theme.of(context).colorScheme.tertiary,
                              textColor: Theme.of(context).colorScheme.onTertiary,
                              child: IconButton(
                                onPressed: () {
                                  filterTasks();
                                },
                                tooltip: 'Filter',
                                icon: const Icon(Icons.filter_list_sharp),
                              ),
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
                        child: Scrollbar(
                          child: ListView.builder(
                            itemCount: tasks.length,
                            padding: const EdgeInsets.only(bottom: 65),
                            controller: _scrollController,
                            itemBuilder: (ctx, index) {
                              var task = tasks[index];
                              // todo swipe left to delete, swipe right to edit?
                              return TaskCard(task: task);
                            },
                          ),
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'No tasks',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
              ],
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: _showFab
                      ? FloatingActionButton.extended(
                          onPressed: launchAddTask,
                          icon: const Icon(Icons.add),
                          label: const Text('ADD TASK'),
                          heroTag: 'TaskFab',
                        )
                      : null,
                ),
              ),
            )
          ],
        ),
      );
    }
  }

  List<Task> getTasks() {
    if (_searchController.text.isNotEmpty) {
      var lowercaseSearch = _searchController.text.toLowerCase();
      return context
          .read<TasksProvider>()
          .filteredTasks
          .where((element) => element.name.toLowerCase().contains(lowercaseSearch))
          .toList();
    } else {
      return context.watch<TasksProvider>().filteredTasks;
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
    var tasks = context.read<TasksProvider>().allTasks.where((element) => !element.inProgress).toList();
    if (tasks.isEmpty) {
      return;
    }
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
    bool? filtered = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FilterTasks()),
    );
    if (filtered != null && filtered && _scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  void setDiceController() {
    _diceController = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    _diceController.repeat(reverse: true);
  }

  @override
  bool get wantKeepAlive => true;
}
