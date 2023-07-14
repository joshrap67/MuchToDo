import 'package:flutter/material.dart';

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
              title: const Text('Links'),
              textColor: Theme.of(context).colorScheme.primary,
              subtitle: Text('${_linkControllers.length} Links added'),
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
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: _linkControllers[index],
                              decoration: const InputDecoration(hintText: 'URL'),
                              onChanged: onChange,
                            ),
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

  void addLink() {
    setState(() {
      _linkControllers.add(TextEditingController());
    });
  }

  void onChange(String? link) {
    widget.onChange(_linkControllers.map((c) => c.text).toList());
  }
}
