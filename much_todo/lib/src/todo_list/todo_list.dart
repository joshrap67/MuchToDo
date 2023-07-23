import 'dart:async';

import 'package:flutter/material.dart';
import 'package:much_todo/src/createTodo/create_todo.dart';
import 'package:much_todo/src/domain/professional.dart';
import 'package:much_todo/src/todo_list/todo_card.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:uuid/uuid.dart';

import '../domain/todo.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final List<Todo> _todos = [];
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  bool _showFab = true;
  Timer showFabDebounce = Timer(const Duration(seconds: 1), () {});

  Future<void> debounceShowFab() async {}

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 10; i++) {
      _todos.add(Todo(
          const Uuid().v4(),
          'Todo ${i + 1}',
          ['Electrical', 'Maintenance'],
          (i % 5) + 1,
          (i % 5) + 1,
          null,
          45.2,
          'Items needed: hammer, paint, screwdriver, nails, wrench, painter\'s tape',
          ['https://www.amazon.com/Celebrity-Cutouts-Danny-DeVito-Cutout/dp/B01AACB8J4/'],
          ['https://upload.wikimedia.org/wikipedia/commons/0/0c/American_Shorthair.jpg', 'https://rb.gy/yk4ed'],
          [Professional('Dennis Reynolds', 'goldengod@gmail.com', '+18658675309')],
          false,
          false,
          DateTime.now()));
    }

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
    });
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
                    child: TextField(
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        label: Text('Search'),
                      ),
                      controller: _searchController,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list_sharp),
                      label: const Text('Filter (1)'),
                    ),
                  ),
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
    List<Todo> result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTodo()),
    );
    if (result.isNotEmpty) {
      setState(() {
        _todos.addAll(result);
        showSnackbar('${result.length} To Dos created.', context);
      });
    }
  }
}
