import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/user.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/user/user_people.dart';
import 'package:much_todo/src/user/user_tags.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:much_todo/src/providers/settings_provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.controller});

  static const routeName = '/settings';

  final SettingsProvider controller;

  @override
  State<Settings> createState() => _SettingsState();
}

enum AccountOptions { logout, delete }

class _SettingsState extends State<Settings> {
  String? _version;

  @override
  void initState() {
    super.initState();
    setPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    return SingleChildScrollView(
      child: Column(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Much To Do', style: Theme.of(context).textTheme.displayMedium),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                    child: Text(
                      _version ?? '',
                      textAlign: TextAlign.left,
                    ),
                  )
                ],
              ),
              ListTile(
                title: Text('Logged in as'),
                subtitle: Text(user.email),
                trailing: accountDropdown(),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Card(
            child: ListTile(
              title: Text(user.tags.isNotEmpty ? '${user.tags.length} Tags' : 'No tags'),
              onTap: launchTags,
              trailing: const Icon(Icons.arrow_forward),
              leading: const Icon(Icons.tag),
            ),
          ),
          Card(
            child: ListTile(
              title: Text(user.people.isNotEmpty ? '${user.people.length} People' : 'No people'),
              onTap: launchPeople,
              trailing: const Icon(Icons.arrow_forward),
              leading: const Icon(Icons.person),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Theme'),
              leading: const Icon(Icons.brush),
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
          Card(
            child: ListTile(
              title: const Text('Privacy Policy'),
              onTap: launchPrivacyPolicy,
              trailing: const Icon(Icons.arrow_forward),
              leading: const Icon(Icons.policy_outlined),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Terms and Conditions'),
              onTap: launchTermsAndConditions,
              trailing: const Icon(Icons.arrow_forward),
              leading: const Icon(Icons.article),
            ),
          ),
          // todo "help" card?
        ],
      ),
    );
  }

  Widget accountDropdown() {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Sort Media',
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      itemBuilder: (context) {
        return <PopupMenuEntry<AccountOptions>>[
          const PopupMenuItem<AccountOptions>(
            value: AccountOptions.logout,
            child: Text('Logout'),
          ),
          PopupMenuItem<AccountOptions>(
            value: AccountOptions.delete,
            child: Text(
              'Delete Account',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ];
      },
      onSelected: (AccountOptions result) => onSortSelected(result),
    );
  }

  void onSortSelected(AccountOptions result) {
    // todo log out or prompt delete
    setState(() {});
  }

  Future<void> setPackageInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
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

  void launchPrivacyPolicy() {}

  void launchTermsAndConditions() {}
}
