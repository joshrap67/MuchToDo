import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/rooms/room_details.dart';

class RoomInfoCard extends StatefulWidget {
  final Room room;

  const RoomInfoCard({super.key, required this.room});

  @override
  State<RoomInfoCard> createState() => _RoomInfoCardState();
}

class _RoomInfoCardState extends State<RoomInfoCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(widget.room.name),
            subtitle: Text(
              getSubtitle(),
              style: const TextStyle(fontSize: 11),
            ),
            trailing: TextButton(
              onPressed: openRoom,
              child: const Text('OPEN'),
            ),
          ),
        ],
      ),
    );
  }

  String getSubtitle() {
    return widget.room.tasks.isEmpty
        ? '${widget.room.tasks.length} Tasks'
        : '${widget.room.tasks.length} Tasks | ${NumberFormat.currency(symbol: '\$').format(widget.room.totalCost())}';
  }

  // todo have a completed indicator

  // todo loop through all tasks and get total estimate cost for room

  Future<void> openRoom() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoomDetails(room: widget.room)),
    );
  }
}
