import 'package:flutter/material.dart';
import 'package:much_todo/src/widgets/tags_picker.dart';

import '../domain/tag.dart';
import '../utils/utils.dart';

class TagsCardFilter extends StatefulWidget {
  final List<Tag> tags;
  final ValueChanged<List<Tag>> onChange;

  const TagsCardFilter({super.key, required this.tags, required this.onChange});

  @override
  State<TagsCardFilter> createState() => _TagsCardFilterState();
}

class _TagsCardFilterState extends State<TagsCardFilter> {
  List<Tag> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _selectedTags = [...widget.tags];
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
              subtitle:
                  _selectedTags.isEmpty ? const Text('No tags selected') : const Text('To Dos with any below tags '),
              trailing: IconButton(onPressed: launchAddTag, icon: const Icon(Icons.add)),
            ),
            Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: [
                for (var i = 0; i < _selectedTags.length; i++)
                  Chip(
                    label: Text(_selectedTags[i].name),
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
      MaterialPageRoute(
        builder: (context) => TagsPicker(
          selectedTags: _selectedTags,
          showAdd: false,
        ),
      ),
    );
    hideKeyboard();
    setState(() {
      _selectedTags = [...result.selectedTags];
      widget.onChange(_selectedTags);
    });
  }

  void onDeleteTag(Tag tag) {
    setState(() {
      _selectedTags.removeWhere((element) => element.id == tag.id);
      widget.onChange(_selectedTags);
    });
  }
}
