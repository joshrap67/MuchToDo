import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/providers/settings_provider.dart';
import 'package:much_todo/src/screens/room_list/room_info_card.dart';
import 'package:much_todo/src/utils/dialogs.dart';
import 'package:much_todo/src/utils/enums.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/skeletons/rooms_list_skeleton.dart';
import 'package:much_todo/src/widgets/sort_direction_button.dart';
import 'package:provider/provider.dart';

class RoomList extends StatefulWidget {
  const RoomList({super.key});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> with AutomaticKeepAliveClientMixin {
  RoomSortOption _sortByValue = RoomSortOption.name;
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
  Widget build(BuildContext context) {
    super.build(context);
    var rooms = context.watch<RoomsProvider>().rooms;
    if (context.watch<RoomsProvider>().isLoading) {
      return const RoomsListSkeleton();
    } else {
      return Stack(
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
                    padding: const EdgeInsets.only(bottom: 65),
                    itemBuilder: (ctx, index) {
                      var room = rooms[index];
                      return RoomInfoCard(key: UniqueKey(), room: room);
                    },
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              child: FloatingActionButton.extended(
                onPressed: promptAddRoom,
                label: const Text('NEW ROOM'),
                icon: const Icon(Icons.add),
                heroTag: 'NewRoom',
              ),
            ),
          ),
        ],
      );
    }
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

  Future<void> promptAddRoom() async {
    await Dialogs.promptAddRoom(context);
  }

  void promptSortRooms() {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog.adaptive(
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setSort();
              },
              child: const Text('APPLY'),
            )
          ],
          insetPadding: const EdgeInsets.all(8.0),
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
                              child: DropdownButton<RoomSortOption>(
                                value: _sortByValue,
                                dropdownColor: getDropdownColor(context),
                                onChanged: (RoomSortOption? value) {
                                  setState(() {
                                    _sortByValue = value!;
                                  });
                                },
                                items:
                                    RoomSortOption.values.map<DropdownMenuItem<RoomSortOption>>((RoomSortOption value) {
                                  return DropdownMenuItem<RoomSortOption>(value: value, child: Text(value.label));
                                }).toList(),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SortDirectionButton(
                            sortDirection: _sortDirectionValue,
                            onChange: (sort) {
                              setState(() {
                                _sortDirectionValue = sort;
                              });
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
      },
    );
  }

  void setSort() {
    context.read<RoomsProvider>().setSort(_sortByValue, _sortDirectionValue);
    context.read<SettingsProvider>().updateRoomSort(_sortByValue, _sortDirectionValue);
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}
