import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/widgets/create_contact.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

class ContactsPicked {
  // emitted to any parent consuming the result of this widget popping
  final List<Contact> selectedContacts;

  ContactsPicked(this.selectedContacts);
}

class ContactPicker extends StatefulWidget {
  final List<Contact> selectedContacts;
  final bool showAdd;

  const ContactPicker({super.key, required this.selectedContacts, this.showAdd = true});

  @override
  State<ContactPicker> createState() => _ContactPickerState();
}

class _ContactPickerState extends State<ContactPicker> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newTagController = TextEditingController();

  List<Contact> _selectedContacts = [];

  @override
  void initState() {
    super.initState();
    _selectedContacts = [...widget.selectedContacts];
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _newTagController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var contacts = getContacts();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Select Contacts'),
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, ContactsPicked(_selectedContacts));
            return false;
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                child: SearchBar(
                  leading: const Icon(Icons.search),
                  controller: _searchController,
                  hintText: 'Search Contacts',
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
                  itemCount: contacts.length + 1,
                  // todo key?
                  itemBuilder: (BuildContext ctx, int index) {
                    if (index < contacts.length) {
                      var contact = contacts[index];
                      return CheckboxListTile(
                          value: _selectedContacts.contains(contact),
                          title: Text(contact.name),
                          onChanged: (val) {
                            selectContact(val!, contact);
                          });
                    } else if (widget.showAdd) {
                      // footer
                      return OutlinedButton.icon(
                        label: const Text('DON\'T SEE A CONTACT? CREATE ONE'),
                        onPressed: addContact,
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
    Contact? createdContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateContact(
          name: _searchController.text,
        ),
      ),
    );
    if (createdContact != null) {
      setState(() {
        _selectedContacts.add(createdContact);
      });
    }
  }

  void selectContact(bool isSelected, Contact contact) {
    if (isSelected) {
      _selectedContacts.add(contact);
    } else {
      _selectedContacts.removeWhere((p) => p.id == contact.id);
    }
    hideKeyboard();
    setState(() {});
  }
}
