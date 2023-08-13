import 'package:flutter/material.dart';
import 'package:much_todo/src/widgets/people_picker.dart';
import 'package:much_todo/src/domain/person.dart';
import 'package:much_todo/src/utils/utils.dart';

class PeopleCardFilter extends StatefulWidget {
  final List<Person> people;
  final ValueChanged<List<Person>> onChange;

  const PeopleCardFilter({super.key, required this.people, required this.onChange});

  @override
  State<PeopleCardFilter> createState() => _PeopleCardFilterState();
}

class _PeopleCardFilterState extends State<PeopleCardFilter> {
  List<Person> _selectedPeople = [];

  @override
  void initState() {
    super.initState();
    _selectedPeople = [...widget.people];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
        child: Column(
          children: [
            ListTile(
              title: Text(getTitle()),
              contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
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

  String getTitle() {
    return _selectedPeople.isEmpty ? 'No people selected' : 'With any below people';
  }

  Future<void> launchPickPeople() async {
    PeoplePicked result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PeoplePicker(
          selectedPeople: _selectedPeople,
          showAdd: false,
        ),
      ),
    );
    hideKeyboard();
    setState(() {
      _selectedPeople = [...result.selectedPeople];
      widget.onChange(_selectedPeople);
    });
  }

  void onDeletePerson(String personName) {
    setState(() {
      _selectedPeople.removeWhere((element) => element.name == personName);
      widget.onChange(_selectedPeople);
    });
  }
}
