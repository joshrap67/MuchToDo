import 'package:flutter/material.dart';

class PriorityIndicator extends StatelessWidget {
  final int priority;

  const PriorityIndicator({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    if (priority == 1) {
      return Icon(Icons.looks_one, color: Colors.red[500]);
    } else if (priority == 2) {
      return Icon(Icons.looks_two, color: Colors.red[400]);
    } else if (priority == 3) {
      return Icon(Icons.looks_3, color: Colors.red[300]);
    } else if (priority == 4) {
      return Icon(Icons.looks_4, color: Colors.red[200]);
    } else {
      return Icon(Icons.looks_5, color: Colors.red[100]);
    }
  }
}
