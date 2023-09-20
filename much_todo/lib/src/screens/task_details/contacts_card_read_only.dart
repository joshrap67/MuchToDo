import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/utils/utils.dart';

class ContactCardReadOnly extends StatefulWidget {
  final List<TaskContact> contacts;

  const ContactCardReadOnly({super.key, required this.contacts});

  @override
  State<ContactCardReadOnly> createState() => _ContactCardReadOnlyState();
}

class _ContactCardReadOnlyState extends State<ContactCardReadOnly> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(title: Text('Contacts'), contentPadding: EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0)),
          Wrap(
            spacing: 8.0, // gap between adjacent chips
            runSpacing: 4.0, // gap between lines
            children: [
              for (var i = 0; i < widget.contacts.length; i++)
                ActionChip(
                  label: Text(
                    widget.contacts[i].name,
                    style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () {
                    showContactInfo(widget.contacts[i]);
                  },
                ),
            ],
          ),
          const Padding(padding: EdgeInsets.all(4.0))
        ],
      ),
    );
  }

  void showContactInfo(TaskContact contact) {
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
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            ListTile(
              title: Text(contact.email != null && contact.email!.isNotEmpty ? contact.email! : 'No email'),
              leading: const Icon(Icons.email),
              onTap: () => launchEmail(context, contact.email),
            ),
            ListTile(
              title: Text(contact.phoneNumber != null && contact.phoneNumber!.isNotEmpty
                  ? contact.phoneNumber!
                  : 'No phone number'),
              leading: const Icon(Icons.phone),
              onTap: () => launchPhone(context, contact.phoneNumber),
            ),
            const Padding(padding: EdgeInsets.all(16))
          ],
        );
      },
    );
  }
}
