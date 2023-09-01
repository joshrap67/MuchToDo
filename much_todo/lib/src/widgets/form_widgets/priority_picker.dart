import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class PriorityPicker extends StatefulWidget {
  final int priority;
  final ValueChanged<int> onChange;

  const PriorityPicker({super.key, required this.priority, required this.onChange});

  @override
  State<PriorityPicker> createState() => _PriorityPickerState();
}

class _PriorityPickerState extends State<PriorityPicker> {
  int _selectedPriority = 3;

  @override
  void initState() {
    super.initState();
    _selectedPriority = (widget.priority - 6).abs(); // need to invert the direction of the slider
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0),
          child: Text(
            'Priority',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
          child: SfSlider(
            value: _selectedPriority,
            min: 1.0,
            interval: 1,
            max: 5.0,
            showTicks: true,
            showLabels: true,
            activeColor: const Color(0xFFf51818),
            inactiveColor: const Color(0xffd3b9b9),
            onChanged: onChange,
            labelFormatterCallback: (dynamic actualValue, String formattedText) {
              return '${(6 - actualValue).toInt()}';
            },
          ),
        )
      ],
    );
  }

  void onChange(dynamic index) {
    setState(() {
      _selectedPriority = index.round().toInt();

      // need to emit priority back in correct direction (1 being most important)
      widget.onChange(6 - _selectedPriority);
    });
  }
}
