import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/rooms/create_room.dart';
import 'package:much_todo/src/rooms/room_info_card.dart';
import 'package:provider/provider.dart';

class RoomList extends StatefulWidget {
  const RoomList({super.key});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  final _scrollController = ScrollController();

  bool _showFab = true;
  Timer showFabDebounce = Timer(const Duration(seconds: 1), () {});

  Future<void> debounceShowFab() async {}

  @override
  void initState() {
    super.initState();

    // need to wait for controller to be attached to list
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.position.isScrollingNotifier.addListener(() {
        showFabDebounce.cancel();
        if (_scrollController.position.isScrollingNotifier.value && _showFab) {
          // second conditional check is to avoid constant re-renders
          setState(() {
            _showFab = false;
          });
        } else if (!_scrollController.position.isScrollingNotifier.value && !_showFab) {
          showFabDebounce = Timer(const Duration(milliseconds: 800), () {
            setState(() {
              _showFab = true;
            });
          });
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var rooms = context.watch<RoomsProvider>().rooms;
    return Stack(
      children: [
        Column(
          children: [
            Card(
              child: ListTile(
                title: Text('${rooms.length} Total Rooms'),
                subtitle: Text(
                    '${totalTasks()} Total Active Tasks | ${NumberFormat.currency(symbol: '\$').format(totalCost())}'),
                trailing: IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () {},
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: rooms.length,
                shrinkWrap: true,
                controller: _scrollController,
                key: const PageStorageKey('room-list'),
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
                    ? FloatingActionButton(
                        onPressed: launchAddRoom,
                        child: const Icon(Icons.add),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
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

  Future<void> launchAddRoom() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateRoom()),
    );
  }
}
