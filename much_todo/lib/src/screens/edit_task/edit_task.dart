import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/services/task_service.dart';
import 'package:much_todo/src/utils/constants.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/form_widgets/date_picker.dart';
import 'package:much_todo/src/widgets/form_widgets/effort_picker.dart';
import 'package:much_todo/src/widgets/form_widgets/money_input.dart';
import 'package:much_todo/src/widgets/form_widgets/pending_contacts_selector.dart';
import 'package:much_todo/src/widgets/form_widgets/pending_links_picker.dart';
import 'package:much_todo/src/widgets/form_widgets/pending_room_selector.dart';
import 'package:much_todo/src/widgets/form_widgets/pending_tags_selector.dart';
import 'package:much_todo/src/widgets/form_widgets/priority_picker.dart';
import 'package:much_todo/src/widgets/form_widgets/task_name_input.dart';
import 'package:much_todo/src/widgets/form_widgets/task_note_input.dart';
import 'package:much_todo/src/widgets/loading_button.dart';
import 'package:provider/provider.dart';

class EditTask extends StatefulWidget {
  final Task task;

  const EditTask({super.key, required this.task});

  @override
  State<EditTask> createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {
  final _formKey = GlobalKey<FormState>();
  final _roomFocusNode = FocusNode();
  bool _shouldPop = false;
  String? _name;
  Room? _selectedRoom;
  int _priority = Constants.defaultPriority;
  int _effort = Constants.defaultEffort;
  List<Contact> _contacts = [];
  List<String> _links = [];
  DateTime? _completeBy;
  double? _estimatedCost;
  String? _note;
  List<Tag> _tags = [];

  @override
  void initState() {
    super.initState();

    _name = widget.task.name;
    _priority = widget.task.priority;
    _effort = widget.task.effort;
    _links = [...widget.task.links];
    _estimatedCost = widget.task.estimatedCost;
    _note = widget.task.note;
    _completeBy = widget.task.completeBy;
    _selectedRoom = context
        .read<RoomsProvider>()
        .rooms
        .cast<Room?>()
        .firstWhere((element) => element?.id == widget.task.room.id, orElse: () => null);
    _contacts =
        context.read<UserProvider>().contacts.where((x) => widget.task.contacts.any((y) => y.id == x.id)).toList();
    _tags = context.read<UserProvider>().tags.where((x) => widget.task.tags.any((y) => y.id == x.id)).toList();
  }

  @override
  void dispose() {
    _roomFocusNode.dispose();
    super.dispose();
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
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          scrolledUnderElevation: 0,
        ),
        body: GestureDetector(
          onTap: () => hideKeyboard(),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Scrollbar(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                      child: Text(
                        'REQUIRED',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary, fontSize: 18, fontWeight: FontWeight.w400),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TaskNameInput(
                        hintText: 'Name of Task',
                        labelText: 'Task Name *',
                        name: _name,
                        nextFocus: _roomFocusNode,
                        onChange: (name) {
                          setState(() {
                            _name = name;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PendingRoomSelector(
                        selectedRoom: _selectedRoom,
                        key: ValueKey(_selectedRoom),
                        focusNode: _roomFocusNode,
                        onRoomChange: (room) {
                          setState(() {
                            _selectedRoom = room;
                          });
                        },
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                      child: Text(
                        'OPTIONAL',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary, fontSize: 18, fontWeight: FontWeight.w400),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PendingTagsSelector(
                        tags: _tags,
                        key: ValueKey(_tags),
                        onChange: (tags) {
                          _tags = [...tags];
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PendingContactsSelector(
                        contacts: _contacts,
                        key: ValueKey(_contacts),
                        onChange: (contacts) {
                          _contacts = [...contacts];
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: MoneyInput(
                        hintText: 'Estimated cost of task',
                        labelText: 'Estimated Cost',
                        prefixIcon: const Icon(Icons.attach_money),
                        amount: _estimatedCost,
                        onChange: (amount) {
                          setState(() {
                            _estimatedCost = amount;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TaskNoteInput(
                        hint: 'Note',
                        label: 'Note',
                        note: _note,
                        onChange: (note) {
                          setState(() {
                            _note = note;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PendingLinksPicker(
                        links: _links,
                        onChange: (links) {
                          _links = [...links];
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DatePicker(
                        labelText: 'Complete By',
                        hintText: 'Complete By',
                        key: ValueKey(_completeBy),
                        initialDate: _completeBy,
                        selectedDate: _completeBy,
                        onChange: (date) {
                          setState(() {
                            _completeBy = date;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 4),
          child: LoadingButton(
            onSubmit: onSubmit,
            label: 'SAVE TASK',
            icon: const Icon(Icons.save),
          ),
        ),
      ),
    );
  }

  bool isModified() {
    final currentTagsSet = Set.from(widget.task.tags.map((e) => e.id));
    final selectedTagsSet = Set.from(_tags.map((e) => e.id));

    final currentContactsSet = Set.from(widget.task.contacts.map((e) => e.id));
    final selectedContactsSet = Set.from(_contacts.map((e) => e.id));

    final currentLinksSet = Set.from(widget.task.links);
    final selectedLinksSet = Set.from(_links);

    return _name != widget.task.name ||
        _priority != widget.task.priority ||
        _effort != widget.task.effort ||
        _estimatedCost != widget.task.estimatedCost ||
        _note != widget.task.note ||
        selectedTagsSet.difference(currentTagsSet).isNotEmpty ||
        selectedContactsSet.difference(currentContactsSet).isNotEmpty ||
        selectedLinksSet.difference(currentLinksSet).isNotEmpty ||
        _completeBy != widget.task.completeBy ||
        _selectedRoom?.id != widget.task.room.id;
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
    if (!_formKey.currentState!.validate()) {
      showSnackbar('Invalid input', context);
      return;
    }

    hideKeyboard();
    var result = await TaskService.editTask(context, widget.task, _name!, _priority, _effort, _selectedRoom!,
        contacts: _contacts,
        note: _note,
        links: _links,
        completeBy: _completeBy,
        estimatedCost: _estimatedCost,
        tags: _tags);
    if (context.mounted && result.success) {
      Navigator.of(context).pop(result.data!);
    } else if (context.mounted && result.failure) {
      showSnackbar(result.errorMessage!, context);
    }
  }
}
