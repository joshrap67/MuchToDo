import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/screens/home/room_list/create_room.dart';
import 'package:much_todo/src/screens/home/room_list/room_info_card.dart';
import 'package:much_todo/src/utils/enums.dart';
import 'package:much_todo/src/widgets/skeletons/rooms_list_skeleton.dart';
import 'package:provider/provider.dart';

class RoomList extends StatefulWidget {
  const RoomList({super.key});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> with AutomaticKeepAliveClientMixin {
  final _scrollController = ScrollController();

  bool _showFab = true;

  RoomSortOptions _sortByValue = RoomSortOptions.name;
  SortDirection _sortDirectionValue = SortDirection.ascending;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sortByValue = context.read<RoomsProvider>().sort;
      _sortDirectionValue = context.read<RoomsProvider>().sortDirection;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var rooms = context.watch<RoomsProvider>().rooms;
    if (context.watch<RoomsProvider>().isLoading) {
      return const RoomsListSkeleton();
    } else {
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
                    '${totalTasks()} Total Tasks | ${NumberFormat.currency(symbol: '\$').format(totalCost())}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: promptSortRooms,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: Scrollbar(
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
  }

  void setSort() {
    context.read<RoomsProvider>().setSort(_sortByValue, _sortDirectionValue);
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

  void promptSortRooms() {
    showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog.adaptive(
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context, 'OK');
                  setSort();
                  setState(() {});
                },
                child: const Text('APPLY'),
              )
            ],
            title: const Text('Sort Rooms'),
            content: StatefulBuilder(
              builder: (statefulContext, setState) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: InputDecorator(
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                                labelText: 'Sort By',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<RoomSortOptions>(
                                  value: _sortByValue,
                                  onChanged: (RoomSortOptions? value) {
                                    setState(() {
                                      _sortByValue = value!;
                                    });
                                  },
                                  items: RoomSortOptions.values
                                      .map<DropdownMenuItem<RoomSortOptions>>((RoomSortOptions value) {
                                    return DropdownMenuItem<RoomSortOptions>(value: value, child: Text(value.label));
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: IconButton(
                              icon: _sortDirectionValue == SortDirection.descending
                                  ? const Icon(Icons.arrow_downward_sharp)
                                  : const Icon(Icons.arrow_upward_sharp),
                              tooltip: _sortDirectionValue == SortDirection.descending ? 'Descending' : 'Ascending',
                              onPressed: () {
                                if (_sortDirectionValue == SortDirection.descending) {
                                  _sortDirectionValue = SortDirection.ascending;
                                } else {
                                  _sortDirectionValue = SortDirection.descending;
                                }
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}
