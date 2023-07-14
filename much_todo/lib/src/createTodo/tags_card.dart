import 'package:flutter/material.dart';
import 'package:much_todo/src/createTodo/tags_picker.dart';

import '../utils/utils.dart';

class TagsCard extends StatefulWidget {
  final List<String> tags;

  const TagsCard({super.key, required this.tags});

  @override
  State<TagsCard> createState() => _TagsCardState();
}

class _TagsCardState extends State<TagsCard> {
  List<String> _selectedTags = [];
  List<String> _allTags = [];

  @override
  void initState() {
    super.initState();
    _selectedTags = [...widget.tags];
    _allTags = ['Decoration', 'Electrical', 'Maintenance', 'Outside', 'Plumbing', 'Structural'];
  }

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
              subtitle: _selectedTags.isEmpty
                  ? const Text('No tags selected')
                  : Text('${_selectedTags.length} tags selected'),
              trailing: IconButton(onPressed: launchAddTag, icon: const Icon(Icons.add)),
            ),
            Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: [
                for (var i = 0; i < _selectedTags.length; i++)
                  Chip(
                    label: Text(_selectedTags[i]),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onDeleted: () {
                      onDeleteTag(_selectedTags[i]);
                    },
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> launchAddTag() async {
    TagCreated result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TagsPicker(allTags: _allTags, selectedTags: _selectedTags)),
    );
    hideKeyboard();
    setState(() {
      _selectedTags = [...result.selectedTags];
      _allTags = [...result.allTags];
    });
  }

  void onDeleteTag(String tag) {
    _selectedTags.removeWhere((element) => element == tag);
    setState(() {});
  }
}
