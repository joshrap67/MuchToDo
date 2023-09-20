import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/screens/room_details/room_details.dart';
import 'package:much_todo/src/services/rooms_service.dart';
import 'package:much_todo/src/utils/utils.dart';

class RoomInfoCard extends StatefulWidget {
  final Room room;

  const RoomInfoCard({super.key, required this.room});

  @override
  State<RoomInfoCard> createState() => _RoomInfoCardState();
}

class _RoomInfoCardState extends State<RoomInfoCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.room.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(widget.room.name),
            leading: IconButton(
              icon: _isFavorite ? const Icon(Icons.star) : const Icon(Icons.star_border_outlined),
              tooltip: _isFavorite ? 'Unfavorite' : 'Favorite',
              onPressed: () async {
                setState(() {
                  _isFavorite = !_isFavorite;
                });
                var result = await RoomsService.setFavorite(context, widget.room.id, _isFavorite);
                if (context.mounted && result.failure) {
                  showSnackbar('There was a problem favoriting ${widget.room.name}', context);
                }
              },
              color: _isFavorite ? const Color(0xFFe3a805) : Theme.of(context).iconTheme.color,
            ),
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

  void openRoom() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoomDetails(room: widget.room)),
    );
  }
}
