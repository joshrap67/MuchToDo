import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:much_todo/src/utils/utils.dart';

class PhotosCard extends StatefulWidget {
  final ValueChanged<List<XFile>> onChange;
  final List<XFile> photos;

  const PhotosCard({super.key, this.photos = const [], required this.onChange});

  @override
  State<PhotosCard> createState() => _PhotosCardState();
}

class LinkWrapper {
  String link;
  TextEditingController controller;

  LinkWrapper(this.link, this.controller);
}

class _PhotosCardState extends State<PhotosCard> {
  final ImagePicker picker = ImagePicker();
  final List<XFile> _mediaFileList = [];

  bool _showAddPhoto = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Theme(
            // removes weird borders that are enabled by default on expansion tile
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: const Text('Photos'),
              textColor: Theme.of(context).colorScheme.primary,
              subtitle: Text('${_mediaFileList.length} photos added'),
              children: [
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 12.0, // gap between adjacent chips
                    runSpacing: 4.0, // gap between lines
                    children: [
                      for (var index = 0; index < _mediaFileList.length; index++)
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 60,
                                height: 60,
                                child: Image.file(
                                  fit: BoxFit.cover,
                                  opacity: const AlwaysStoppedAnimation(.85),
                                  File(_mediaFileList[index].path),
                                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                    return const Center(child: Text('This image type is not supported'));
                                  },
                                ),
                              ),
                              Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  onTap: () => removeLink(index),
                                  child: Container(
                                    decoration: const ShapeDecoration(
                                      color: Color(0xff3f3f3f),
                                      shape: CircleBorder(),
                                    ),
                                    child: const Icon(
                                      Icons.remove_circle_outline,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              ],
              onExpansionChanged: (newVal) {
                setState(() {
                  _showAddPhoto = newVal;
                });
              },
            ),
          ),
          Visibility(
            visible: _showAddPhoto && _mediaFileList.length < 5,
            child: OutlinedButton.icon(
              label: const Text('ADD NEW PHOTO'),
              onPressed: addLink,
              icon: const Icon(Icons.add),
            ),
          )
        ],
      ),
    );
  }

  Future<void> addLink() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _mediaFileList.add(image!);
    });
  }

  void removeLink(int index) {
    setState(() {
      _mediaFileList.removeAt(index);
      widget.onChange(_mediaFileList.map((c) => c).toList());
      hideKeyboard();
    });
  }

  void onChange(String? link) {
    widget.onChange(_mediaFileList.map((c) => c).toList());
  }
}
