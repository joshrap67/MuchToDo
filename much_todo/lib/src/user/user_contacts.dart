import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/services/user_service.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/create_contact.dart';
import 'package:much_todo/src/widgets/edit_contact.dart';
import 'package:provider/provider.dart';

class UserContacts extends StatefulWidget {
  const UserContacts({super.key});

  @override
  State<UserContacts> createState() => _UserContactsState();
}

class _UserContactsState extends State<UserContacts> {
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var contacts = getContacts();
    return IgnorePointer(
      ignoring: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Contacts'),
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
                        hintText: 'Search Contacts',
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
                          itemCount: contacts.length,
                          itemBuilder: (BuildContext ctx, int index) {
                            var contact = contacts[index];
                            return Card(
                              child: ListTile(
                                title: Text(contact.name),
                                onTap: () => showContactInfo(contact),
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: addContact,
          label: const Text('ADD CONTACT'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  List<Contact> getContacts() {
    if (_searchController.text.isNotEmpty) {
      var lowerCaseSearch = _searchController.text.toLowerCase();
      return context
          .read<UserProvider>()
          .contacts
          .where((element) => element.name.toLowerCase().contains(lowerCaseSearch))
          .toList();
    } else {
      return context.watch<UserProvider>().contacts;
    }
  }

  Future<void> addContact() async {
    hideKeyboard();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateContact(
          name: _searchController.text,
        ),
      ),
    );
  }

  void showContactInfo(Contact contact) {
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
                title: Text(contact.name),
                subtitle: Text('Associated with ${contact.tasks.length} ${contact.tasks.length == 1 ? 'Task' : 'Tasks'}'),
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
                editContact(contact);
              },
            ),
            ListTile(
              title: const Text('Delete'),
              leading: const Icon(Icons.delete),
              onTap: () {
                Navigator.pop(context);
                promptDeleteContact(contact);
              },
            ),
            const Padding(padding: EdgeInsets.all(16))
          ],
        );
      },
    );
  }

  void promptDeleteContact(Contact contact) {
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
                  deleteContact(contact);
                },
                child: const Text('DELETE'),
              )
            ],
            title: const Text('Delete Contact'),
            content: const Text(
                'Are you sure you wish to delete this contact? This contact will be removed from ALL tasks that have them!'),
          );
        });
  }

  Future<void> editContact(Contact contact) async {
    hideKeyboard();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditContact(contact: contact),
      ),
    );
  }

  Future<void> deleteContact(Contact contact) async {
    setState(() {
      _isLoading = true;
    });

    await UserService.deleteContact(context, contact);

    if (context.mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
