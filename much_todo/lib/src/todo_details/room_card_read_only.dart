import 'package:flutter/material.dart';
import 'package:much_todo/src/createTodo/room_picker.dart';

import '../domain/room.dart';
import '../utils/utils.dart';

class RoomCardReadOnly extends StatelessWidget {
  final Room? selectedRoom;

  const RoomCardReadOnly({super.key, this.selectedRoom});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('Room'),
            contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
            subtitle: selectedRoom == null ? const Text('No room selected') : Text(selectedRoom!.name),
          ),
        ],
      ),
    );
  }
}
