import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/todo.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class EffortPicker extends StatefulWidget {
  final int effort;
  final ValueChanged<int> onChange;

  const EffortPicker({super.key, required this.effort, required this.onChange});

  @override
  State<EffortPicker> createState() => _EffortPickerState();
}

class _EffortPickerState extends State<EffortPicker> {
  int _selectedEffort = 1;

  @override
  void initState() {
    super.initState();
    _selectedEffort = widget.effort;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
            child: Text(
              'Effort',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
            child: SfSlider(
              value: _selectedEffort,
              min: Todo.lowEffort,
              max: Todo.highEffort,
              interval: 1,
              showTicks: true,
              showLabels: true,
              activeColor: const Color(0xFF48db63),
              labelFormatterCallback: (dynamic actualValue, String formattedText) {
                if (actualValue == Todo.lowEffort) {
                  return 'Low';
                } else if (actualValue == Todo.mediumEffort) {
                  return 'Medium';
                } else {
                  return 'High';
                }
              },
              onChanged: onChange,
            ),
          )
        ],
      ),
    );
  }

  void onChange(dynamic index) {
    setState(() {
      _selectedEffort = index.round().toInt();
      widget.onChange(_selectedEffort);
    });
  }
}
