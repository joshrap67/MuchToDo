import 'package:flutter/material.dart';
import 'package:much_todo/src/widgets/create_person.dart';
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
  final bool showAdd;

  const PeoplePicker({super.key, required this.selectedPeople, this.showAdd = true});

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
        scrolledUnderElevation: 0,
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
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                child: SearchBar(
                  leading: const Icon(Icons.search),
                  controller: _searchController,
                  hintText: 'Search People',
                  // todo bug with flutter... if you close keyboard while focus is on this you can't open keyboard again
                  onChanged: filterPeople,
                  trailing: _searchController.text.isNotEmpty
                      ? <Widget>[
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              hideKeyboard();
                              setState(() {
                                filterPeople('');
                              });
                            },
                          )
                        ]
                      : null,
                ),
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
                    } else if (widget.showAdd) {
                      // footer
                      return OutlinedButton.icon(
                        label: const Text('DON\'T SEE A PERSON? CREATE ONE'),
                        onPressed: addPerson,
                        icon: const Icon(Icons.add),
                      );
                    }
                    return null;
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
    hideKeyboard();
    setState(() {});
  }
}
