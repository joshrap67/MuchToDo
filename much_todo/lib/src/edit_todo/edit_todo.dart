import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:much_todo/src/createTodo/effort_picker.dart';
import 'package:much_todo/src/createTodo/people_card.dart';
import 'package:much_todo/src/createTodo/priority_picker.dart';
import 'package:much_todo/src/createTodo/tags_card.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/todo.dart';
import 'package:much_todo/src/edit_todo/room_card.dart';
import 'package:much_todo/src/utils/globals.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/loading_button.dart';
import 'package:much_todo/src/widgets/links_card.dart';
import 'package:much_todo/src/widgets/photos_card.dart';
import 'package:uuid/uuid.dart';

import '../domain/professional.dart';
import 'package:intl/intl.dart';

class EditTodo extends StatefulWidget {
  final Todo todo;

  const EditTodo({super.key, required this.todo});

  @override
  State<EditTodo> createState() => _EditTodoState();
}

class _EditTodoState extends State<EditTodo> {
  bool shouldPop = false;

  late int _priority;
  late int _effort;

  List<String> _links = [];
  List<XFile> _pictures = [];
  Room? _selectedRoom;
  List<Room> _allRooms = [];
  DateTime? _completeBy;
  List<Professional> _people = [];
  List<String> _tags = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _completeByController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _approximateCostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _allRooms.add(Room('A', 'Bedroom', []));
    _allRooms.add(Room('B', 'Bathroom', []));
    _allRooms.add(Room('C', 'Kitchen', []));

    _nameController.text = widget.todo.name;
    _priority = widget.todo.priority;
    _effort = widget.todo.effort;
    // _selectedRoom = widget.todo.roomId;
    _tags = [...widget.todo.tags];
    _people = [...widget.todo.professionals];
    _links = [...widget.todo.links];
    _approximateCostController.text = widget.todo.approximateCost != null ? widget.todo.approximateCost.toString() : '';
    _noteController.text = widget.todo.note ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isModified() && !shouldPop) {
          promptUnsavedChanges();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit To Do'),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.sticky_note_2),
                                border: OutlineInputBorder(),
                                hintText: 'Name of Todo',
                                labelText: 'Name *',
                              ),
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              maxLength: Constants.maxNameLength,
                              validator: validName,
                            ),
                          ),
                        ),
                        PriorityPicker(
                          priority: _priority,
                          onChange: (p) {
                            setState(() {
                              hideKeyboard();
                              _priority = p;
                            });
                          },
                        ),
                        EffortPicker(
                          effort: _effort,
                          onChange: (p) {
                            setState(() {
                              hideKeyboard();
                              _effort = p;
                            });
                          },
                        ),
                        const Divider(),
                        RoomCard(
                          selectedRoom: _selectedRoom,
                          rooms: _allRooms,
                          onRoomChange: (room) {
                            setState(() {
                              _selectedRoom = room;
                            });
                          },
                          onAllRoomsChanged: (rooms) {
                            setState(() {
                              _allRooms = [...rooms];
                            });
                          },
                        ),
                        TagsCard(
                          tags: _tags,
                          onChange: (tags) {
                            _tags = [...tags];
                          },
                        ),
                        PeopleCard(
                            people: _people,
                            onChange: (people) {
                              _people = [...people];
                            }),
                        LinksCard(
                          links: _links,
                          onChange: (links) {
                            _links = [...links];
                          },
                        ),
                        PhotosCard(
                          photos: _pictures,
                          onChange: (photos) {
                            _pictures = [...photos];
                          },
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.attach_money),
                                      hintText: 'Approximate cost',
                                      labelText: 'Cost',
                                    ),
                                    inputFormatters: [
                                      CurrencyTextInputFormatter(locale: 'en', symbol: '\$', enableNegative: false)
                                    ],
                                    keyboardType: TextInputType.number,
                                    controller: _approximateCostController,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                                  child: TextFormField(
                                    controller: _completeByController,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      prefixIcon: const Icon(Icons.date_range),
                                      border: const OutlineInputBorder(),
                                      hintText: 'Complete By',
                                      labelText: 'Complete By',
                                      suffixIcon: _completeByController.text.isNotEmpty
                                          ? IconButton(
                                              onPressed: () {
                                                setState(() {
                                                  _completeByController.clear();
                                                });
                                              },
                                              icon: const Icon(Icons.clear),
                                            )
                                          : null,
                                    ),
                                    onTap: () async {
                                      hideKeyboard();
                                      DateTime? pickDate = await showDatePicker(
                                          context: context,
                                          initialDate: DateTime.now(),
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime(2100));
                                      if (pickDate != null) {
                                        setState(() {
                                          _completeBy = pickDate;
                                          _completeByController.text = DateFormat('yyyy-MM-dd').format(pickDate);
                                        });
                                      }
                                      hideKeyboard();
                                    },
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: _noteController,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              onChanged: (v) {
                                setState(() {
                                  // to get the clear button to show. gotta be a better way...
                                });
                              },
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.note_alt),
                                border: const OutlineInputBorder(),
                                hintText: 'Note',
                                labelText: 'Note',
                                suffixIcon: _noteController.text.isNotEmpty
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _noteController.clear();
                                          });
                                        },
                                        icon: const Icon(Icons.clear),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LoadingButton(
                  onSubmit: onSubmit,
                  label: 'SAVE',
                  icon: const Icon(Icons.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool isModified() {
    return _nameController.text.isNotEmpty ||
        _priority != widget.todo.priority ||
        _effort != widget.todo.effort ||
        _approximateCostController.text.isNotEmpty ||
        _noteController.text.isNotEmpty ||
        _selectedRoom?.id != widget.todo.roomId ||
        _tags.isNotEmpty ||
        _people.isNotEmpty ||
        _links.isNotEmpty ||
        _pictures.isNotEmpty ||
        _completeByController.text.isNotEmpty;
  }

  String? validName(String? name) {
    if (name.isNullOrEmpty()) {
      return 'Required';
    }
    return null;
  }

  void promptUnsavedChanges() {
    hideKeyboard();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Unsaved Changes'),
          content: (const Text('You have changes that are not saved. Do you wish to discard these changes?')),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('CANCEL')),
            TextButton(
                onPressed: () {
                  setState(() {
                    Navigator.of(context).pop(); // close popup
                    Navigator.of(context).pop(); // pop this page
                    shouldPop = true;
                  });
                },
                child: const Text('LEAVE')),
          ],
        );
      },
    );
  }

  Future<void> onSubmit() async {
    if (!_formKey.currentState!.validate()) {
      showSnackbar('Invalid input.', context);
      return;
    }

    await Future.delayed(const Duration(seconds: 2), () {
      hideKeyboard();
      double? approximateCost =
          double.tryParse(_approximateCostController.text.toString().replaceAll(RegExp(r'[$,]+'), ''));
      var todo = Todo(
          const Uuid().v4(),
          _nameController.text.toString().trim(),
          _tags,
          _priority,
          _effort,
          null,
          approximateCost,
          _noteController.text.toString().trim(),
          _links,
          [],
          // todo need to upload
          _people,
          false,
          false,
          _completeBy);

      Navigator.of(context).pop(todo);
    });
  }
}
