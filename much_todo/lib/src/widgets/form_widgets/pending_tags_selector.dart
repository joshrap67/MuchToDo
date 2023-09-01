import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/utils/dialogs.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';

class PendingTagsSelector extends StatefulWidget {
  final List<Tag> tags;
  final ValueChanged<List<Tag>> onChange;
  final bool showAdd;

  const PendingTagsSelector({super.key, required this.tags, required this.onChange, this.showAdd = true});

  @override
  State<PendingTagsSelector> createState() => _PendingTagsSelectorState();
}

class TagOption {
  Tag? tag;
  bool hasResults = true;

  TagOption({this.tag, this.hasResults = true});
}

class _PendingTagsSelectorState extends State<PendingTagsSelector> {
  List<Tag> _selectedTags = [];
  final _autoCompleteController = TextEditingController();
  final _focusNode = FocusNode();
  final _textFieldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedTags = [...widget.tags];
  }

  @override
  void dispose() {
    _autoCompleteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8,8,8,2),
          child: LayoutBuilder(builder: (context, BoxConstraints constraints) {
            return RawAutocomplete<TagOption>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                var tags = context.read<UserProvider>().tags;
                if (tags.isEmpty) {
                  // if user has none in the first place give them an option to create one from here
                  return [TagOption(hasResults: false)];
                }

                // don't show options that are already selected
                if (textEditingValue.text == '') {
                  return tags
                      .where((element) => !_selectedTags.any((t) => t.id == element.id))
                      .map((e) => TagOption(tag: e));
                }

                var filteredTags = tags
                    .where((element) => element.name.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                    .where((element) => !_selectedTags.any((t) => t.id == element.id));
                if (filteredTags.isNotEmpty) {
                  return filteredTags.map((e) => TagOption(tag: e));
                } else {
                  // hack, but I want to show a footer when no results are found to allow user to create items on the fly
                  return [TagOption(hasResults: false)];
                }
              },
              textEditingController: _autoCompleteController,
              focusNode: _focusNode,
              displayStringForOption: (tagOption) => tagOption.tag!.name,
              fieldViewBuilder: (context, fieldTextEditingController, fieldFocusNode, onFieldSubmitted) {
                return TextFormField(
                  key: _textFieldKey,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag),
                    labelText: "Select Tags",
                  ),
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                );
              },
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                        // bug with flutter, without this there is overflow on right
                        maxHeight: 300,
                      ),
                      child: Scrollbar(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: options.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            final TagOption option = options.elementAt(index);
                            if (option.hasResults) {
                              return ListTile(
                                title: Text(option.tag!.name),
                                onTap: () => onSelected(option),
                              );
                            } else if (widget.showAdd) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: OutlinedButton.icon(
                                  label: const Text('CREATE NEW TAG'),
                                  onPressed: addTag,
                                  icon: const Icon(Icons.add),
                                ),
                              );
                            } else {
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              onSelected: selectTag,
            );
          }),
        ),
        if (_selectedTags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
            child: Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: [
                for (var i = 0; i < _selectedTags.length; i++)
                  Chip(
                    label: Text(
                      _selectedTags[i].name,
                      style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    deleteIconColor: Theme.of(context).colorScheme.onTertiary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onDeleted: () {
                      onDeleteTag(_selectedTags[i]);
                    },
                  ),
              ],
            ),
          )
      ],
    );
  }

  void selectTag(TagOption? tagOption) {
    if (tagOption == null || tagOption.tag == null) {
      return;
    }

    var tag = tagOption.tag!;
    _autoCompleteController.clear();
    if (!_selectedTags.any((element) => element.id == tag.id)) {
      _selectedTags.add(tag);
    } else {
      _selectedTags.removeWhere((t) => t.id == tag.id);
    }
    widget.onChange(_selectedTags);
    hideKeyboard();
    setState(() {});
  }

  Future<void> addTag() async {
    hideKeyboard();

    var tag = await Dialogs.promptAddTag(context, _autoCompleteController.text);
    if (tag != null) {
      setState(() {
        _selectedTags.add(tag);
        _autoCompleteController.clear();
      });
    }
  }

  void onDeleteTag(Tag tag) {
    hideKeyboard();
    setState(() {
      _selectedTags.removeWhere((element) => element.id == tag.id);
      widget.onChange(_selectedTags);
    });
  }
}
