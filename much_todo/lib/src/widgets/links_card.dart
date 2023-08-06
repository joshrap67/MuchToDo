import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:much_todo/src/utils/utils.dart';

class LinksCard extends StatefulWidget {
  final ValueChanged<List<String>> onChange;
  final List<String> links;

  const LinksCard({super.key, this.links = const [], required this.onChange});

  @override
  State<LinksCard> createState() => _LinksCardState();
}

class LinkWrapper {
  String link;
  TextEditingController controller;

  LinkWrapper(this.link, this.controller);
}

class _LinksCardState extends State<LinksCard> {
  final List<TextEditingController> _linkControllers = [];
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _showAddUrl = false;

  @override
  void initState() {
    super.initState();
    for (var link in widget.links) {
      var controller = TextEditingController(text: link);
      _linkControllers.add(controller);
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (var controller in _linkControllers) {
      controller.dispose();
    }
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Theme(
            // removes weird borders that are enabled by default on expansion tile
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              textColor: Theme.of(context).colorScheme.primary,
              title: Text(getTitle()),
			  leading: const Icon(Icons.link),
              children: [
                const Divider(),
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: _scrollController,
                    child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _linkControllers.length,
                        shrinkWrap: true,
                        itemBuilder: (ctx, index) {
                          return Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 8.0, 8.0),
                                  child: TextField(
                                    controller: _linkControllers[index],
                                    decoration: const InputDecoration(hintText: 'URL'),
                                    onChanged: onChange,
                                    focusNode: index == _linkControllers.length - 1 ? _focusNode : null,
                                  ),
                                ),
                              ),
                              IconButton(onPressed: () => removeLink(index), icon: const Icon(Icons.delete))
                            ],
                          );
                        }),
                  ),
                ),
              ],
              onExpansionChanged: (newVal) {
                setState(() {
                  _showAddUrl = newVal;
                });
              },
            ),
          ),
          Visibility(
            visible: _showAddUrl,
            child: OutlinedButton.icon(
              label: const Text('ADD NEW LINK'),
              onPressed: addLink,
              icon: const Icon(Icons.add),
            ),
          )
        ],
      ),
    );
  }

  String getTitle(){
	  return _linkControllers.isEmpty
		  ? 'No links added'
		  : '${_linkControllers.length} ${_linkControllers.length == 1 ? 'link' : 'links'} added';
  }

  void addLink() {
    setState(() {
      _linkControllers.add(TextEditingController());
      // todo maybe i shouldn't do this for the user? in most cases i would assume they would just be pasting so grabbing focus might be annoying
      SchedulerBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    });
  }

  void removeLink(int index) {
    setState(() {
      _linkControllers.removeAt(index);
      widget.onChange(_linkControllers.map((c) => c.text).toList());
      hideKeyboard();
    });
  }

  void onChange(String? link) {
    widget.onChange(_linkControllers.map((c) => c.text).toList());
  }
}
