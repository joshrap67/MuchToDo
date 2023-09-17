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
  bool isFooter = false;

  TagOption({this.tag, this.isFooter = false});
}

class _PendingTagsSelectorState extends State<PendingTagsSelector> {
  static const maxOptionsHeight = 300.0;

  final _autoCompleteController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  List<Tag> _selectedTags = [];
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _selectedTags = [...widget.tags];
  }

  @override
  void dispose() {
    _autoCompleteController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _hasFocus = hasFocus;
        });
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 2),
            child: LayoutBuilder(builder: (context, BoxConstraints constraints) {
              return RawAutocomplete<TagOption>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  var tags = getOptions();
                  // don't show options that are already selected
                  if (textEditingValue.text == '') {
                    return tags
                        .where((element) => element.isFooter || !_selectedTags.any((t) => t.id == element.tag?.id));
                  }

                  var filteredTags = tags.where((element) =>
                      element.isFooter ||
                      (element.tag!.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) &&
                          !_selectedTags.any((t) => t.id == element.tag?.id)));
                  return filteredTags;
                },
                textEditingController: _autoCompleteController,
                focusNode: _focusNode,
                fieldViewBuilder: (context, fieldTextEditingController, fieldFocusNode, onFieldSubmitted) {
                  return TextFormField(
                    scrollPadding: const EdgeInsets.only(bottom: maxOptionsHeight + 50),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.tag),
                      labelText: 'Select Tags',
                      suffixIcon: _hasFocus
                          ? IconButton(
                              icon: const Icon(Icons.done),
                              onPressed: () {
                                setState(() {
                                  hideKeyboard();
                                });
                              },
                            )
                          : null,
                    ),
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Align(
                    alignment: Alignment.topLeft,
                    child: Material(
                      elevation: 15,
                      color: getDropdownColor(context),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: constraints.maxWidth,
                          // bug with flutter, without this there is overflow on right
                          maxHeight: maxOptionsHeight,
                        ),
                        child: Scrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.zero,
                            itemCount: options.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              final TagOption option = options.elementAt(index);
                              if (!option.isFooter) {
                                return ListTile(
                                  title: Text(option.tag!.name),
                                  onTap: () => onSelected(option),
                                );
                              } else if (widget.showAdd) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: TextButton.icon(
                                    label: const Text('NEW TAG'),
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
      ),
    );
  }

  List<TagOption> getOptions() {
    // separate method since it appears optionsBuilder uses deferred execution on the iterable defined in it, so can't call toList in it
    List<TagOption> options = [];
    var tags = context.read<UserProvider>().tags;
    options.addAll(tags.map((e) => TagOption(tag: e)));
    options.add(TagOption(isFooter: true));
    return options;
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
    setState(() {});
  }

  Future<void> addTag() async {
    hideKeyboard();

    var tag = await Dialogs.promptAddTag(context, _autoCompleteController.text);
    if (tag != null) {
      setState(() {
        _selectedTags.add(tag);
        // dumb hack, but if user did not have a text when creating the contact, options list isn't rebuild
        _autoCompleteController.text = 'a';
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
