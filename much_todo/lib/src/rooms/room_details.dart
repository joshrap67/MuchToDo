import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/providers/todos_provider.dart';
import 'package:much_todo/src/rooms/rooms_list_todos.dart';
import 'package:provider/provider.dart';

import '../domain/room.dart';
import '../domain/todo.dart';

class RoomDetails extends StatefulWidget {
  final Room room;

  const RoomDetails({super.key, required this.room});

  @override
  State<RoomDetails> createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<RoomDetails> {
  late Room _room;

  late Future<List<Todo>> _todos;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _todos = getRoomTodos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const AutoSizeText('Room Details'),
        scrolledUnderElevation: 0,
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  title: AutoSizeText(_room.name),
                  subtitle: _room.note != null ? Text(_room.note!) : null,
                ),
              ],
            ),
          ),
          FutureBuilder<List<Todo>>(
            future: _todos,
            builder: (BuildContext context, AsyncSnapshot<List<Todo>> snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: RoomsListTodos(
                    todos: snapshot.data!,
                    room: widget.room,
                  ),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          )
        ],
      ),
    );
  }

  Future<List<Todo>> getRoomTodos() async {
    List<Todo> todos = [];
    await Future.delayed(const Duration(seconds: 2), () {
      todos = context.read<TodosProvider>().todos.where((element) => element.room?.id == widget.room.id).toList();
    });
    setState(() {});
    return todos;
  }
}
