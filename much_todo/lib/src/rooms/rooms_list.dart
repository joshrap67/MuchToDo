import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/rooms/create_room.dart';
import 'package:much_todo/src/rooms/room_info_card.dart';
import 'package:uuid/uuid.dart';

class RoomList extends StatefulWidget {
  const RoomList({super.key});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  final List<Room> _rooms = [];
  final _scrollController = ScrollController();

  bool _showFab = true;
  Timer showFabDebounce = Timer(const Duration(seconds: 1), () {});

  Future<void> debounceShowFab() async {}

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 15; i++) {
      _rooms.add(Room(const Uuid().v4(), 'Room ${i + 1}', []));
    }

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
    return Stack(
      children: [
        Column(
          children: [
            Card(
              child: ListTile(
                title: Text('${_rooms.length} Total Rooms'),
                subtitle:
                    Text('${totalTodos()} Total To Dos | ${NumberFormat.currency(symbol: '\$').format(totalCost())}'),
                trailing: IconButton(
                  icon: const Icon(Icons.sort),
                  onPressed: () {},
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _rooms.length,
                shrinkWrap: true,
                controller: _scrollController,
                key: const PageStorageKey('room-list'),
                padding: const EdgeInsets.only(bottom: 65),
                itemBuilder: (ctx, index) {
                  var room = _rooms[index];
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

  int totalTodos() {
    var sum = 0;
    for (var room in _rooms) {
      sum += room.todos.length;
    }
    return sum;
  }

  double totalCost() {
    var cost = 0.0;
    for (var room in _rooms) {
      cost += room.totalCost();
    }
    return cost;
  }

  Future<void> launchAddRoom() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateRoom()),
    );
    if (result != null) {
      setState(() {
        _rooms.add(result);
      });
    }
  }
}
