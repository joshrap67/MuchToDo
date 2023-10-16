import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/utils/utils.dart';

class DatePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final DateTime? firstDate;
  final DateTime? initialDate;
  final ValueChanged<DateTime?> onChange;
  final String? hintText;
  final String? labelText;
  final String? pickerHelpText;
  final bool required;

  const DatePicker(
      {super.key,
      this.selectedDate,
      this.firstDate,
      this.initialDate,
      this.hintText,
      this.labelText,
      this.pickerHelpText,
      this.required = false,
      required this.onChange});

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.selectedDate != null) {
      _controller.text = DateFormat('yyyy-MM-dd').format(widget.selectedDate!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      readOnly: true,
      validator: (date) {
        if (!widget.required) {
          return null;
        }
        if (_controller.text.isEmpty) {
          return 'Required';
        }
        return null;
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.date_range),
        border: const OutlineInputBorder(),
        hintText: widget.hintText,
        labelText: widget.labelText,
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                onPressed: () {
                  setState(() {
                    widget.onChange(null);
                    _controller.clear();
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
            initialDate: widget.initialDate ?? DateTime.now(),
            firstDate: widget.firstDate ?? DateTime.now(),
            helpText: widget.pickerHelpText,
            lastDate: DateTime(9999));
        if (pickDate != null) {
          pickDate = DateTime.utc(pickDate.year, pickDate.month, pickDate.day);
          setState(() {
            widget.onChange(pickDate);
            _controller.text = DateFormat('yyyy-MM-dd').format(pickDate!);
          });
        }
        hideKeyboard();
      },
    );
  }
}
