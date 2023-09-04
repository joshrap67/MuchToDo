import 'package:flutter/material.dart';
import 'package:much_todo/src/utils/constants.dart';
import 'package:much_todo/src/utils/validation.dart';

class TaskNoteInput extends StatefulWidget {
  final String? hint;
  final String? label;
  final ValueChanged<String?> onChange;
  final String? note;

  const TaskNoteInput({super.key, this.hint, this.label, required this.onChange, this.note});

  @override
  State<TaskNoteInput> createState() => _TaskNoteInputState();
}

class _TaskNoteInputState extends State<TaskNoteInput> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.note ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
          prefixIcon: const Icon(Icons.note_alt),
          border: const OutlineInputBorder(),
          hintText: widget.hint,
          labelText: widget.label,
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _controller.clear();
                      widget.onChange(null);
                    });
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          counterText: ''),
      maxLines: null,
      keyboardType: TextInputType.multiline,
      controller: _controller,
      maxLength: Constants.maxTaskNameLength,
      validator: validTaskNote,
      onChanged: (note) {
        widget.onChange(note.trim());
      },
    );
  }
}
