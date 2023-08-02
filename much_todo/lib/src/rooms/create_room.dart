import 'package:flutter/material.dart';
import 'package:much_todo/src/services/rooms_service.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/loading_button.dart';
import 'package:provider/provider.dart';

import '../providers/rooms_provider.dart';

class CreateRoom extends StatefulWidget {
  final String? name;

  const CreateRoom({super.key, this.name});

  @override
  State<CreateRoom> createState() => _CreateRoomState();
}

class _CreateRoomState extends State<CreateRoom> {
  final TextEditingController _nameController = TextEditingController();

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
                      Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Room name'),
                              border: OutlineInputBorder(),
                            ),
                            controller: _nameController,
                            validator: validName,
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LoadingButton(onSubmit: onSubmit),
          )
        ],
      ),
    );
  }

  String? validName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Required';
    }
    if (context.read<RoomsProvider>().rooms.any((r) => r.name == name)) {
      return 'Room name already exists';
    }
    return null;
  }

  Future<void> onSubmit() async {
    if (_formKey.currentState!.validate()) {
      var room = await RoomsService.createRoom(context, _nameController.text);
      hideKeyboard();
      if (context.mounted) {
        Navigator.pop(context, room);
      }
    }
  }
}
