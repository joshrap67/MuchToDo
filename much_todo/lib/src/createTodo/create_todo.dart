import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:much_todo/src/widgets/effort_picker.dart';
import 'package:much_todo/src/createTodo/people_card.dart';
import 'package:much_todo/src/widgets/priority_picker.dart';
import 'package:much_todo/src/createTodo/room_card.dart';
import 'package:much_todo/src/createTodo/tags_card.dart';
import 'package:much_todo/src/domain/person.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/services/todo_service.dart';
import 'package:much_todo/src/utils/globals.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/loading_button.dart';
import 'package:much_todo/src/widgets/links_card.dart';
import 'package:much_todo/src/widgets/photos_card.dart';

import 'package:intl/intl.dart';

import '../domain/tag.dart';

class CreateTodo extends StatefulWidget {
  final String? roomId;

  const CreateTodo({super.key, this.roomId});

  @override
  State<CreateTodo> createState() => _CreateTodoState();
}

class _CreateTodoState extends State<CreateTodo> {
  static const int defaultPriority = 3;
  static const int defaultEffort = 2;

  bool shouldPop = false;

  int _priority = defaultPriority;
  int _effort = defaultEffort;
  List<String> _links = [];
  List<XFile> _pictures = [];
  List<Room> _selectedRooms = [];
  DateTime? _completeBy;
  List<Person> _people = [];
  List<Tag> _tags = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _completeByController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _estimatedCostController = TextEditingController();

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
          title: const Text('Create To Do'),
          scrolledUnderElevation: 0,
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
                                  counterText: ''),
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
                          onChange: (e) {
                            setState(() {
                              hideKeyboard();
                              _effort = e;
                            });
                          },
                        ),
                        const Divider(),
                        RoomCard(
                          selectedRooms: _selectedRooms,
                          onRoomsChange: (room) {
                            setState(() {
                              _selectedRooms = room;
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
                                      hintText: 'Estimated cost',
                                      labelText: 'Cost',
                                    ),
                                    inputFormatters: [
                                      CurrencyTextInputFormatter(locale: 'en', symbol: '', enableNegative: false)
                                    ],
                                    keyboardType: TextInputType.number,
                                    controller: _estimatedCostController,
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
                  label: getCreateButtonLabel(),
                  icon: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String getCreateButtonLabel() {
    if (_selectedRooms.length > 1) {
      return 'CREATE (${_selectedRooms.length})';
    } else {
      return 'CREATE';
    }
  }

  bool isModified() {
    return _nameController.text.isNotEmpty ||
        _priority != defaultPriority ||
        _effort != defaultEffort ||
        _estimatedCostController.text.isNotEmpty ||
        _noteController.text.isNotEmpty ||
        _selectedRooms.isNotEmpty ||
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
      double? estimatedCost = double.tryParse(_estimatedCostController.text.toString().replaceAll(',', ''));
      var createdTodos = TodoService.createTodos(
          _nameController.text.toString().trim(), _priority, _effort, 'createdBy', _selectedRooms,
          photos: _pictures,
          people: _people,
          note: _noteController.text.toString().trim(),
          links: _links,
          completeBy: _completeBy,
          estimatedCost: estimatedCost,
          tags: _tags);

      Navigator.of(context).pop(createdTodos);
    });
  }
}
