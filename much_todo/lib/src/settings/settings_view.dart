import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/user.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:provider/provider.dart';

import 'settings_controller.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsController controller;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
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
                title: Text(user.tags.isNotEmpty ? '${user.tags.length} Tags' : ''),
                subtitle: const Text(
                  'Tags',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward)),
              ),
            ),
            Card(
              child: ListTile(
                title: Text(user.people.isNotEmpty ? '${user.people.length} People' : ''),
                subtitle: const Text(
                  'People',
                  style: TextStyle(fontSize: 12),
                ),
                trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.arrow_forward)),
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
}
