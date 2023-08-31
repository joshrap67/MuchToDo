import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/screens/create_task/room_picker_multiple.dart';
import 'package:much_todo/src/utils/utils.dart';

class RoomCardMultiple extends StatefulWidget {
  final List<Room> selectedRooms;
  final ValueChanged<List<Room>> onRoomsChange;
  final bool showError;

  const RoomCardMultiple({super.key, this.selectedRooms = const [], required this.onRoomsChange, this.showError = false});

  @override
  State<RoomCardMultiple> createState() => _RoomCardMultipleState();
}

class _RoomCardMultipleState extends State<RoomCardMultiple> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
        child: Column(
          children: [
            ListTile(
              title: getTitle(),
              subtitle: getSubtitle(),
              leading: Icon(
                Icons.home,
                color: widget.showError ? Theme.of(context).colorScheme.error : null,
              ),
              contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
              trailing: IconButton(onPressed: selectRoom, icon: const Icon(Icons.add)),
            ),
            if (widget.selectedRooms.length > 1)
              Wrap(
                spacing: 8.0, // gap between adjacent chips
                runSpacing: 4.0, // gap between lines
                children: [
                  for (var i = 0; i < widget.selectedRooms.length; i++)
                    Chip(
                      label: Text(
                        widget.selectedRooms[i].name,
                        style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      deleteIconColor: Theme.of(context).colorScheme.onTertiary,
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

  Widget getTitle() {
    var title = '';
    if (widget.selectedRooms.isEmpty) {
      title = 'Room *';
    } else if (widget.selectedRooms.length == 1) {
      title = widget.selectedRooms[0].name;
    } else {
      title = 'Task will be created for each room';
    }
    return Text(
      title,
      style: TextStyle(color: widget.showError ? Theme.of(context).colorScheme.error : null),
    );
  }

  Widget? getSubtitle() {
    if (widget.showError) {
      return Text(
        'Room is required',
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      );
    } else {
      return null;
    }
  }

  Future<void> selectRoom() async {
    hideKeyboard();
    RoomPickerPopData result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomPickerMultiple(
          selectedRooms: widget.selectedRooms,
        ),
      ),
    );
    widget.onRoomsChange(result.selectedRooms);
  }

  void onDeleteRoom(Room room) {
    var rooms = widget.selectedRooms.where((x) => x.id != room.id).toList();
    widget.onRoomsChange(rooms);
  }
}
