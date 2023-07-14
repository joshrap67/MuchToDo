import 'package:flutter/material.dart';

class EffortPicker extends StatefulWidget {
  final int effort;
  final ValueChanged<int> onChange;

  const EffortPicker({super.key, required this.effort, required this.onChange});

  @override
  State<EffortPicker> createState() => _EffortPickerState();
}

class _EffortPickerState extends State<EffortPicker> {
  int _selectedEffort = 3;

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
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Effort',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
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
                            color: _selectedEffort == index ? const Color(0xFF48db63) : const Color(0xFF154f12),
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
                                  style: index == _selectedEffort
                                      ? const TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Colors.black,
                                          decorationColor: Colors.black,
                                        )
                                      : const TextStyle(color: Colors.white),
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
      _selectedEffort = index;
      widget.onChange(index);
    });
  }
}
