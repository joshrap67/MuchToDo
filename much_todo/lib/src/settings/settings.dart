import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/user.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/user/user_people.dart';
import 'package:much_todo/src/user/user_tags.dart';
import 'package:provider/provider.dart';
import 'package:much_todo/src/providers/settings_provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsProvider controller;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(user.email),
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: Card(
                    child: ExpansionTile(
                      title: const Text('Danger Zone'),
                      textColor: Theme.of(context).colorScheme.error,
                      iconColor: Theme.of(context).colorScheme.error,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            'DELETE ACCOUNT',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            Card(
              child: ListTile(
                title: Text(user.tags.isNotEmpty ? '${user.tags.length} Tags' : 'No tags'),
                trailing: IconButton(onPressed: launchTags, icon: const Icon(Icons.arrow_forward)),
              ),
            ),
            Card(
              child: ListTile(
                title: Text(user.people.isNotEmpty ? '${user.people.length} People' : 'No people'),
                trailing: IconButton(onPressed: launchPeople, icon: const Icon(Icons.arrow_forward)),
              ),
            ),
            Card(
              child: ListTile(
                title: const Text('Theme'),
                trailing: IconButton(
                  onPressed: () {},
                  icon: DropdownButton<ThemeMode>(
                    value: widget.controller.themeMode,
                    onChanged: widget.controller.updateThemeMode, // rebuilds MaterialApp
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light Theme'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark Theme'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void launchTags() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserTags(),
      ),
    );
  }

  void launchPeople() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserPeople(),
      ),
    );
  }
}
