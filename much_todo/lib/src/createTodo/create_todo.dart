import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:much_todo/src/createTodo/effort_picker.dart';
import 'package:much_todo/src/createTodo/people_card.dart';
import 'package:much_todo/src/createTodo/priority_picker.dart';
import 'package:much_todo/src/createTodo/room_card.dart';
import 'package:much_todo/src/createTodo/tags_card.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/loading_button.dart';
import 'package:much_todo/src/widgets/links_card.dart';
import 'package:much_todo/src/widgets/photos_card.dart';

import '../domain/professional.dart';
import 'package:intl/intl.dart';

class CreateTodo extends StatefulWidget {
  final String? roomId;

  const CreateTodo({super.key, this.roomId});

  @override
  State<CreateTodo> createState() => _CreateTodoState();
}

class _CreateTodoState extends State<CreateTodo> {
  String? _name = '';
  List<String> _tags = [];
  int _priority = 3;
  int _effort = 3;
  double? _approximateCost;
  String? _note;
  List<String> _links = [];
  List<Professional> _people = [];
  List<XFile> _pictures = [];
  Professional? _professional; // allow professional to be created from here
  DateTime? _completeBy;
  Room? _selectedRoom;
  List<Room> _rooms = [];

  bool showAddNewRoom = false;

  // todo prevent back button if changes present

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _completeByController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _rooms.add(Room('A', 'Bedroom', []));
    _rooms.add(Room('B', 'Bathroom', []));
    _rooms.add(Room('C', 'Kitchen', []));
  }

  // todo in demo show how you can create multiple todos in one form. so like if you wanted to paint house you could do a tag of Paint2023 and have it applied to 10 rooms

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create To Do'),
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
                            keyboardType: TextInputType.name,
                            onSaved: (String? val) {
                              setState(() {
                                _name = val;
                              });
                            },
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
                        rooms: _rooms,
                        onRoomChange: (room) {
                          setState(() {
                            _selectedRoom = room;
                          });
                        },
                        onRoomsChanged: (rooms) {
                          setState(() {
                            _rooms = [...rooms];
                          });
                        },
                      ),
                      TagsCard(tags: _tags),
                      PeopleCard(people: _people),
                      LinksCard(
                          onChange: (links) {
                            _links = [...links];
                          },
                          links: _links),
                      PhotosCard(
                          onChange: (photos) {
                            _pictures = [...photos];
                          },
                          photos: _pictures),
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
                                  onSaved: (String? val) {
                                    setState(() {
                                      _approximateCost = val as double;
                                    });
                                  },
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
              child: LoadingButton(onSubmit: onSubmit),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onSubmit() async {}
}
