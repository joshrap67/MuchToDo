import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/rooms/rooms_list_tasks.dart';
import 'package:provider/provider.dart';

import '../domain/room.dart';
import '../domain/task.dart';

class RoomDetails extends StatefulWidget {
  final Room room;

  const RoomDetails({super.key, required this.room});

  @override
  State<RoomDetails> createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<RoomDetails> {
  late Room _room;

  late Future<List<Task>> _tasks;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
    _tasks = getRoomTasks();
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
          FutureBuilder<List<Task>>(
            future: _tasks,
            builder: (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: RoomsListTasks(
                    tasks: snapshot.data!,
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

  Future<List<Task>> getRoomTasks() async {
    List<Task> tasks = [];
    await Future.delayed(const Duration(seconds: 2), () {
      tasks = context.read<TasksProvider>().tasks.where((element) => element.room.id == widget.room.id).toList();
    });
    setState(() {});
    return tasks;
  }
}
