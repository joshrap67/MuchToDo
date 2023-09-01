import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/screens/home/room_list/create_room.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

class PendingRoomsCard extends StatefulWidget {
  final List<Room> selectedRooms;
  final ValueChanged<List<Room>> onChange;

  const PendingRoomsCard({super.key, required this.selectedRooms, required this.onChange});

  @override
  State<PendingRoomsCard> createState() => _PendingRoomsCardState();
}

class RoomOption {
  Room? room;
  bool hasResults = true;

  RoomOption({this.room, this.hasResults = true});
}

class _PendingRoomsCardState extends State<PendingRoomsCard> {
  List<Room> _selectedRooms = [];
  final _autoCompleteController = TextEditingController();
  final _focusNode = FocusNode();
  final _textFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedRooms = [...widget.selectedRooms];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: LayoutBuilder(builder: (context, BoxConstraints constraints) {
            return RawAutocomplete<RoomOption>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                var rooms = context.read<RoomsProvider>().rooms;
                if (rooms.isEmpty) {
                  // if user has none in the first place give them an option to create one from here
                  return [RoomOption(hasResults: false)];
                }

                // don't show options that are already selected
                if (textEditingValue.text == '') {
                  return rooms
                      .where((element) => !_selectedRooms.any((t) => t.id == element.id))
                      .map((e) => RoomOption(room: e));
                }

                var filteredRooms = rooms
                    .where((element) => element.name.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                    .where((element) => !_selectedRooms.any((t) => t.id == element.id));
                if (filteredRooms.isNotEmpty) {
                  return filteredRooms.map((e) => RoomOption(room: e));
                } else {
                  // hack, but I want to show a footer when no results are found to allow user to create items on the fly
                  return [RoomOption(hasResults: false)];
                }
              },
              textEditingController: _autoCompleteController,
              focusNode: _focusNode,
              displayStringForOption: (roomOption) => roomOption.room!.name,
              fieldViewBuilder: (context, fieldTextEditingController, fieldFocusNode, onFieldSubmitted) {
                return TextFormField(
                  key: _textFieldKey,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.house),
                    labelText: _selectedRooms.isEmpty
                        ? 'Room *'
                        : '${_selectedRooms.length} Task${_selectedRooms.length > 1 ? 's' : ''} will be made',
                  ),
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  validator: (_) {
                    if (_selectedRooms.isEmpty) {
                      return 'Required';
                    } else {
                      return null;
                    }
                  },
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                        // bug with flutter, without this there is overflow on right
                        maxHeight: 300,
                      ),
                      child: Scrollbar(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            final RoomOption option = options.elementAt(index);
                            if (option.hasResults) {
                              return ListTile(
                                title: Text(option.room!.name),
                                onTap: () => onSelected(option),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: OutlinedButton.icon(
                                  label: const Text('CREATE NEW ROOM'),
                                  onPressed: addRoom,
                                  icon: const Icon(Icons.add),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              onSelected: selectRoom,
            );
          }),
        ),
        if (_selectedRooms.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: [
                for (var i = 0; i < _selectedRooms.length; i++)
                  Chip(
                    label: Text(
                      _selectedRooms[i].name,
                      style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    deleteIconColor: Theme.of(context).colorScheme.onTertiary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onDeleted: () {
                      onDeleteRoom(_selectedRooms[i]);
                    },
                  ),
              ],
            ),
          )
      ],
    );
  }

  void selectRoom(RoomOption? roomOption) {
    if (roomOption == null || roomOption.room == null) {
      return;
    }

    var room = roomOption.room!;
    _autoCompleteController.clear();
    if (!_selectedRooms.any((element) => element.id == room.id)) {
      _selectedRooms.add(room);
    } else {
      _selectedRooms.removeWhere((t) => t.id == room.id);
    }
    widget.onChange(_selectedRooms);
    hideKeyboard();
    setState(() {});
  }

  Future<void> addRoom() async {
    hideKeyboard();
    Room? createdRoom = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRoom(
          name: _autoCompleteController.text,
        ),
      ),
    );
    if (createdRoom != null) {
      selectRoom(RoomOption(room: createdRoom));
    }
  }

  void onDeleteRoom(Room room) {
    hideKeyboard();
    setState(() {
      _selectedRooms.removeWhere((element) => element.id == room.id);
      widget.onChange(_selectedRooms);
    });
  }
}
