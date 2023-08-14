import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/rooms/edit_room.dart';
import 'package:much_todo/src/rooms/rooms_list_tasks.dart';
import 'package:much_todo/src/services/rooms_service.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/task.dart';

class RoomDetails extends StatefulWidget {
  final Room room;

  const RoomDetails({super.key, required this.room});

  @override
  State<RoomDetails> createState() => _RoomDetailsState();
}

enum TaskOptions { edit, delete }

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
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'More',
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15.0),
              ),
            ),
            itemBuilder: (context) {
              hideKeyboard();
              return <PopupMenuEntry<TaskOptions>>[
                const PopupMenuItem<TaskOptions>(
                  value: TaskOptions.edit,
                  child: ListTile(
                    title: Text('Edit'),
                    leading: Icon(Icons.edit),
                    contentPadding: EdgeInsets.all(0),
                  ),
                ),
                const PopupMenuItem<TaskOptions>(
                  value: TaskOptions.delete,
                  child: ListTile(
                    title: Text('Delete'),
                    leading: Icon(Icons.delete),
                    contentPadding: EdgeInsets.all(0),
                  ),
                ),
              ];
            },
            onSelected: (TaskOptions result) => onOptionSelected(result),
          )
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: AutoSizeText(
              _room.name,
              style: const TextStyle(fontSize: 22),
            ),
            subtitle: _room.note != null ? Text(_room.note!) : null,
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
    // todo use a separate provider for this?
    await Future.delayed(const Duration(seconds: 2), () {
      tasks = context.read<TasksProvider>().tasks.where((element) => element.room.id == widget.room.id).toList();
    });
    setState(() {});
    return tasks;
  }

  onOptionSelected(TaskOptions result) {
    switch (result) {
      case TaskOptions.edit:
        editRoom();
        break;
      case TaskOptions.delete:
        promptDeleteRoom();
        break;
    }
  }

  Future<void> editRoom() async {
    Room? room = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRoom(room: widget.room),
      ),
    );
    if (room != null && context.mounted) {
      setState(() {
        _room = room;
      });
    }
  }

  void promptDeleteRoom() {
    showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deleteRoom();
                },
                child: const Text('DELETE'),
              )
            ],
            title: const Text('Delete Room'),
            content: const Text(
                'Are you sure you wish to delete this room? ALL tasks associated with this room will be deleted!'),
          );
        });
  }

  Future<void> deleteRoom() async {
    await RoomsService.deleteRoom(context, widget.room);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
