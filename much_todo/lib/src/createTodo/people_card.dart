import 'package:flutter/material.dart';
import 'package:much_todo/src/createTodo/people_picker.dart';
import 'package:much_todo/src/domain/professional.dart';

import '../utils/utils.dart';

class PeopleCard extends StatefulWidget {
  final List<Professional> people;

  const PeopleCard({super.key, required this.people});

  @override
  State<PeopleCard> createState() => _PeopleCardState();
}

class _PeopleCardState extends State<PeopleCard> {
  List<Professional> _selectedPeople = [];
  List<Professional> _allPeople = [];

  @override
  void initState() {
    super.initState();
    _selectedPeople = [...widget.people];
    _allPeople = [Professional('Dennis', 'A@a.com', '8658675309')];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('People'),
              contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
              subtitle: _selectedPeople.isEmpty
                  ? const Text('No people selected')
                  : Text('${_selectedPeople.length} ${_selectedPeople.length == 1 ? 'person' : 'people'} selected'),
              trailing: IconButton(onPressed: launchPickPeople, icon: const Icon(Icons.add)),
            ),
            Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: [
                for (var i = 0; i < _selectedPeople.length; i++)
                  Chip(
                    label: Text(_selectedPeople[i].name),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onDeleted: () {
                      onDeletePerson(_selectedPeople[i].name);
                    },
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> launchPickPeople() async {
    PeopleCreated result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PeoplePicker(allPeople: _allPeople, selectedPeople: _selectedPeople)),
    );
    hideKeyboard();
    setState(() {
      _selectedPeople = [...result.selectedPeople];
      _allPeople = [...result.allPeople];
    });
  }

  void onDeletePerson(String personName) {
    _selectedPeople.removeWhere((element) => element.name == personName);
    setState(() {});
  }
}
