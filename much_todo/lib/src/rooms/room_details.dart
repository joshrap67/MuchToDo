import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/rooms/edit_room.dart';
import 'package:much_todo/src/rooms/room_completed_tasks.dart';
import 'package:much_todo/src/rooms/room_tasks_list.dart';
import 'package:much_todo/src/services/rooms_service.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/domain/room.dart';

class RoomDetails extends StatefulWidget {
  final Room room;

  const RoomDetails({super.key, required this.room});

  @override
  State<RoomDetails> createState() => _RoomDetailsState();
}

enum TaskOptions { edit, delete, showCompletedTasks }

class _RoomDetailsState extends State<RoomDetails> {
  late Room _room;

  @override
  void initState() {
    super.initState();
    _room = widget.room;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(_room.name),
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
                const PopupMenuItem<TaskOptions>(
                  value: TaskOptions.showCompletedTasks,
                  child: ListTile(
                    title: Text('Completed Tasks'),
                    leading: Icon(Icons.done),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Visibility(
          //   visible: _room.note.isNotNullOrEmpty(),
          //   child: ListTile(
          //     title: Text(_room.note ?? ''),
          //     subtitle: const Text(
          //       'Note',
          //       style: TextStyle(fontSize: 11),
          //     ),
          //   ),
          // ),
          Expanded(
            child: RoomTasksList(
              room: _room,
            ),
          ),
        ],
      ),
    );
  }

  onOptionSelected(TaskOptions result) {
    switch (result) {
      case TaskOptions.edit:
        editRoom();
        break;
      case TaskOptions.delete:
        promptDeleteRoom();
        break;
      case TaskOptions.showCompletedTasks:
        showCompletedRooms();
        break;
    }
  }

  Future<void> editRoom() async {
    Room? room = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditRoom(room: _room),
      ),
    );
    if (room != null && context.mounted) {
      setState(() {
        _room = room;
      });
    }
  }

  void showCompletedRooms() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomCompletedTasks(room: _room),
      ),
    );
  }

  void promptDeleteRoom() {
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
    showLoadingDialog(context, msg: 'Deleting...');
    await RoomsService.deleteRoom(context, _room); // todo in general need better error handling pattern from service
    if (context.mounted) {
      closePopup(context);
      Navigator.of(context).pop();
    }
  }
}
