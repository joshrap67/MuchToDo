import 'package:flutter/material.dart';

class TagsCardCompletedTask extends StatelessWidget {
  final List<String> tags;

  const TagsCardCompletedTask({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
        child: Column(
          children: [
            const ListTile(
              title: Text('Tags'),
              contentPadding: EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
            ),
            Wrap(
              spacing: 4.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: [
                for (var i = 0; i < tags.length; i++)
                  Chip(
                    label: Text(
                      tags[i],
                      style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
