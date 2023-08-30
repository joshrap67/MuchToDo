import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/rooms_list/room_info_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RoomsListSkeleton extends StatefulWidget {
  const RoomsListSkeleton({super.key});

  @override
  State<RoomsListSkeleton> createState() => _RoomsListSkeletonState();
}

class _RoomsListSkeletonState extends State<RoomsListSkeleton> {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          const ListTile(
            title: Text(
              '10 Total Rooms',
              style: TextStyle(fontSize: 22),
            ),
            subtitle: Text(
              '10 Total Tasks | \$1.00',
              style: TextStyle(fontSize: 12),
            ),
            trailing: Icon(Icons.sort),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: 15,
              padding: const EdgeInsets.only(bottom: 65),
              itemBuilder: (ctx, index) {
                return RoomInfoCard(room: Room(index.toString(), 'Bedroom', 'note', []));
              },
            ),
          ),
        ],
      ),
    );
  }
}
