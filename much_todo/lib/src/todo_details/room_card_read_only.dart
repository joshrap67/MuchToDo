import 'package:flutter/material.dart';
import 'package:much_todo/src/createTodo/room_picker.dart';
import 'package:much_todo/src/domain/todo.dart';

import '../domain/room.dart';
import '../utils/utils.dart';

class RoomCardReadOnly extends StatelessWidget {
  final TodoRoom? selectedRoom;

  const RoomCardReadOnly({super.key, this.selectedRoom});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        subtitle: const Text('Room'),
        contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
        title: selectedRoom == null ? const Text('No room') : Text(selectedRoom!.name),
      ),
    );
  }
}
