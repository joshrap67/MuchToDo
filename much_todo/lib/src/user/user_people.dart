import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/person.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/services/user_service.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/create_person.dart';
import 'package:much_todo/src/widgets/edit_person.dart';
import 'package:provider/provider.dart';

class UserPeople extends StatefulWidget {
  const UserPeople({super.key});

  @override
  State<UserPeople> createState() => _UserPeopleState();
}

class _UserPeopleState extends State<UserPeople> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var people = getPeople();
    return IgnorePointer(
      ignoring: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('People'),
          scrolledUnderElevation: 0.0,
        ),
        body: Stack(
          children: [
            Opacity(
              opacity: _isLoading ? .6 : 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 8.0),
                      child: SearchBar(
                        leading: const Icon(Icons.search),
                        controller: _searchController,
                        hintText: 'Search People',
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
                      child: Scrollbar(
                        child: ListView.builder(
                          itemCount: people.length,
                          itemBuilder: (BuildContext ctx, int index) {
                            var person = people[index];
                            return Card(
                              child: ListTile(
                                title: Text(person.name),
                                onTap: () => showPersonInfo(person),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: _isLoading,
              child: const LinearProgressIndicator(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: addPerson,
          child: const Icon(Icons.add),
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
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePerson(
          name: _searchController.text,
        ),
      ),
    );
  }

  void showPersonInfo(Person person) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: ListTile(
                title: Text(person.name),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            ListTile(
              title: const Text('Edit'),
              leading: const Icon(Icons.edit),
              onTap: () {
                Navigator.pop(context);
                editPerson(person);
              },
            ),
            ListTile(
              title: const Text('Delete'),
              leading: const Icon(Icons.delete),
              onTap: () {
                Navigator.pop(context);
                promptDeletePerson(person);
              },
            ),
            const Padding(padding: EdgeInsets.all(16))
          ],
        );
      },
    );
  }

  void promptDeletePerson(Person person) {
    showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deletePerson(person);
                },
                child: const Text('DELETE'),
              )
            ],
            title: const Text('Delete Person'),
            content: const Text(
                'Are you sure you wish to delete this person? This person will be removed from ALL tasks that have them!'),
          );
        });
  }

  Future<void> editPerson(Person person) async {
    hideKeyboard();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditPerson(person: person),
      ),
    );
  }

  Future<void> deletePerson(Person person) async {
    setState(() {
      _isLoading = true;
    });

    await UserService.deletePerson(context, person);

    if (context.mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
