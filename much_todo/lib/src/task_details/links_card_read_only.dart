import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class LinksCardReadOnly extends StatefulWidget {
  final List<String> links;

  const LinksCardReadOnly({super.key, this.links = const []});

  @override
  State<LinksCardReadOnly> createState() => _LinksCardReadOnlyState();
}

class _LinksCardReadOnlyState extends State<LinksCardReadOnly> {
  List<String> _links = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _links = [...widget.links];
  }

  @override
  void dispose() {
    super.dispose();
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
              title: Text('Links (${_links.length})'),
              textColor: Theme.of(context).colorScheme.primary,
              children: [
                const Divider(),
                Container(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: Scrollbar(
                    thumbVisibility: true,
                    controller: _scrollController,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _links.length,
                      shrinkWrap: true,
                      itemBuilder: (ctx, index) {
                        return Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => promptLaunchLink(_links[index]),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 0.0, 8.0),
                                  child: AutoSizeText(
                                    _links[index],
                                    maxLines: 1,
                                    minFontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => copyLink(_links[index]),
                              icon: const Icon(Icons.copy),
                              tooltip: 'Copy Link',
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> copyLink(String link) async {
    await Clipboard.setData(ClipboardData(text: link));
    if (context.mounted) {
      showSnackbar('Link copied to clipboard.', context);
    }
  }

  Future<void> promptLaunchLink(String link) async {
    showDialog<void>(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            actions: <Widget>[
              TextButton(
                child: const Text('NO'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('YES'),
                onPressed: () {
                  Navigator.pop(context);
                  launchLink(link);
                },
              )
            ],
            insetPadding: const EdgeInsets.all(8.0),
            title: const Text('Launch Link'),
            content: const Text('Launch this link with an external application?'),
          );
        });
  }

  Future<void> launchLink(String link) async {
    var uri = Uri.parse(link);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        showSnackbar('Cannot launch link', context);
      }
    }
  }
}
