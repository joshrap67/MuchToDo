import 'package:flutter/material.dart';
import 'package:much_todo/src/createTodo/create_person.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

import '../domain/person.dart';

class PeoplePicked {
  // emitted to any parent consuming the result of this widget popping
  final List<Person> selectedPeople;

  PeoplePicked(this.selectedPeople);
}

class PeoplePicker extends StatefulWidget {
  final List<Person> selectedPeople;

  const PeoplePicker({super.key, required this.selectedPeople});

  @override
  State<PeoplePicker> createState() => _PeoplePickerState();
}

class _PeoplePickerState extends State<PeoplePicker> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newTagController = TextEditingController();

  List<Person> _displayedPeople = [];
  List<Person> _selectedPeople = [];

  @override
  void initState() {
    super.initState();
    _selectedPeople = [...widget.selectedPeople];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _displayedPeople = _allPeople();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _newTagController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Select People'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, PeoplePicked(_selectedPeople));
            return false;
          },
          child: Column(
            children: [
              TextField(
                decoration: const InputDecoration(
                  label: Text('Search People'),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                controller: _searchController,
                onChanged: filterPeople,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _displayedPeople.length + 1,
                  // todo key?
                  itemBuilder: (BuildContext ctx, int index) {
                    if (index < _displayedPeople.length) {
                      return CheckboxListTile(
                          value: _selectedPeople.contains(_displayedPeople[index]),
                          title: Text(_displayedPeople[index].name),
                          onChanged: (val) {
                            selectPerson(val!, index);
                          });
                    } else {
                      // footer
                      return OutlinedButton.icon(
                        label: const Text('DON\'T SEE A PERSON? CREATE ONE'),
                        onPressed: addPerson,
                        icon: const Icon(Icons.add),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Person> _allPeople() {
    return context.read<UserProvider>().people;
  }

  void filterPeople(String text) {
    var lowerCaseSearch = text.toLowerCase();
    setState(() {
      if (lowerCaseSearch.isEmpty) {
        _displayedPeople = _allPeople();
      } else {
        _displayedPeople =
            _allPeople().where((element) => element.name.toLowerCase().contains(lowerCaseSearch)).toList();
      }
    });
  }

  Future<void> addPerson() async {
    hideKeyboard();
    Person? createdPerson = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePerson(
          name: _searchController.text,
        ),
      ),
    );
    if (createdPerson != null) {
      setState(() {
        _selectedPeople.add(createdPerson);
        _displayedPeople.add(createdPerson);
      });
    }
  }

  void selectPerson(bool isSelected, int index) {
    if (isSelected) {
      _selectedPeople.add(_displayedPeople[index]);
    } else {
      _selectedPeople.remove(_displayedPeople[index]);
    }
    setState(() {});
  }
}
