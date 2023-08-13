import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/person.dart';
import 'package:much_todo/src/widgets/create_person.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

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

  List<Person> _selectedPeople = [];

  @override
  void initState() {
    super.initState();
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
    var people = getPeople();
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
                  onChanged: (_) {
                    setState(() {});
                  },
                  trailing: _searchController.text.isNotEmpty
                      ? <Widget>[
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              hideKeyboard();
                              setState(() {});
                            },
                          )
                        ]
                      : null,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: people.length + 1,
                  // todo key?
                  itemBuilder: (BuildContext ctx, int index) {
                    if (index < people.length) {
                      var person = people[index];
                      return CheckboxListTile(
                          value: _selectedPeople.contains(person),
                          title: Text(person.name),
                          onChanged: (val) {
                            selectPerson(val!, person);
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

  List<Person> getPeople() {
    if (_searchController.text.isNotEmpty) {
      var lowerCaseSearch = _searchController.text.toLowerCase();
      return context
          .read<UserProvider>()
          .people
          .where((element) => element.name.toLowerCase().contains(lowerCaseSearch))
          .toList();
    } else {
      return context.watch<UserProvider>().people;
    }
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
      });
    }
  }

  void selectPerson(bool isSelected, Person person) {
    if (isSelected) {
      _selectedPeople.add(person);
    } else {
      _selectedPeople.removeWhere((p) => p.id == person.id);
    }
    hideKeyboard();
    setState(() {});
  }
}
