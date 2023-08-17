import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/rooms/create_room.dart';
import 'package:much_todo/src/rooms/room_info_card.dart';
import 'package:much_todo/src/utils/globals.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

class RoomList extends StatefulWidget {
  const RoomList({super.key});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  bool _showFab = true;
  RoomSortingValues sortValue = RoomSortingValues.alphaAscending; // todo shared prefs?

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var rooms = context.watch<RoomsProvider>().rooms;
    return NotificationListener<UserScrollNotification>(
      onNotification: (notification) {
        var direction = notification.direction;
        setState(() {
          if (direction == ScrollDirection.reverse) {
            _showFab = false;
          } else if (direction == ScrollDirection.forward) {
            _showFab = true;
          }
        });
        return true;
      },
      child: Stack(
        children: [
          Column(
            children: [
              ListTile(
                title: Text(
                  '${rooms.length} Total Rooms',
                  style: const TextStyle(fontSize: 22),
                ),
                subtitle: Text(
                  '${totalTasks()} Total Active Tasks | ${NumberFormat.currency(symbol: '\$').format(totalCost())}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: sortDropdown(),
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: rooms.length,
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 65),
                  itemBuilder: (ctx, index) {
                    var room = rooms[index];
                    return RoomInfoCard(room: room);
                  },
                ),
              ),
            ],
          ),
          Visibility(
            visible: true,
            child: Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: _showFab
                      ? FloatingActionButton.extended(
                          onPressed: launchAddRoom,
                          label: const Text('ADD ROOM'),
                          icon: const Icon(Icons.add),
                          heroTag: 'RoomFab',
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sortDropdown() {
    return PopupMenuButton(
      icon: const Icon(Icons.sort_rounded),
      tooltip: 'Sort Media',
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      initialValue: sortValue,
      itemBuilder: (context) {
        hideKeyboard();
        return <PopupMenuEntry<RoomSortingValues>>[
          const PopupMenuItem<RoomSortingValues>(
            value: RoomSortingValues.alphaAscending,
            child: Text('Room Name (A-Z)'),
          ),
          const PopupMenuItem<RoomSortingValues>(
            value: RoomSortingValues.alphaDescending,
            child: Text('Room Name (Z-A)'),
          ),
        ];
      },
      onSelected: (RoomSortingValues result) => onSortSelected(result),
    );
  }

  void onSortSelected(RoomSortingValues result) {
	  sortValue = result;
	  setState(() {});
	  context.read<RoomsProvider>().sortRooms(result);
  }

  int totalTasks() {
    var sum = 0;
    for (var room in context.read<RoomsProvider>().rooms) {
      sum += room.tasks.length;
    }
    return sum;
  }

  double totalCost() {
    var cost = 0.0;
    for (var room in context.read<RoomsProvider>().rooms) {
      cost += room.totalCost();
    }
    return cost;
  }

  void launchAddRoom() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateRoom()),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
