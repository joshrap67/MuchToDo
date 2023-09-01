import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MoreScreenSkeleton extends StatelessWidget {
  const MoreScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
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
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                    child: Text(
                      'v1.0.0',
                      textAlign: TextAlign.left,
                    ),
                  )
                ],
              ),
              const ListTile(
                title: Text('Signed in as'),
                subtitle: Text('binary0010productions@gmail.com'),
                trailing: Icon(Icons.more_vert),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Card(
            child: ListTile(
              title: Text('6 Tags'),
              trailing: Icon(Icons.arrow_forward),
              leading: Icon(Icons.tag),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('6 Contacts'),
              trailing: Icon(Icons.arrow_forward),
              leading: Icon(Icons.person),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Theme'),
              leading: const Icon(Icons.brush),
              contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
              trailing: DropdownButtonHideUnderline(
                child: DropdownMenu<ThemeMode>(
                  onSelected: (_) {},
                  inputDecorationTheme: const InputDecorationTheme(
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(
                      value: ThemeMode.system,
                      label: 'System Theme',
                    ),
                    DropdownMenuEntry(
                      value: ThemeMode.light,
                      label: 'Light Theme',
                    ),
                    DropdownMenuEntry(
                      value: ThemeMode.dark,
                      label: 'Dark Theme',
                    )
                  ],
                ),
              ),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Privacy Policy'),
              trailing: Icon(Icons.arrow_forward),
              leading: Icon(Icons.policy_outlined),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Terms and Conditions'),
              trailing: Icon(Icons.arrow_forward),
              leading: Icon(Icons.article),
            ),
          ),
        ],
      ),
    );
  }
}
