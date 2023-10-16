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
          const Card(
            child: ListTile(
              title: Text('Completed Tasks'),
              trailing: Icon(Icons.arrow_forward),
              leading: Icon(Icons.check),
            ),
          ),
          const Card(
            child: ListTile(
              title: Text('Uploaded Photos'),
              leading: Icon(Icons.camera_alt),
            ),
          ),
          Card(
            child: ListTile(
              title: const Text('Theme'),
              leading: const Icon(Icons.brush),
              contentPadding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<ThemeMode>(
                  value: ThemeMode.dark,
                  onChanged: (_) {},
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
          const Divider(),
          const Card(
            child: ListTile(
              title: Text('Help'),
              leading: Icon(Icons.help),
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
