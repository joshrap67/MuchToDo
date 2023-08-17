import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/widgets/tag_picker.dart';

class TagsCard extends StatefulWidget {
  final List<Tag> tags;
  final ValueChanged<List<Tag>> onChange;

  const TagsCard({super.key, required this.tags, required this.onChange});

  @override
  State<TagsCard> createState() => _TagsCardState();
}

class _TagsCardState extends State<TagsCard> {
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
              title: Text(getTitle()),
			  leading: const Icon(Icons.tag),
              contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
              trailing: IconButton(onPressed: launchAddTag, icon: const Icon(Icons.add)),
            ),
            Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: [
                for (var i = 0; i < _selectedTags.length; i++)
                  // todo allow for custom colors for each tag? problem would be text color
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

  String getTitle() {
    return _selectedTags.isEmpty
        ? 'No tags selected'
        : '${_selectedTags.length} ${_selectedTags.length == 1 ? 'tag' : 'tags'} selected';
  }

  Future<void> launchAddTag() async {
    TagCreated result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TagPicker(selectedTags: _selectedTags)),
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
