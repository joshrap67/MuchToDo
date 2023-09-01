import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/services/user_service.dart';
import 'package:much_todo/src/utils/dialogs.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/utils/validation.dart';
import 'package:provider/provider.dart';

class UserTags extends StatefulWidget {
  const UserTags({super.key});

  @override
  State<UserTags> createState() => _UserTagsState();
}

class _UserTagsState extends State<UserTags> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _renameTagController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    _renameTagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var tags = getTags();
    return IgnorePointer(
      ignoring: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tags'),
          scrolledUnderElevation: 0.0,
        ),
        body: Stack(
          children: [
            Opacity(
              opacity: _isLoading ? .6 : 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 8.0),
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
                      child: Scrollbar(
                        child: ListView.builder(
                          itemCount: tags.length,
                          itemBuilder: (BuildContext ctx, int index) {
                            var tag = tags[index];
                            return Card(
                              child: ListTile(
                                title: Text(tag.name),
                                onTap: () => showTagInfo(tag),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: _isLoading,
              child: const LinearProgressIndicator(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: addTag,
          label: const Text('ADD TAG'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
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

  void showTagInfo(Tag tag) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
              child: ListTile(
                title: Text(tag.name),
                subtitle: Text('Used with ${tag.tasks.length} ${tag.tasks.length == 1 ? 'Task' : 'Tasks'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            ListTile(
              title: const Text('Rename'),
              leading: const Icon(Icons.drive_file_rename_outline),
              onTap: () {
                Navigator.pop(context);
                renameTagPopup(tag);
              },
            ),
            ListTile(
              title: const Text('Delete'),
              leading: const Icon(Icons.delete),
              onTap: () {
                Navigator.pop(context);
                promptDeleteTag(tag);
              },
            ),
            const Padding(padding: EdgeInsets.all(16))
          ],
        );
      },
    );
  }

  void renameTagPopup(Tag tag) {
    final formKey = GlobalKey<FormState>();
    _renameTagController.text = tag.name;
    showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog.adaptive(
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    renameTag(tag, _renameTagController.text);
                    Navigator.pop(context, 'OK');
                  }
                },
                child: const Text('RENAME'),
              )
            ],
            insetPadding: const EdgeInsets.all(8.0),
            title: const Text('Rename Tag'),
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
                  controller: _renameTagController,
                ),
              ),
            ),
          );
        }).then((value) => _renameTagController.clear());
  }

  void promptDeleteTag(Tag tag) {
    showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog.adaptive(
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  deleteTag(tag);
                },
                child: const Text('DELETE'),
              )
            ],
            title: const Text('Delete Tag'),
            content: const Text(
                'Are you sure you wish to delete this tag?\n\nThis tag will be removed from ALL tasks that have it!'),
          );
        });
  }

  Future<void> deleteTag(Tag tag) async {
    setState(() {
      _isLoading = true;
    });

    await UserService.deleteTag(context, tag);

    if (context.mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> renameTag(Tag tag, String tagName) async {
    if (tagName.isEmpty || tag.name == tagName) {
      return;
    }
    tag.name = tagName.trim();

    setState(() {
      _isLoading = true;
    });

    await UserService.updateTag(context, tag);

    setState(() {
      _isLoading = false;
      hideKeyboard();
      _searchController.clear();
    });
  }

  Future<void> addTag() async {
    hideKeyboard();
    await Dialogs.promptAddTag(context, _searchController.text);

    setState(() {
      _searchController.clear();
    });
  }
}
