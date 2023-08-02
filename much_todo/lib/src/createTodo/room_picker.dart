import 'package:flutter/material.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/rooms/create_room.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

import '../domain/room.dart';

class RoomPickerPopData {
  List<Room> selectedRooms;

  RoomPickerPopData(this.selectedRooms);
}

class RoomPicker extends StatefulWidget {
  final List<Room> selectedRooms;

  const RoomPicker({super.key, this.selectedRooms = const []});

  @override
  State<RoomPicker> createState() => _RoomPickerState();
}

class _RoomPickerState extends State<RoomPicker> {
  final TextEditingController _searchController = TextEditingController();

  List<Room> _displayedRooms = [];
  List<Room> _selectedRooms = [];

  @override
  void initState() {
    super.initState();
    _selectedRooms = [...widget.selectedRooms];
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
            Navigator.pop(context, RoomPickerPopData(_selectedRooms));
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
                        value: _selectedRooms.any((element) => element.id == room.id),
                        onChanged: (bool? value) {
                          roomSelected(value ?? true, room);
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
      setState(() {
        _selectedRooms.add(createdRoom);
        _displayedRooms.add(createdRoom);
      });
    }
  }

  void roomSelected(bool selected, Room room) {
    if (selected) {
      // unselect the room
      _selectedRooms.add(room);
    } else {
      _selectedRooms.removeWhere((element) => element.id == room.id);
    }
    setState(() {});
  }
}
