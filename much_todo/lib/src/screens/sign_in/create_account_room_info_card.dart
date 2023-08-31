import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';

class CreateAccountRoomInfoCard extends StatelessWidget {
  final Room room;
  final VoidCallback delete;

  const CreateAccountRoomInfoCard({super.key, required this.room, required this.delete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(room.name),
            subtitle: Text(
              getSubtitle(),
              style: const TextStyle(fontSize: 11),
            ),
			  trailing: IconButton(icon: const Icon(Icons.delete), onPressed: delete),
          ),
        ],
      ),
    );
  }

  String getSubtitle() {
    return room.note == null || room.note!.isEmpty ? '' : '${room.note}';
  }
}
