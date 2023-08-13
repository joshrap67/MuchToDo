import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:much_todo/src/domain/person.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/services/task_service.dart';
import 'package:much_todo/src/widgets/effort_picker.dart';
import 'package:much_todo/src/create_task/people_card.dart';
import 'package:much_todo/src/widgets/priority_picker.dart';
import 'package:much_todo/src/create_task/tags_card.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/edit_task/room_card.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/utils/globals.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/loading_button.dart';
import 'package:much_todo/src/widgets/links_card.dart';
import 'package:much_todo/src/widgets/photos_card.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';

class EditTask extends StatefulWidget {
  final Task task;

  const EditTask({super.key, required this.task});

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  bool _shouldPop = false;
  bool _roomError = false;

  late int _priority;
  late int _effort;

  List<String> _links = [];
  List<XFile> _photos = [];
  Room? _selectedRoom;
  DateTime? _completeBy;
  List<Person> _people = [];
  List<Tag> _tags = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _completeByController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _estimatedCostController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.task.name;
    _priority = widget.task.priority;
    _effort = widget.task.effort;
    _links = [...widget.task.links];

    CurrencyTextInputFormatter formatter = CurrencyTextInputFormatter(symbol: '');
    _estimatedCostController.text =
        widget.task.estimatedCost != null ? formatter.format(widget.task.estimatedCost!.toStringAsFixed(2)) : '';

    _noteController.text = widget.task.note ?? '';
    _photos = widget.task.photos.map((e) => XFile(e)).toList();
    _completeBy = widget.task.completeBy;
    if (_completeBy != null) {
      _completeByController.text = DateFormat('yyyy-MM-dd').format(_completeBy!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedRoom = context
          .read<RoomsProvider>()
          .rooms
          .cast<Room?>()
          .firstWhere((element) => element?.id == widget.task.room.id, orElse: () => null);
      _people = context.read<UserProvider>().people.where((x) => widget.task.people.any((y) => y.id == x.id)).toList();
      _tags = context.read<UserProvider>().tags.where((x) => widget.task.tags.any((y) => y.id == x.id)).toList();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (isModified() && !_shouldPop) {
          promptUnsavedChanges();
          return false;
        } else {
          return true;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Edit Task'),
          scrolledUnderElevation: 0,
        ),
        body: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
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
                                  hintText: 'Name of Task',
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
                        RoomCard(
                          selectedRoom: _selectedRoom,
                          showError: _roomError,
                          onRoomChange: (room) {
                            setState(() {
                              _roomError = false;
                              _selectedRoom = room;
                            });
                          },
                        ),
                        const Divider(),
                        TagsCard(
                          tags: _tags,
                          key: ValueKey(_tags),
                          onChange: (tags) {
                            _tags = [...tags];
                          },
                        ),
                        PeopleCard(
                          people: _people,
                          key: ValueKey(_people),
                          onChange: (people) {
                            _people = [...people];
                          },
                        ),
                        LinksCard(
                          links: _links,
                          onChange: (links) {
                            _links = [...links];
                          },
                        ),
                        PhotosCard(
                          photos: _photos,
                          onChange: (photos) {
                            _photos = [...photos];
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
                                    inputFormatters: [
                                      CurrencyTextInputFormatter(locale: 'en', symbol: '', enableNegative: false)
                                    ],
                                    keyboardType: TextInputType.number,
                                    controller: _estimatedCostController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.attach_money),
                                      hintText: 'Estimated cost',
                                      labelText: 'Cost',
                                    ),
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
    return _nameController.text != widget.task.name ||
        _priority != widget.task.priority ||
        _effort != widget.task.effort ||
        // _approximateCostController.text.isNotEmpty ||
        _noteController.text != widget.task.note ||
        _selectedRoom?.id != widget.task.room.id;
    // _tags.isNotEmpty ||
    // _people.isNotEmpty ||
    // _links.isNotEmpty ||
    // _photos.isNotEmpty ||
    // _completeByController.text.isNotEmpty;
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
                    _shouldPop = true;
                  });
                },
                child: const Text('LEAVE')),
          ],
        );
      },
    );
  }

  Future<void> onSubmit() async {
    if (!_formKey.currentState!.validate() || _selectedRoom == null) {
      if (_selectedRoom == null) {
        setState(() {
          _roomError = true;
        });
      }
      showSnackbar('Invalid input.', context);
      return;
    }

    await Future.delayed(const Duration(seconds: 2), () {
      hideKeyboard();
      double? estimatedCost = double.tryParse(_estimatedCostController.text.toString().replaceAll(',', ''));
      var task = TaskService.editTask(
          context, widget.task.id, _nameController.text.toString().trim(), _priority, _effort, 'createdBy', _selectedRoom!,
          photos: _photos,
          people: _people,
          note: _noteController.text.toString().trim(),
          links: _links,
          completeBy: _completeBy,
          estimatedCost: estimatedCost,
          tags: _tags);

      Navigator.of(context).pop(task);
    });
  }
}
