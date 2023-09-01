import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/screens/home/room_list/create_room.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

class PendingRoomSelector extends StatefulWidget {
  final Room? selectedRoom;
  final ValueChanged<Room?> onRoomChange;

  const PendingRoomSelector({super.key, this.selectedRoom, required this.onRoomChange});

  @override
  State<PendingRoomSelector> createState() => _PendingRoomSelectorState();
}

class RoomOption {
  Room? room;
  bool hasResults = true;

  RoomOption({this.room, this.hasResults = true});
}

class _PendingRoomSelectorState extends State<PendingRoomSelector> {
  Room? _selectedRoom;
  final _autoCompleteController = TextEditingController();
  final _focusNode = FocusNode();
  final _textFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.selectedRoom;
    _autoCompleteController.text = _selectedRoom?.name ?? '';
  }

  @override
  void dispose() {
    _autoCompleteController.dispose();
    super.dispose();
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
                  return rooms.map((e) => RoomOption(room: e));
                }

                var filteredRooms =
                    rooms.where((element) => element.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
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
                return Focus(
                  onFocusChange: (hasFocus) {
                    if (!hasFocus) {
                      if (_selectedRoom == null) {
                        _autoCompleteController.clear();
                      } else {
                        _autoCompleteController.text = _selectedRoom!.name;
                      }
                    }
                  },
                  child: TextFormField(
                    key: _textFieldKey,
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.house),
                        labelText: "Room *",
                        suffixIcon: _autoCompleteController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedRoom = null;
                                    widget.onRoomChange(_selectedRoom);
                                    _autoCompleteController.clear();
                                  });
                                },
                                icon: const Icon(Icons.clear))
                            : null),
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    validator: (_) {
                      if (_selectedRoom == null) {
                        return 'Required';
                      } else {
                        return null;
                      }
                    },
                  ),
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
      ],
    );
  }

  void selectRoom(RoomOption? roomOption) {
    if (roomOption == null || roomOption.room == null) {
      return;
    }

    var room = roomOption.room!;
    _selectedRoom = room;
    widget.onRoomChange(_selectedRoom);

    _autoCompleteController.clear();
    hideKeyboard();
    setState(() {});
  }

  Future<void> addRoom() async {
    var name = _autoCompleteController.text; // since onFocus lost input is cleared, grab before hiding keyboard
    hideKeyboard();
    Room? createdRoom = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateRoom(
          name: name,
        ),
      ),
    );
    if (createdRoom != null) {
      selectRoom(RoomOption(room: createdRoom));
    }
  }
}
