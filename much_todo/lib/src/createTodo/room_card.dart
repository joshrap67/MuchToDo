import 'package:flutter/material.dart';
import 'package:much_todo/src/createTodo/room_picker.dart';

import '../domain/room.dart';
import '../utils/utils.dart';

class RoomCard extends StatefulWidget {
  final List<Room> selectedRooms;
  final List<Room> rooms;
  final ValueChanged<List<Room>> onRoomsChange;
  final ValueChanged<List<Room>> onAllRoomsChanged;

  const RoomCard(
      {super.key,
      this.selectedRooms = const [],
      required this.rooms,
      required this.onRoomsChange,
      required this.onAllRoomsChanged});

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
              subtitle: Text(getSubtitle()),
              trailing: IconButton(onPressed: selectRoom, icon: const Icon(Icons.add)),
            ),
            if (widget.selectedRooms.length > 1)
              Wrap(
                spacing: 8.0, // gap between adjacent chips
                runSpacing: 4.0, // gap between lines
                children: [
                  for (var i = 0; i < widget.selectedRooms.length; i++)
                    Chip(
                      label: Text(widget.selectedRooms[i].name),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onDeleted: () {
                        onDeleteRoom(widget.selectedRooms[i]);
                      },
                    ),
                ],
              )
          ],
        ),
      ),
    );
  }

  String getSubtitle() {
    if (widget.selectedRooms.isEmpty) {
      return 'No room selected';
    } else if (widget.selectedRooms.length == 1) {
      return widget.selectedRooms[0].name;
    } else {
      return '${widget.selectedRooms.length} rooms selected';
    }
  }

  Future<void> selectRoom() async {
    hideKeyboard();
    RoomPickerPopData result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomPicker(
          rooms: widget.rooms,
          selectedRooms: widget.selectedRooms,
        ),
      ),
    );
    widget.onRoomsChange(result.selectedRooms);
    widget.onAllRoomsChanged(result.rooms);
  }

  void onDeleteRoom(Room room) {
    var rooms = widget.selectedRooms.where((x) => x.id != room.id).toList();
    widget.onRoomsChange(rooms);
  }
}
