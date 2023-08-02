import 'package:flutter/material.dart';
import 'package:much_todo/src/rooms/create_room.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

import '../domain/room.dart';
import '../providers/rooms_provider.dart';

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

  List<Room> _displayedRooms = [];
  Room? _selectedRoom;

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.selectedRoom;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _displayedRooms = _allRooms();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Select Room'),
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
              TextField(
                decoration: const InputDecoration(
                  label: Text('Search Rooms'),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                controller: _searchController,
                onChanged: filterRooms,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _displayedRooms.length + 1,
                  // todo key?
                  itemBuilder: (BuildContext ctx, int index) {
                    if (index < _displayedRooms.length) {
                      var room = _displayedRooms[index];
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

  List<Room> _allRooms() {
    return context.read<RoomsProvider>().rooms;
  }

  void filterRooms(String text) {
    var lowerCaseSearch = text.toLowerCase();
    setState(() {
      if (lowerCaseSearch.isEmpty) {
        _displayedRooms = _allRooms();
      } else {
        _displayedRooms = _allRooms().where((element) => element.name.toLowerCase().contains(lowerCaseSearch)).toList();
      }
    });
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
        _displayedRooms.add(createdRoom);
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
    setState(() {});
  }
}
