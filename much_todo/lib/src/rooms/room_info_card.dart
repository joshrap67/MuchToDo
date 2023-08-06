import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/room.dart';

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
              '${widget.room.todos.length} To Dos',
              style: const TextStyle(fontSize: 11),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 0.0, 0.0),
                child: Text(
                  '${NumberFormat.currency(symbol: '\$').format(widget.room.totalCost())} Total Estimated Cost',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              TextButton(
                onPressed: openRoom,
                child: const Text('OPEN'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // todo loop through all to dos and get total estimate cost for room

  Future<void> openRoom() async {}
}
