import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/utils/dialogs.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

class PendingRoomSelector extends StatefulWidget {
  final Room? selectedRoom;
  final ValueChanged<Room?> onRoomChange;
  final FocusNode? focusNode;

  const PendingRoomSelector({super.key, this.selectedRoom, this.focusNode, required this.onRoomChange});

  @override
  State<PendingRoomSelector> createState() => _PendingRoomSelectorState();
}

class RoomOption {
  Room? room;
  bool isFooter = false;

  RoomOption({this.room, this.isFooter = false});
}

class _PendingRoomSelectorState extends State<PendingRoomSelector> {
  final _autoCompleteController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  Room? _selectedRoom;

  @override
  void initState() {
    super.initState();
    _selectedRoom = widget.selectedRoom;
    _autoCompleteController.text = _selectedRoom?.name ?? '';
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    }
  }

  @override
  void dispose() {
    _autoCompleteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var maxOptionsHeight = MediaQuery.sizeOf(context).height * .35;
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, BoxConstraints constraints) {
            return RawAutocomplete<RoomOption>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                var rooms = getOptions();

                if (textEditingValue.text == '') {
                  return rooms;
                }

                var filteredRooms = rooms.where(
                    (r) => r.isFooter || r.room!.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                return filteredRooms;
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
                    scrollPadding: EdgeInsets.only(bottom: maxOptionsHeight + 50),
                    decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.room),
                        labelText: 'Room *',
                        suffixIcon: _autoCompleteController.text.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedRoom = null;
                                    widget.onRoomChange(_selectedRoom);
                                    _autoCompleteController.clear();
                                  });
                                },
                                icon: const Icon(Icons.clear),
                              )
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
                    elevation: 15,
                    color: getDropdownColor(context),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                        // bug with flutter, without this there is overflow on right
                        maxHeight: maxOptionsHeight,
                      ),
                      child: Scrollbar(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            final RoomOption option = options.elementAt(index);
                            if (!option.isFooter) {
                              return ListTile(
                                title: Text(option.room!.name),
                                onTap: () => onSelected(option),
                              );
                            } else {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: TextButton.icon(
                                  label: const Text('NEW ROOM'),
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
          },
        ),
      ],
    );
  }

  List<RoomOption> getOptions() {
    // separate method since it appears optionsBuilder uses deferred execution on the iterable defined in it, so can't call toList in it
    List<RoomOption> options = [];
    var rooms = context.read<RoomsProvider>().rooms;
    options.addAll(rooms.map((e) => RoomOption(room: e)));
    options.add(RoomOption(isFooter: true));
    return options;
  }

  void selectRoom(RoomOption? roomOption) {
    if (roomOption == null || roomOption.room == null) {
      return;
    }

    var room = roomOption.room!;
    _selectedRoom = room;
    widget.onRoomChange(_selectedRoom);

    // dumb hack, but if user did not have a text when creating the contact, options list isn't rebuild
    _autoCompleteController.text = 'a';
    _autoCompleteController.clear();

    hideKeyboard();
    setState(() {});
  }

  Future<void> addRoom() async {
    var name = _autoCompleteController.text; // since onFocus lost input is cleared, grab before hiding keyboard
    hideKeyboard();
    Room? createdRoom = await Dialogs.promptAddRoom(context, initialName: name);
    if (createdRoom != null) {
      selectRoom(RoomOption(room: createdRoom));
    }
  }
}
