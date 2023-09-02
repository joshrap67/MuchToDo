import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/screens/room_details/room_details.dart';
import 'package:provider/provider.dart';

class RoomCardReadOnly extends StatefulWidget {
  final TaskRoom selectedRoom;

  const RoomCardReadOnly({super.key, required this.selectedRoom});

  @override
  State<RoomCardReadOnly> createState() => _RoomCardReadOnlyState();
}

class _RoomCardReadOnlyState extends State<RoomCardReadOnly> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: openRoom,
        child: ListTile(
          title: Text(widget.selectedRoom.name),
          subtitle: const Text(
            'Room',
            style: TextStyle(fontSize: 12),
          ),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
        ),
      ),
    );
  }

  void openRoom() {
    var room = context.read<RoomsProvider>().rooms.firstWhere((element) => element.id == widget.selectedRoom.id);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoomDetails(room: room)),
    );
  }
}
