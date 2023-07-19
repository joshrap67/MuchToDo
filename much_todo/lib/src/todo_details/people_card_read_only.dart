import 'package:flutter/material.dart';
import 'package:much_todo/src/createTodo/people_picker.dart';
import 'package:much_todo/src/domain/professional.dart';

import '../utils/utils.dart';

class PeopleCardReadOnly extends StatelessWidget {
  final List<Professional> people;

  const PeopleCardReadOnly({super.key, required this.people});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('People'),
            contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
            subtitle: people.isEmpty
                ? const Text('No people selected')
                : Text('${people.length} ${people.length == 1 ? 'person' : 'people'} selected'),
          ),
          Wrap(
            spacing: 8.0, // gap between adjacent chips
            runSpacing: 4.0, // gap between lines
            children: [
              for (var i = 0; i < people.length; i++)
                Chip(
                  label: Text(people[i].name),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
            ],
          )
        ],
      ),
    );
  }
}
