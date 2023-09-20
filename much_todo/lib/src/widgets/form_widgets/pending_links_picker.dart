import 'package:flutter/material.dart';
import 'package:much_todo/src/utils/constants.dart';
import 'package:much_todo/src/utils/utils.dart';

class PendingLinksPicker extends StatefulWidget {
  final List<String> links;
  final ValueChanged<List<String>> onChange;

  const PendingLinksPicker({super.key, this.links = const [], required this.onChange});

  @override
  State<PendingLinksPicker> createState() => _PendingLinksPickerState();
}

class _PendingLinksPickerState extends State<PendingLinksPicker> {
  List<String> _links = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _links = [...widget.links];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          readOnly: true,
          showCursor: false,
          canRequestFocus: false,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.link),
            labelText: 'Add Links',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                hideKeyboard();
                promptAddLink();
              },
            ),
          ),
          onTap: () {
            hideKeyboard();
            promptAddLink();
          },
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 300,
          ),
          child: Scrollbar(
            thumbVisibility: true,
            controller: _scrollController,
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              itemCount: _links.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                final String url = _links.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Chip(
                    label: Text(
                      url,
                      style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                    deleteIconColor: Theme.of(context).colorScheme.onTertiary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onDeleted: () {
                      removeLink(index);
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void promptAddLink() {
    hideKeyboard();
    if (_links.length > Constants.maxRooms) {
      showSnackbar('Cannot have more than ${Constants.maxLinks} links', context);
      return;
    }

    final formKey = GlobalKey<FormState>();
    final linkController = TextEditingController();
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  addLink(linkController.text.trim());
                  Navigator.pop(context);
                }
              },
              child: const Text('ADD'),
            )
          ],
          insetPadding: const EdgeInsets.all(8.0),
          title: const Text('Add Link'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('URL *'),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.url,
                      controller: linkController,
                      validator: (url) {
                        if (url == null || url.isEmpty) {
                          return 'Required';
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
      },
    );
  }

  void addLink(String link) {
    setState(() {
      _links.add(link);
      widget.onChange(_links);
    });
  }

  void removeLink(int index) {
    setState(() {
      _links.removeAt(index);
      widget.onChange(_links);
      hideKeyboard();
    });
  }
}
