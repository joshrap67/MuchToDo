import 'package:flutter/material.dart';
import 'package:much_todo/src/createTodo/room_picker.dart';

import '../domain/room.dart';
import '../utils/utils.dart';

class RoomCard extends StatefulWidget {
  final Room? selectedRoom;
  final List<Room> rooms;
  final ValueChanged<Room?> onRoomChange;
  final ValueChanged<List<Room>> onRoomsChanged;

  const RoomCard({super.key, this.selectedRoom, required this.rooms, required this.onRoomChange, required this.onRoomsChanged});

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Room'),
              contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
              subtitle: widget.selectedRoom == null ? const Text('No room selected') : Text(widget.selectedRoom!.name),
              trailing: IconButton(onPressed: selectRoom, icon: const Icon(Icons.add)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> selectRoom() async {
    hideKeyboard();
	RoomPickerPopData result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomPicker(
          rooms: widget.rooms,
          selectedRoom: widget.selectedRoom,
        ),
      ),
    );
    widget.onRoomChange(result.selectedRoom);
	widget.onRoomsChanged(result.rooms);
  }
}
