import 'package:flutter/material.dart';
import 'package:much_todo/src/utils/utils.dart';

class TagCreated {
  // emitted to any parent consuming the result of this widget popping
  final List<String> allTags;
  final List<String> selectedTags;

  TagCreated(this.allTags, this.selectedTags);
}

class TagsPicker extends StatefulWidget {
  final List<String> allTags;
  final List<String> selectedTags;

  const TagsPicker({super.key, required this.allTags, required this.selectedTags});

  @override
  State<TagsPicker> createState() => _TagsPickerState();
}

class _TagsPickerState extends State<TagsPicker> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _newTagController = TextEditingController();

  List<String> _displayedTags = [];
  List<String> _allTags = [];
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _displayedTags = [...widget.allTags];
    _allTags = [...widget.allTags];
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
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Select Tags'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context, TagCreated(_allTags, _selectedTags));
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
                          title: Text(_displayedTags[index]),
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
        _displayedTags = _allTags;
      } else {
        _displayedTags = _allTags.where((element) => element.toLowerCase().contains(lowerCaseSearch)).toList();
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
                    addTag(_newTagController.text.trim());
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

  String? validNewTag(String? tagName) {
    if (tagName == null || tagName.isEmpty) {
      return 'Name is required.';
    } else if (_allTags.contains(tagName)) {
      return 'Tag already exists';
    } else {
      return null;
    }
  }

  void addTag(String tag) {
    if (tag.isEmpty) {
      return;
    }

    setState(() {
      _selectedTags.add(tag);
      _allTags.add(tag);
      _displayedTags = _allTags;

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
