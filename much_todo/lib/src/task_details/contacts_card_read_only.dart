import 'package:flutter/material.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:much_todo/src/domain/task.dart';

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
              title: Text(contact.email != null ? contact.email! : 'No email'),
              subtitle: const Text(
                'Email',
                style: TextStyle(fontSize: 12),
              ),
              leading: const Icon(Icons.email),
              onTap: () => launchEmail(contact),
            ),
            ListTile(
              title: Text(contact.phoneNumber != null ? contact.phoneNumber! : 'No phone number'),
              subtitle: const Text(
                'Phone Number',
                style: TextStyle(fontSize: 12),
              ),
              leading: const Icon(Icons.phone),
              onTap: () => launchPhone(contact),
            ),
            const Padding(padding: EdgeInsets.all(16))
          ],
        );
      },
    );
  }

  Future<void> launchEmail(TaskContact contact) async {
    if (contact.email == null) {
      showSnackbar('Email is empty.', context);
    }

    final Uri uri = Uri(scheme: 'mailto', path: contact.email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        showSnackbar('Could not launch email.', context);
      }
    }
  }

  Future<void> launchPhone(TaskContact contact) async {
    if (contact.phoneNumber == null) {
      showSnackbar('Phone number is empty.', context);
    }

    final Uri uri = Uri(scheme: 'tel', path: contact.phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        showSnackbar('Could not launch number.', context);
      }
    }
  }
}
