import 'package:flutter/material.dart';
import 'package:much_todo/src/createTodo/tags_picker.dart';

import '../utils/utils.dart';

class TagsCardReadOnly extends StatelessWidget {
  final List<String> tags;

  const TagsCardReadOnly({super.key, required this.tags});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 8.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('Tags'),
              contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
              subtitle: tags.isEmpty
                  ? const Text('No tags selected')
                  : Text('${tags.length} ${tags.length == 1 ? 'tag' : 'tags'}'),
            ),
            Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: [
                for (var i = 0; i < tags.length; i++)
                  Chip(
                    label: Text(tags[i]),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
