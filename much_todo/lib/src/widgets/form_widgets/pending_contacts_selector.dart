import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/create_contact.dart';
import 'package:provider/provider.dart';

class PendingContactsSelector extends StatefulWidget {
  final List<Contact> contacts;
  final ValueChanged<List<Contact>> onChange;
  final bool showAdd;

  const PendingContactsSelector({super.key, required this.contacts, required this.onChange, this.showAdd = true});

  @override
  State<PendingContactsSelector> createState() => _PendingContactsCard1State();
}

class ContactOption {
  Contact? contact;
  bool hasResults = true;

  ContactOption({this.contact, this.hasResults = true});
}

class _PendingContactsCard1State extends State<PendingContactsSelector> {
  List<Contact> _selectedContacts = [];
  final _autoCompleteController = TextEditingController();
  final _focusNode = FocusNode();
  final _textFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedContacts = [...widget.contacts];
  }

  @override
  void dispose() {
    _autoCompleteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
          child: LayoutBuilder(builder: (context, BoxConstraints constraints) {
            return RawAutocomplete<ContactOption>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                var contacts = context.read<UserProvider>().contacts;
                if (contacts.isEmpty) {
                  // if user has none in the first place give them an option to create one from here
                  return [ContactOption(hasResults: false)];
                }

                // don't show options that are already selected
                if (textEditingValue.text == '') {
                  return contacts
                      .where((element) => !_selectedContacts.any((t) => t.id == element.id))
                      .map((e) => ContactOption(contact: e));
                }

                var filteredContacts = contacts
                    .where((element) => element.name.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                    .where((element) => !_selectedContacts.any((t) => t.id == element.id));
                if (filteredContacts.isNotEmpty) {
                  return filteredContacts.map((e) => ContactOption(contact: e));
                } else {
                  // hack, but I want to show a footer when no results are found to allow user to create items on the fly
                  return [ContactOption(hasResults: false)];
                }
              },
              textEditingController: _autoCompleteController,
              focusNode: _focusNode,
              displayStringForOption: (contactOption) => contactOption.contact!.name,
              fieldViewBuilder: (context, fieldTextEditingController, fieldFocusNode, onFieldSubmitted) {
                return TextFormField(
                  key: _textFieldKey,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                    labelText: "Select Contacts",
                  ),
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                        // bug with flutter, without this there is overflow on right
                        maxHeight: 300,
                      ),
                      child: Scrollbar(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            final ContactOption option = options.elementAt(index);
                            if (option.hasResults) {
                              return ListTile(
                                title: Text(option.contact!.name),
                                onTap: () => onSelected(option),
                              );
                            } else if (widget.showAdd) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: OutlinedButton.icon(
                                  label: const Text('CREATE NEW CONTACT'),
                                  onPressed: addContact,
                                  icon: const Icon(Icons.add),
                                ),
                              );
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              onSelected: selectContact,
            );
          }),
        ),
        if (_selectedContacts.isNotEmpty)
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: Wrap(
                spacing: 8.0, // gap between adjacent chips
                runSpacing: 4.0, // gap between lines
                children: [
                  for (var i = 0; i < _selectedContacts.length; i++)
                    Chip(
                      label: Text(
                        _selectedContacts[i].name,
                        style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.tertiary,
                      deleteIconColor: Theme.of(context).colorScheme.onTertiary,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      onDeleted: () {
                        onDeleteContact(_selectedContacts[i]);
                      },
                    ),
                ],
              ))
      ],
    );
  }

  void selectContact(ContactOption? contactOption) {
    if (contactOption == null || contactOption.contact == null) {
      return;
    }

    var contact = contactOption.contact!;
    _autoCompleteController.clear();
    if (!_selectedContacts.any((element) => element.id == contact.id)) {
      _selectedContacts.add(contact);
    } else {
      _selectedContacts.removeWhere((t) => t.id == contact.id);
    }
    widget.onChange(_selectedContacts);
    hideKeyboard();
    setState(() {});
  }

  Future<void> addContact() async {
    hideKeyboard();
    Contact? createdContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateContact(
          name: _autoCompleteController.text,
        ),
      ),
    );
    if (createdContact != null) {
      setState(() {
        _selectedContacts.add(createdContact);
        widget.onChange(_selectedContacts);
      });
    }
  }

  void onDeleteContact(Contact contact) {
    hideKeyboard();
    setState(() {
      _selectedContacts.removeWhere((element) => element.id == contact.id);
      widget.onChange(_selectedContacts);
    });
  }
}
