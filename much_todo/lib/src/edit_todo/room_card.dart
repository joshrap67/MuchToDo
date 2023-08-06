import 'package:flutter/material.dart';
import 'package:much_todo/src/edit_todo/room_picker_singular.dart';

import '../domain/room.dart';
import '../utils/utils.dart';

class RoomCard extends StatefulWidget {
  final Room? selectedRoom;
  final ValueChanged<Room?> onRoomChange;

  const RoomCard({super.key, this.selectedRoom, required this.onRoomChange});

  @override
  State<RoomCard> createState() => _RoomCardState();
}

class _RoomCardState extends State<RoomCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
        child: Column(
          children: [
            ListTile(
              title: Text(getTitle()),
              leading: const Icon(Icons.home),
              contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
              trailing: IconButton(onPressed: selectRoom, icon: const Icon(Icons.add)),
            ),
          ],
        ),
      ),
    );
  }

  String getTitle() {
    if (widget.selectedRoom == null) {
      return 'No room';
    } else {
      return widget.selectedRoom!.name;
    }
  }

  Future<void> selectRoom() async {
    hideKeyboard();
    RoomPickerPopData result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomPickerSingular(
          selectedRoom: widget.selectedRoom,
        ),
      ),
    );
    widget.onRoomChange(result.selectedRoom);
  }
}
