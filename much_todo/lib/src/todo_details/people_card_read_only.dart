import 'package:flutter/material.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/todo.dart';

class PeopleCardReadOnly extends StatefulWidget {
  final List<TodoPerson> people;

  const PeopleCardReadOnly({super.key, required this.people});

  @override
  State<PeopleCardReadOnly> createState() => _PeopleCardReadOnlyState();
}

class _PeopleCardReadOnlyState extends State<PeopleCardReadOnly> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            title: Text('People'),
            contentPadding: EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0)
          ),
          Wrap(
            spacing: 8.0, // gap between adjacent chips
            runSpacing: 4.0, // gap between lines
            children: [
              for (var i = 0; i < widget.people.length; i++)
                ActionChip(
                  label: Text(widget.people[i].name),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () {
                    var person = widget.people[i];
                    if (person.email != null || person.phoneNumber != null) {
                      showPersonInfo(widget.people[i]);
                    }
                  },
                ),
            ],
          ),
          const Padding(padding: EdgeInsets.all(4.0))
        ],
      ),
    );
  }

  void showPersonInfo(TodoPerson person) {
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
              title: Text(person.email != null ? person.email! : 'No email'),
              subtitle: const Text('Email'),
              leading: const Icon(Icons.email),
              onTap: () => launchEmail(person),
            ),
            ListTile(
              title: Text(person.phoneNumber != null ? person.phoneNumber! : 'No phone number'),
              subtitle: const Text('Phone Number'),
              leading: const Icon(Icons.phone),
              onTap: () => launchPhone(person),
            ),
            const Padding(padding: EdgeInsets.all(16))
          ],
        );
      },
    );
  }

  Future<void> launchEmail(TodoPerson person) async {
    if (person.email == null) {
      showSnackbar('Email is empty.', context);
    }

    final Uri uri = Uri(scheme: 'mailto', path: person.email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        showSnackbar('Could not launch email.', context);
      }
    }
  }

  Future<void> launchPhone(TodoPerson person) async {
    if (person.phoneNumber == null) {
      showSnackbar('Phone number is empty.', context);
    }

    final Uri uri = Uri(scheme: 'tel', path: person.phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        showSnackbar('Could not launch number.', context);
      }
    }
  }
}
