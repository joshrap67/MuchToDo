import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/edit_task/room_picker_singular.dart';
import 'package:much_todo/src/utils/utils.dart';

class RoomCard extends StatefulWidget {
  final Room? selectedRoom;
  final ValueChanged<Room?> onRoomChange;
  final bool showError;

  const RoomCard({super.key, this.selectedRoom, required this.onRoomChange, this.showError = false});

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
              title: getTitle(),
              subtitle: getSubtitle(),
              leading: Icon(
                Icons.home,
                color: widget.showError ? Theme.of(context).colorScheme.error : null,
              ),
              contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
              trailing: IconButton(onPressed: selectRoom, icon: const Icon(Icons.add)),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTitle() {
    var title = '';
    if (widget.selectedRoom == null) {
      title = 'Room *';
    } else {
      title = widget.selectedRoom!.name;
    }
    return Text(
      title,
      style: TextStyle(color: widget.showError ? Theme.of(context).colorScheme.error : null),
    );
  }

  Widget? getSubtitle() {
    // todo shake the card?
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
        builder: (context) => RoomPickerSingular(
          selectedRoom: widget.selectedRoom,
        ),
      ),
    );
    widget.onRoomChange(result.selectedRoom);
  }
}
