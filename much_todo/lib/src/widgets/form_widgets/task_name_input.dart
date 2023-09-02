import 'package:flutter/material.dart';
import 'package:much_todo/src/utils/constants.dart';
import 'package:much_todo/src/utils/validation.dart';

class TaskNameInput extends StatefulWidget {
  final String? hint;
  final String? label;
  final ValueChanged<String?> onChange;
  final String? name;
  final FocusNode? nextFocus;

  const TaskNameInput({super.key, this.hint, this.label, required this.onChange, this.name, this.nextFocus});

  @override
  State<TaskNameInput> createState() => _TaskNameInputState();
}

class _TaskNameInputState extends State<TaskNameInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.name ?? '';
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
          prefixIcon: const Icon(Icons.sticky_note_2),
          border: const OutlineInputBorder(),
          hintText: widget.hint,
          labelText: widget.label,
          counterText: ''),
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.name,
      maxLength: Constants.maxNameLength,
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) {
        if (widget.nextFocus != null) {
          FocusScope.of(context).requestFocus(widget.nextFocus!);
        }
      },
      validator: validTaskName,
      onChanged: (name) {
        widget.onChange(name.trim());
      },
    );
  }
}
