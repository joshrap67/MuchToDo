import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/services/user_service.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

class TagCreated {
  // emitted to any parent consuming the result of this widget popping
  final List<Tag> selectedTags;

  TagCreated(this.selectedTags);
}

class TagPicker extends StatefulWidget {
  final List<Tag> selectedTags;
  final bool showAdd;

  const TagPicker({super.key, required this.selectedTags, this.showAdd = true});

  @override
  State<TagPicker> createState() => _TagPickerState();
}

class _TagPickerState extends State<TagPicker> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newTagController = TextEditingController();

  List<Tag> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _selectedTags = [...widget.selectedTags];
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _newTagController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tags = getTags();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Select Tags'),
        scrolledUnderElevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, TagCreated(_selectedTags));
            return false;
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8.0),
                child: SearchBar(
                  leading: const Icon(Icons.search),
                  controller: _searchController,
                  hintText: 'Search Tags',
                  onChanged: (_) {
                    setState(() {});
                  },
                  trailing: _searchController.text.isNotEmpty
                      ? <Widget>[
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              hideKeyboard();
                              setState(() {});
                            },
                          )
                        ]
                      : null,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tags.length + 1,
                  // todo key?
                  itemBuilder: (BuildContext ctx, int index) {
                    if (index < tags.length) {
                      var tag = tags[index];
                      return CheckboxListTile(
                          value: _selectedTags.contains(tag),
                          title: Text(tag.name),
                          onChanged: (val) {
                            selectTag(val!, tag);
                          });
                    } else if (widget.showAdd) {
                      // footer
                      return OutlinedButton.icon(
                        label: const Text('DON\'T SEE A TAG? CREATE ONE'),
                        onPressed: promptAddTag,
                        icon: const Icon(Icons.add),
                      );
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void promptAddTag() {
    // todo max amount check
    final formKey = GlobalKey<FormState>();
    _newTagController.text = _searchController.text; // shortcut for user if they were searching for one not found
    showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context, 'OK');
                    addTag(_newTagController.text);
                  }
                },
                child: const Text('CREATE'),
              )
            ],
            insetPadding: const EdgeInsets.all(8.0),
            title: const Text('Create Tag'),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextFormField(
                  decoration: const InputDecoration(
                    label: Text('Tag name'),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => validNewTag(val, context.read<UserProvider>().tags),
                  controller: _newTagController,
                ),
              ),
            ),
          );
        }).then((value) => _newTagController.clear());
  }

  List<Tag> getTags() {
    if (_searchController.text.isNotEmpty) {
      var lowerCaseSearch = _searchController.text.toLowerCase();
      return context
          .read<UserProvider>()
          .tags
          .where((element) => element.name.toLowerCase().contains(lowerCaseSearch))
          .toList();
    } else {
      return context.watch<UserProvider>().tags;
    }
  }

  Future<void> addTag(String tagName) async {
    if (tagName.isEmpty) {
      return;
    }

    var tag = await UserService.createTag(context, tagName.trim());

    setState(() {
      _selectedTags.add(tag);
      hideKeyboard();
      _searchController.clear();
    });
  }

  void selectTag(bool isSelected, Tag tag) {
    if (isSelected) {
      _selectedTags.add(tag);
    } else {
      _selectedTags.removeWhere((t) => t.id == tag.id);
    }
    hideKeyboard();
    setState(() {});
  }
}
