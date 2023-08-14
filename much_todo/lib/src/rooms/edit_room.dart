import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/services/rooms_service.dart';
import 'package:much_todo/src/utils/globals.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/loading_button.dart';
import 'package:provider/provider.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';

class EditRoom extends StatefulWidget {
  final Room room;

  const EditRoom({super.key, required this.room});

  @override
  State<EditRoom> createState() => _EditRoomState();
}

class _EditRoomState extends State<EditRoom> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.room.name;
    _noteController.text = widget.room.note ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Room'),
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
                        validator: (val) => validRoomName(val, context.read<RoomsProvider>().rooms),
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
            child: LoadingButton(onSubmit: onSubmit),
          )
        ],
      ),
    );
  }

  Future<void> onSubmit() async {
    if (_formKey.currentState!.validate()) {
      var name = _nameController.text.trim();
      var note = _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null;
      var room = await RoomsService.editRoom(context, widget.room.id, name, note);
      hideKeyboard();
      if (context.mounted) {
        Navigator.pop(context, room);
      }
    }
  }
}
