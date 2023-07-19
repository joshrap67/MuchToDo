import 'package:flutter/material.dart';
import 'package:much_todo/src/createTodo/create_todo.dart';
import 'package:much_todo/src/todo_list/todo_card.dart';
import 'package:uuid/uuid.dart';

import '../domain/todo.dart';

class TodoList extends StatefulWidget {
  const TodoList({super.key});

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  final List<Todo> _todos = [];
  final TextEditingController _searchController = TextEditingController();

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
          ['https://experience.sap.com/wp-content/uploads/sites/58/2022/10/Sort-Filter-Overview-Form.png'],
          ['https://upload.wikimedia.org/wikipedia/commons/0/0c/American_Shorthair.jpg', 'https://rb.gy/yk4ed'],
          [],
          false,
          false,
          DateTime.now()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
            itemCount: _todos.length,
            shrinkWrap: true,
            itemBuilder: (ctx, index) {
              var todo = _todos[index];
              // todo swipe left to delete, swipe right to edit?
              return TodoCard(todo: todo);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
          child: FloatingActionButton.extended(
            onPressed: launchAddTodo,
            icon: const Icon(Icons.add),
            label: const Text('CREATE NEW TO-DO'),
          ),
        )
      ],
    );
  }

  Future<void> launchAddTodo() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateTodo()),
    );
  }
}
