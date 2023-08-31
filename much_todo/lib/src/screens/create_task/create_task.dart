import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/screens/create_task/room_card_multiple.dart';
import 'package:much_todo/src/widgets/effort_picker.dart';
import 'package:much_todo/src/widgets/pending_contacts_card.dart';
import 'package:much_todo/src/widgets/priority_picker.dart';
import 'package:much_todo/src/widgets/pending_tags_card.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/services/task_service.dart';
import 'package:much_todo/src/utils/globals.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/loading_button.dart';
import 'package:much_todo/src/widgets/pending_links_card.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CreateTask extends StatefulWidget {
  final Room? room;
  final Task? task;

  const CreateTask({super.key, this.room, this.task});

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  static const int defaultPriority = 3;
  static const int defaultEffort = 2;

  bool _shouldPop = false;
  bool _roomError = false;

  int _priority = defaultPriority;
  int _effort = defaultEffort;
  List<String> _links = [];
  List<Room> _selectedRooms = [];
  DateTime? _completeBy;
  List<Contact> _contacts = [];
  List<Tag> _tags = [];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _completeByController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _estimatedCostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      _selectedRooms.add(widget.room!);
    }
    if (widget.task != null) {
      _nameController.text = widget.task!.name;
      _priority = widget.task!.priority;
      _effort = widget.task!.effort;
      _links = [...widget.task!.links];

      CurrencyTextInputFormatter formatter = CurrencyTextInputFormatter(symbol: '');
      _estimatedCostController.text =
          widget.task!.estimatedCost != null ? formatter.format(widget.task!.estimatedCost!.toStringAsFixed(2)) : '';

      _noteController.text = widget.task!.note ?? '';
      _completeBy = widget.task!.completeBy;
      if (_completeBy != null) {
        _completeByController.text = DateFormat('yyyy-MM-dd').format(_completeBy!);
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _contacts =
            context.read<UserProvider>().contacts.where((x) => widget.task!.contacts.any((y) => y.id == x.id)).toList();
        _tags = context.read<UserProvider>().tags.where((x) => widget.task!.tags.any((y) => y.id == x.id)).toList();
        setState(() {});
      });
    }
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
          title: const Text('Create Task'),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                        RoomCardMultiple(
                          selectedRooms: _selectedRooms,
                          showError: _roomError,
                          onRoomsChange: (room) {
                            setState(() {
                              _roomError = false;
                              _selectedRooms = room;
                            });
                          },
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
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                          child: Text(
                            'Optional Fields',
                            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 20),
                          ),
                        ),
                        PendingTagsCard(
                          tags: _tags,
                          key: ValueKey(_tags),
                          onChange: (tags) {
                            _tags = [...tags];
                          },
                        ),
                        PendingContactsCard(
                            contacts: _contacts,
                            key: ValueKey(_contacts),
                            onChange: (contacts) {
                              _contacts = [...contacts];
                            }),
                        PendingLinksCard(
                          links: _links,
                          onChange: (links) {
                            _links = [...links];
                          },
                        ),
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
        roomChanged() ||
        _tags.isNotEmpty ||
        _contacts.isNotEmpty ||
        _links.isNotEmpty ||
        _completeByController.text.isNotEmpty;
  }

  bool roomChanged() {
    if (widget.room != null) {
      return _selectedRooms.isEmpty || _selectedRooms.any((element) => element.id != widget.room!.id);
    } else {
      return _selectedRooms.isNotEmpty;
    }
  }

  String? validName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Required';
    }
    return null;
  }

  void promptUnsavedChanges() {
    hideKeyboard();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog.adaptive(
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
    if (!_formKey.currentState!.validate() || _selectedRooms.isEmpty) {
      if (_selectedRooms.isEmpty) {
        setState(() {
          _roomError = true;
        });
      }
      showSnackbar('Invalid input.', context);
      return;
    }

    hideKeyboard();
    double? estimatedCost = double.tryParse(_estimatedCostController.text.toString().replaceAll(',', ''));
    var createdTasks = await TaskService.createTasks(
        context, _nameController.text.toString().trim(), _priority, _effort, _selectedRooms,
        contacts: _contacts,
        note: _noteController.text.toString().trim(),
        links: _links,
        completeBy: _completeBy,
        estimatedCost: estimatedCost,
        tags: _tags);
    if (context.mounted && createdTasks != null) {
      Navigator.of(context).pop(createdTasks);
    }
  }
}
