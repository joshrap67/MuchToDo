import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/services/rooms_service.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/utils/validation.dart';
import 'package:much_todo/src/widgets/loading_button.dart';
import 'package:provider/provider.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';

class CreateRoom extends StatefulWidget {
  final String? name;

  const CreateRoom({super.key, this.name});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.name != null) {
      _nameController.text = widget.name!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Room'),
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Room name'),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.name,
                        controller: _nameController,
                        validator: validRoomName,
                      ),
                      const Padding(padding: EdgeInsets.all(12)),
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Note'),
                          border: OutlineInputBorder(),
                        ),
                        controller: _noteController,
                        validator: validRoomNote,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LoadingButton(
              onSubmit: onSubmit,
              label: 'CREATE',
              icon: const Icon(Icons.add),
            ),
          )
        ],
      ),
    );
  }

  Future<void> onSubmit() async {
    if (_formKey.currentState!.validate()) {
      hideKeyboard();
      Room? room = await RoomsService.createRoom(context, _nameController.text, note: _noteController.text);
      if (context.mounted && room != null) {
        Navigator.pop(context, room);
      }
    }
  }
}
