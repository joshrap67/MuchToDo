import 'package:flutter/material.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/services/user_service.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

import '../domain/tag.dart';

class TagCreated {
  // emitted to any parent consuming the result of this widget popping
  final List<Tag> selectedTags;

  TagCreated(this.selectedTags);
}

class TagsPicker extends StatefulWidget {
  final List<Tag> selectedTags;

  const TagsPicker({super.key, required this.selectedTags});

  @override
  State<TagsPicker> createState() => _TagsPickerState();
}

class _TagsPickerState extends State<TagsPicker> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newTagController = TextEditingController();

  List<Tag> _displayedTags = [];
  List<Tag> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _selectedTags = [...widget.selectedTags];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _displayedTags = _allTags();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
    _newTagController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Select Tags'),
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
              TextField(
                decoration: const InputDecoration(
                  label: Text('Search Tags'),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                controller: _searchController,
                onChanged: filterTags,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _displayedTags.length + 1,
                  // todo key?
                  itemBuilder: (BuildContext ctx, int index) {
                    if (index < _displayedTags.length) {
                      return CheckboxListTile(
                          value: _selectedTags.contains(_displayedTags[index]),
                          title: Text(_displayedTags[index].name),
                          onChanged: (val) {
                            selectTag(val!, index);
                          });
                    } else {
                      // footer
                      return OutlinedButton.icon(
                        label: const Text('DON\'T SEE A TAG? CREATE ONE'),
                        onPressed: promptAddTag,
                        icon: const Icon(Icons.add),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void filterTags(String text) {
    var lowerCaseSearch = text.toLowerCase();
    setState(() {
      if (lowerCaseSearch.isEmpty) {
        _displayedTags = _allTags();
      } else {
        _displayedTags = _allTags().where((element) => element.name.toLowerCase().contains(lowerCaseSearch)).toList();
      }
    });
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
                  // todo loading indicator
                  if (formKey.currentState!.validate()) {
                    addTag(_newTagController.text);
                    Navigator.pop(context, 'OK');
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
                  validator: validNewTag,
                  controller: _newTagController,
                ),
              ),
            ),
          );
        }).then((value) => _newTagController.clear());
  }

  List<Tag> _allTags() {
    return context.read<UserProvider>().tags;
  }

  String? validNewTag(String? tagName) {
    if (tagName == null || tagName.isEmpty) {
      return 'Name is required.';
    } else if (_allTags().any((x) => x.name == tagName)) {
      return 'Tag already exists';
    } else {
      return null;
    }
  }

  void addTag(String tagName) {
    if (tagName.isEmpty) {
      return;
    }

    var tag = UserService.createTag(context, tagName.trim());

    setState(() {
      _selectedTags.add(tag);
      _displayedTags.add(tag);
      hideKeyboard();
      _searchController.clear();
    });
  }

  void selectTag(bool isSelected, int index) {
    if (isSelected) {
      _selectedTags.add(_displayedTags[index]);
    } else {
      _selectedTags.remove(_displayedTags[index]);
    }
    setState(() {});
  }
}
