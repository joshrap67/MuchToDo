import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:much_todo/src/utils/utils.dart';

class DatePicker extends StatefulWidget {
  final DateTime? selectedDate;
  final DateTime? firstDate;
  final ValueChanged<DateTime?> onChange;
  final String? hintText;
  final String? labelText;

  const DatePicker(
      {super.key, this.selectedDate, this.firstDate, this.hintText, this.labelText, required this.onChange});

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
            initialDate: DateTime.now(),
            firstDate: widget.firstDate ?? DateTime.now(),
            lastDate: DateTime(9999));
        if (pickDate != null) {
          setState(() {
            widget.onChange(pickDate);
            _controller.text = DateFormat('yyyy-MM-dd').format(pickDate);
          });
        }
        hideKeyboard();
      },
    );
  }
}
