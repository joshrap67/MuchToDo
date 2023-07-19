import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/loading_button.dart';
import 'package:uuid/uuid.dart';

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
    // todo check other room names
    return null;
  }

  Future<void> onSubmit() async {
    if (_formKey.currentState!.validate()) {
      await Future.delayed(const Duration(seconds: 5), () {
        var room = Room(const Uuid().v4(), _nameController.text, []);
        hideKeyboard();
        Navigator.pop(context, room);
      });
    }
  }
}
