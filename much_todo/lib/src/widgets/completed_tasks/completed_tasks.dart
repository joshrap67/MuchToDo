import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/completed_task.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/services/completed_tasks_service.dart';
import 'package:much_todo/src/utils/enums.dart';
import 'package:much_todo/src/utils/result.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/completed_tasks/completed_task_card.dart';
import 'package:much_todo/src/widgets/completed_tasks/selected_completed_task_card.dart';
import 'package:much_todo/src/widgets/skeletons/completed_tasks_skeleton.dart';
import 'package:much_todo/src/widgets/sort_direction_button.dart';

class CompletedTasks extends StatefulWidget {
  final Room? room;

  const CompletedTasks({super.key, this.room});

  @override
  State<CompletedTasks> createState() => _CompletedTasksState();
}

class _CompletedTasksState extends State<CompletedTasks> {
  late bool _loading = false;
  late bool _deleteMode = false;
  late bool _deleteAll = false;
  late List<CompletedTask> _completedTasks;
  final List<String> _tasksToDelete = [];

  CompletedTaskSortOption _sortByValue = CompletedTaskSortOption.completionDate;
  SortDirection _sortDirectionValue = SortDirection.descending;
  final List<DropdownMenuItem<CompletedTaskSortOption>> _sortEntries = <DropdownMenuItem<CompletedTaskSortOption>>[];

  @override
  void initState() {
    super.initState();
    for (var value in CompletedTaskSortOption.values) {
      _sortEntries.add(DropdownMenuItem<CompletedTaskSortOption>(
        value: value,
        child: Text(value.label),
      ));
    }
    getCompletedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.room != null
            ? ListTile(
                title: const Text('Completed Tasks'),
                subtitle: Text(widget.room!.name),
                contentPadding: EdgeInsets.zero,
              )
            : const AutoSizeText(
                'Completed Tasks',
                minFontSize: 10,
                maxLines: 1,
              ),
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        actions: _deleteMode
            ? [
                TextButton(
                  onPressed: promptDeleteCompletedTasks,
                  child: Text(
                    'DELETE',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),
                  ),
                )
              ]
            : [
                IconButton(
                  onPressed: promptSortTasks,
                  icon: const Icon(Icons.sort),
                )
              ],
      ),
      body: !_loading
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Visibility(
                      visible: _deleteMode,
                      child: Checkbox(
                        value: _deleteAll,
                        checkColor: Colors.white,
                        activeColor: Theme.of(context).colorScheme.error,
                        onChanged: (newValue) {
                          _tasksToDelete.clear();
                          if (newValue!) {
                            _tasksToDelete.addAll(_completedTasks.map((e) => e.id));
                            _deleteAll = true;
                          } else {
                            _deleteAll = false;
                          }
                          setState(() {});
                        },
                      ),
                    ),
                    Expanded(
                      child: Visibility(
                        visible: !_deleteMode,
                        maintainAnimation: true,
                        maintainSize: true,
                        maintainState: true,
                        child: ListTile(
                          title: Text('${_completedTasks.length} Total Tasks'),
                          subtitle: Text(
                            '${NumberFormat.currency(symbol: '\$').format(totalCost())} Total Estimated Cost',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_completedTasks.isEmpty)
                  const Center(
                    child: Text('No completed tasks'),
                  ),
                if (_completedTasks.isNotEmpty)
                  Expanded(
                    child: Scrollbar(
                      child: ListView.builder(
                        itemCount: _completedTasks.length,
                        itemBuilder: (ctx, index) {
                          var task = _completedTasks[index];
                          if (_deleteMode) {
                            return Row(
                              children: [
                                Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: Theme.of(context).colorScheme.error,
                                  value: _tasksToDelete.any((element) => element == task.id),
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      if (newValue!) {
                                        _tasksToDelete.add(task.id);
                                      } else {
                                        _tasksToDelete.removeWhere((element) => element == task.id);
                                      }
                                    });
                                  },
                                ),
                                Expanded(
                                  child: SelectedCompletedTaskCard(
                                    task: task,
                                    onLongPress: () {
                                      setState(() {
                                        _deleteMode = !_deleteMode;
                                        if (!_deleteMode) {
                                          _tasksToDelete.clear();
                                          _deleteAll = false;
                                        }
                                      });
                                    },
                                  ),
                                )
                              ],
                            );
                          } else {
                            return CompletedTaskCard(
                              task: task,
                              showRoom: widget.room == null,
                              onDelete: () => onDelete(task.id),
                              onLongPress: () {
                                setState(() {
                                  _deleteMode = !_deleteMode;
                                  if (_deleteMode) {
                                    // since they long pressed this one, initially select it to delete
                                    _tasksToDelete.add(task.id);
                                  }
                                });
                              },
                            );
                          }
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

    List<CompletedTask> tasks = [];
    Result<List<CompletedTask>> result;
    if (widget.room != null) {
      result = await CompletedTaskService.getCompletedTasksByRoom(widget.room!);
    } else {
      result = await CompletedTaskService.getAllCompletedTasks();
    }

    if (result.success) {
      tasks = result.data!;
    } else if (context.mounted) {
      showSnackbar(result.errorMessage!, context);
    }

    setState(() {
      _completedTasks = tasks;
      sortTasks();
      _loading = false;
    });
  }

  void promptDeleteCompletedTasks() {
    if (_tasksToDelete.isEmpty) {
      showSnackbar('Select at least one to delete', context);
      return;
    }

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
                deleteCompletedTasks();
              },
              child: Text('DELETE (${_tasksToDelete.length})'),
            )
          ],
          title: const Text('Delete Tasks'),
          content: const Text('Are you sure you wish to delete these completed tasks?'),
        );
      },
    );
  }

  Future<void> deleteCompletedTasks() async {
    setState(() {
      _loading = true;
    });

    var result = await CompletedTaskService.deleteCompletedTasks(_tasksToDelete);
    if (result.success) {
      setState(() {
        _completedTasks.removeWhere((element) => _tasksToDelete.contains(element.id));
        _tasksToDelete.clear();
        _loading = false;
      });
    } else if (context.mounted) {
      showSnackbar(result.errorMessage!, context);
      setState(() {
        _loading = false;
      });
    }
  }

  void onDelete(String taskId) {
    setState(() {
      _completedTasks.removeWhere((element) => element.id == taskId);
    });
  }

  double totalCost() {
    var cost = 0.0;
    for (final task in _completedTasks) {
      cost += task.estimatedCost ?? 0.0;
    }
    return cost;
  }

  void promptSortTasks() {
    if (_loading) {
      return;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog.adaptive(
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, 'OK');
                sortTasks();
                setState(() {});
              },
              child: const Text('APPLY'),
            )
          ],
          title: const Text('Sort Tasks'),
          insetPadding: const EdgeInsets.all(8.0),
          content: StatefulBuilder(
            builder: (statefulContext, setState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                              labelText: 'Sort By',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<CompletedTaskSortOption>(
                                value: _sortByValue,
                                dropdownColor: getDropdownColor(context),
                                onChanged: (CompletedTaskSortOption? value) {
                                  setState(() {
                                    _sortByValue = value!;
                                  });
                                },
                                items: CompletedTaskSortOption.values
                                    .map<DropdownMenuItem<CompletedTaskSortOption>>((CompletedTaskSortOption value) {
                                  return DropdownMenuItem<CompletedTaskSortOption>(
                                      value: value, child: Text(value.label));
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SortDirectionButton(
                            sortDirection: _sortDirectionValue,
                            onChange: (sort) {
                              setState(() {
                                _sortDirectionValue = sort;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void sortTasks() {
    var tasks = _completedTasks;
    sortCompletedTasks(tasks, _sortByValue, _sortDirectionValue);

    _completedTasks = tasks;
  }
}
