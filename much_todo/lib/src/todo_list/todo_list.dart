import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:much_todo/src/createTodo/create_todo.dart';
import 'package:much_todo/src/filter/filter_todos.dart';
import 'package:much_todo/src/providers/todos_provider.dart';
import 'package:much_todo/src/todo_details/todo_details.dart';
import 'package:much_todo/src/todo_list/todo_card.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

import '../domain/todo.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  List<Todo> _todos = [];
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
        _todos = context.read<TodosProvider>().todos;
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
                            filterTodos();
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
                key: const PageStorageKey('todo-list'),
                itemCount: _todos.length,
                padding: const EdgeInsets.only(bottom: 65),
                shrinkWrap: true,
                controller: _scrollController,
                itemBuilder: (ctx, index) {
                  var todo = _todos[index];
                  // todo swipe left to delete, swipe right to edit?
                  return TodoCard(todo: todo);
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
                        onPressed: launchAddTodo,
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

  Future<void> launchAddTodo() async {
    List<Todo>? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTodo()),
    );
    hideKeyboard();
    // todo since using provider, this is not needed. just call method to get todos with current filters
    if (result != null && result.isNotEmpty) {
      setState(() {
        _todos.addAll(result);
        showSnackbar('${result.length} To Dos created.', context);
      });
    }
  }

  Future<void> pickRandomTask() async {
    var random = Random();
    var index = random.nextInt(_todos.length);
    hideKeyboard();
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TodoDetails(todo: _todos[index])),
    );
  }

  Future<void> filterTodos() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FilterTodos()),
    );
  }
}
