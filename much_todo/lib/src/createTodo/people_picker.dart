import 'package:flutter/material.dart';
import 'package:much_todo/src/createTodo/create_person.dart';
import 'package:much_todo/src/domain/professional.dart';
import 'package:much_todo/src/utils/utils.dart';

class PeopleCreated {
  // emitted to any parent consuming the result of this widget popping
  final List<Professional> allPeople;
  final List<Professional> selectedPeople;

  PeopleCreated(this.allPeople, this.selectedPeople);
}

class PeoplePicker extends StatefulWidget {
  final List<Professional> allPeople;
  final List<Professional> selectedPeople;

  const PeoplePicker({super.key, required this.allPeople, required this.selectedPeople});

  @override
  State<PeoplePicker> createState() => _PeoplePickerState();
}

class _PeoplePickerState extends State<PeoplePicker> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newTagController = TextEditingController();

  List<Professional> _displayedPeople = [];
  List<Professional> _allPeople = [];
  List<Professional> _selectedPeople = [];

  @override
  void initState() {
    super.initState();
    _displayedPeople = [...widget.allPeople];
    _allPeople = [...widget.allPeople];
    _selectedPeople = [...widget.selectedPeople];
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
            Navigator.pop(context, PeopleCreated(_allPeople, _selectedPeople));
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

  void filterPeople(String text) {
    var lowerCaseSearch = text.toLowerCase();
    setState(() {
      if (lowerCaseSearch.isEmpty) {
        _displayedPeople = _allPeople;
      } else {
        _displayedPeople = _allPeople.where((element) => element.name.toLowerCase().contains(lowerCaseSearch)).toList();
      }
    });
  }

  Future<void> addPerson() async {
    hideKeyboard();
    Professional? createdPerson = await Navigator.push(
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
        _allPeople.add(createdPerson);
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
