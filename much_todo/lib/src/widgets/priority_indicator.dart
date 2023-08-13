import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/task.dart';

class PriorityIndicator extends StatelessWidget {
  final Task task;

  const PriorityIndicator({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    if (task.priority == 1) {
      return Icon(Icons.looks_one, color: Colors.red[500]);
    } else if (task.priority == 2) {
      return Icon(Icons.looks_two, color: Colors.red[400]);
    } else if (task.priority == 3) {
      return Icon(Icons.looks_3, color: Colors.red[300]);
    } else if (task.priority == 4) {
      return Icon(Icons.looks_4, color: Colors.red[200]);
    } else {
      return Icon(Icons.looks_5, color: Colors.red[100]);
    }
  }
}
