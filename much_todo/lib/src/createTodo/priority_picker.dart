import 'package:flutter/material.dart';

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
    _selectedPriority = widget.priority;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Priority',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
			// Slider(
          // 	value: _currentSliderValue,
          // 	max: 4,
          // 	divisions: 4,
          // 	min: 0,
          // 	label: (_currentSliderValue.round() + 1).toString(),
          // 	onChanged: (double value) {
          // 		setState(() {
          // 			_currentSliderValue = value;
          // 		});
          // 	},
          // ),
          SizedBox(
            height: 45,
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var index = 1; index < 6; index++)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                        child: ClipOval(
                          child: Material(
                            color: _selectedPriority == index ? const Color(0xFFf51818) : const Color(0xFFab5959),
                            child: InkWell(
                              onTap: () {
                                onItemTapped(index);
                              },
                              child: SizedBox(
                                width: 45,
                                height: 45,
                                child: Center(
                                    child: Text(
                                  '$index',
                                  style: index == _selectedPriority
                                      ? const TextStyle(
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.white,
                                          color: Colors.white)
                                      : null,
                                )),
                              ),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Lowest'),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Highest'),
              ),
            ],
          )
        ],
      ),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      _selectedPriority = index;
      widget.onChange(index);
    });
  }
}
