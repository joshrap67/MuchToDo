import 'package:flutter/material.dart';
import 'package:much_todo/src/widgets/contact_picker.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/utils/utils.dart';

class ContactCardFilter extends StatefulWidget {
  final List<Contact> contacts;
  final ValueChanged<List<Contact>> onChange;

  const ContactCardFilter({super.key, required this.contacts, required this.onChange});

  @override
  State<ContactCardFilter> createState() => _ContactCardFilterState();
}

class _ContactCardFilterState extends State<ContactCardFilter> {
  List<Contact> _selectedContacts = [];

  @override
  void initState() {
    super.initState();
    _selectedContacts = [...widget.contacts];
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
              trailing: IconButton(onPressed: launchPickContact, icon: const Icon(Icons.add)),
            ),
            Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: [
                for (var i = 0; i < _selectedContacts.length; i++)
                  Chip(
                    label: Text(
                      _selectedContacts[i].name,
                      style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    deleteIconColor: Theme.of(context).colorScheme.onTertiary,
                    onDeleted: () {
                      onDeleteContact(_selectedContacts[i].id);
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
    return _selectedContacts.isEmpty ? 'No contacts selected' : 'With any below contact';
  }

  Future<void> launchPickContact() async {
    ContactsPicked result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPicker(
          selectedContacts: _selectedContacts,
          showAdd: false,
        ),
      ),
    );
    hideKeyboard();
    setState(() {
      _selectedContacts = [...result.selectedContacts];
      widget.onChange(_selectedContacts);
    });
  }

  void onDeleteContact(String id) {
    setState(() {
      _selectedContacts.removeWhere((element) => element.id == id);
      widget.onChange(_selectedContacts);
    });
  }
}
