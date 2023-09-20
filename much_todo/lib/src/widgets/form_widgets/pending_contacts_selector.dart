import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/utils/dialogs.dart';
import 'package:much_todo/src/utils/utils.dart';
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
  bool isFooter = false;

  ContactOption({this.contact, this.isFooter = false});
}

class _PendingContactsCard1State extends State<PendingContactsSelector> {
  final _autoCompleteController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  List<Contact> _selectedContacts = [];
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _selectedContacts = [...widget.contacts];
  }

  @override
  void dispose() {
    _autoCompleteController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var maxOptionsHeight = MediaQuery.sizeOf(context).height * .35;
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _hasFocus = hasFocus;
        });
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 2.0),
            child: LayoutBuilder(builder: (context, BoxConstraints constraints) {
              return RawAutocomplete<ContactOption>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  var contacts = getOptions();
                  // don't show options that are already selected
                  if (textEditingValue.text == '') {
                    return contacts.where(
                        (element) => element.isFooter || !_selectedContacts.any((t) => t.id == element.contact?.id));
                  }

                  var filteredContacts = contacts.where((element) =>
                      element.isFooter ||
                      (element.contact!.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) &&
                          !_selectedContacts.any((t) => t.id == element.contact?.id)));
                  return filteredContacts;
                },
                textEditingController: _autoCompleteController,
                focusNode: _focusNode,
                fieldViewBuilder: (context, fieldTextEditingController, fieldFocusNode, onFieldSubmitted) {
                  return TextFormField(
                    scrollPadding: EdgeInsets.only(bottom: maxOptionsHeight + 50),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.person),
                      labelText: 'Select Contacts',
                      suffixIcon: _hasFocus
                          ? IconButton(
                              icon: const Icon(Icons.done),
                              onPressed: () {
                                setState(() {
                                  hideKeyboard();
                                });
                              },
                            )
                          : null,
                    ),
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 15,
                      color: getDropdownColor(context),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          // bug with flutter, without this there is overflow on right
                          maxWidth: constraints.maxWidth,
                          maxHeight: maxOptionsHeight,
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          controller: _scrollController,
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              final ContactOption option = options.elementAt(index);
                              if (!option.isFooter) {
                                return ListTile(
                                  title: Text(option.contact!.name),
                                  onTap: () => onSelected(option),
                                );
                              } else if (widget.showAdd) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: TextButton.icon(
                                    label: const Text('NEW CONTACT'),
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
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    deleteIconColor: Theme.of(context).colorScheme.onTertiary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onDeleted: () {
                      onDeleteContact(_selectedContacts[i]);
                    },
                  ),
              ],
            )
        ],
      ),
    );
  }

  List<ContactOption> getOptions() {
    // separate method since it appears optionsBuilder uses deferred execution on the iterable defined in it, so can't call toList in it
    List<ContactOption> options = [];
    var contacts = context.read<UserProvider>().contacts;
    options.addAll(contacts.map((e) => ContactOption(contact: e)));
    options.add(ContactOption(isFooter: true));
    return options;
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
    setState(() {});
  }

  Future<void> addContact() async {
    hideKeyboard();
    Contact? createdContact = await Dialogs.promptAddContact(context, _autoCompleteController.text);
    if (createdContact != null) {
      // dumb hack, but if user did not have a text when creating the contact, options list isn't rebuild
      _autoCompleteController.text = 'a';
      _autoCompleteController.clear();

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
