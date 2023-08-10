import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/task.dart';

class RoomCardReadOnly extends StatelessWidget {
  final TaskRoom selectedRoom;

  const RoomCardReadOnly({super.key, required this.selectedRoom});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        subtitle: const Text('Room'),
        contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
        title: Text(selectedRoom.name),
      ),
    );
  }
}
