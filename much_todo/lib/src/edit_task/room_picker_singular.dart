import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/rooms/create_room.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

class RoomPickerPopData {
  Room? selectedRoom;

  RoomPickerPopData(this.selectedRoom);
}

class RoomPickerSingular extends StatefulWidget {
  final Room? selectedRoom;

  const RoomPickerSingular({super.key, this.selectedRoom});

  @override
  State<RoomPickerSingular> createState() => _RoomPickerSingularState();
}

class _RoomPickerSingularState extends State<RoomPickerSingular> {
  final TextEditingController _searchController = TextEditingController();

  Room? _selectedRoom;

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.selectedRoom;
  }

  @override
  Widget build(BuildContext context) {
    var rooms = getRooms();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Select Room'),
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, RoomPickerPopData(_selectedRoom));
            return false;
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                child: SearchBar(
                  leading: const Icon(Icons.search),
                  controller: _searchController,
                  hintText: 'Search Rooms',
                  onChanged: (_) {
                    setState(() {});
                  },
                  trailing: _searchController.text.isNotEmpty
                      ? <Widget>[
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              hideKeyboard();
                              setState(() {});
                            },
                          )
                        ]
                      : null,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: rooms.length + 1,
                  // todo key?
                  itemBuilder: (BuildContext ctx, int index) {
                    if (index < rooms.length) {
                      var room = rooms[index];
                      return CheckboxListTile(
                        value: _selectedRoom != null && room.id == _selectedRoom!.id,
                        onChanged: (bool? value) {
                          roomSelected(room);
                        },
                        title: Text(room.name),
                      );
                    } else {
                      // footer
                      return OutlinedButton.icon(
                        label: const Text('DON\'T SEE A ROOM? CREATE ONE'),
                        onPressed: addRoom,
                        icon: const Icon(Icons.add),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Room> getRooms() {
    if (_searchController.text.isNotEmpty) {
      var lowerCaseSearch = _searchController.text.toLowerCase();
      return context
          .read<RoomsProvider>()
          .rooms
          .where((element) => element.name.toLowerCase().contains(lowerCaseSearch))
          .toList();
    } else {
      return context.watch<RoomsProvider>().rooms;
    }
  }

  Future<void> addRoom() async {
    hideKeyboard();
    Room? createdRoom = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRoom(
          name: _searchController.text,
        ),
      ),
    );
    if (createdRoom != null) {
      roomSelected(createdRoom);
      setState(() {
        _selectedRoom = createdRoom;
      });
    }
  }

  void roomSelected(Room room) {
    if (_selectedRoom != null && room.id == _selectedRoom!.id) {
      // unselect the room
      _selectedRoom = null;
    } else {
      _selectedRoom = room;
    }
    hideKeyboard();
    setState(() {});
  }
}
