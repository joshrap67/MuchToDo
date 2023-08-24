import 'package:flutter/material.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/services/user_service.dart';
import 'package:much_todo/src/sign_in/sign_in_screen.dart';
import 'package:much_todo/src/skeletons/more_screen_skeleton.dart';
import 'package:much_todo/src/user/user_contacts.dart';
import 'package:much_todo/src/user/user_tags.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:much_todo/src/providers/settings_provider.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key, required this.controller});

  final SettingsProvider controller;

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

enum AccountOptions { logout, delete }

class _MoreScreenState extends State<MoreScreen> {
  String? _version;

  @override
  void initState() {
    super.initState();
    setPackageInfo();
  }

  @override
  Widget build(BuildContext context) {
    var user = context.watch<UserProvider>().user;
    if (user == null || context.watch<UserProvider>().isLoading) {
      return const MoreScreenSkeleton();
    }
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
                title: const Text('Signed in as'),
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
              title: Text(user.contacts.isNotEmpty ? '${user.contacts.length} Contacts' : 'No contacts'),
              onTap: launchContacts,
              trailing: const Icon(Icons.arrow_forward),
              leading: const Icon(Icons.person),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Theme'),
              leading: const Icon(Icons.brush),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<ThemeMode>(
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
      tooltip: 'Account Options',
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      itemBuilder: (context) {
        return <PopupMenuEntry<AccountOptions>>[
          const PopupMenuItem<AccountOptions>(
            value: AccountOptions.logout,
            child: Text('Sign-out'),
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
      onSelected: (AccountOptions result) => onAccountOptionSelected(result),
    );
  }

  void onAccountOptionSelected(AccountOptions result) {
    // todo log out or prompt delete
    switch (result) {
      case AccountOptions.logout:
        signOut();
        break;
      case AccountOptions.delete:
        promptDeleteAccount();
        break;
    }
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

  void launchContacts() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UserContacts(),
      ),
    );
  }

  void launchPrivacyPolicy() {}

  void launchTermsAndConditions() {}

  Future<void> signOut() async {
    await UserService.signOut(context);
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, SignInScreen.routeName, (route) => false);
    }
  }

  void promptDeleteAccount() {}
}
