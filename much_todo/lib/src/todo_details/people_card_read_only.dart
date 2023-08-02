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
          ListTile(
            title: const Text('People'),
            contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
            subtitle: widget.people.isEmpty
                ? const Text('No people selected')
                : Text('${widget.people.length} ${widget.people.length == 1 ? 'person' : 'people'}'),
          ),
          Wrap(
            spacing: 8.0, // gap between adjacent chips
            runSpacing: 4.0, // gap between lines
            children: [
              for (var i = 0; i < widget.people.length; i++)
                ActionChip(
                  label: Text(widget.people[i].name),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onPressed: () => showProfessionalInfo(widget.people[i]),
                ),
            ],
          ),
          const Padding(padding: EdgeInsets.all(4.0))
        ],
      ),
    );
  }

  void showProfessionalInfo(TodoPerson professional) {
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
                title: Text(professional.name),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            ListTile(
              title: Text(professional.email != null ? professional.email! : 'No email'),
              subtitle: const Text('Email'),
              leading: const Icon(Icons.email),
              onTap: () => launchEmail(professional),
            ),
            ListTile(
              title: Text(professional.phoneNumber != null ? professional.phoneNumber! : 'No phone number'),
              subtitle: const Text('Phone Number'),
              leading: const Icon(Icons.phone),
              onTap: () => launchPhone(professional),
            ),
            const Padding(padding: EdgeInsets.all(16))
          ],
        );
      },
    );
  }

  Future<void> launchEmail(TodoPerson professional) async {
    if (professional.email == null) {
      showSnackbar('Email is empty.', context);
    }

    final Uri uri = Uri(scheme: 'mailto', path: professional.email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        showSnackbar('Could not launch email.', context);
      }
    }
  }

  Future<void> launchPhone(TodoPerson professional) async {
    if (professional.phoneNumber == null) {
      showSnackbar('Phone number is empty.', context);
    }

    final Uri uri = Uri(scheme: 'tel', path: professional.phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        showSnackbar('Could not launch number.', context);
      }
    }
  }
}
