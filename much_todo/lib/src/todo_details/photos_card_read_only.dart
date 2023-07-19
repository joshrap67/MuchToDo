import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:much_todo/src/todo_details/photos_gallery.dart';
import 'package:much_todo/src/utils/utils.dart';

class PhotosCardReadOnly extends StatelessWidget {
  final List<String> photos;

  const PhotosCardReadOnly({super.key, this.photos = const []});

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
              subtitle: Text('${photos.length} photos added'),
              children: [
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 12.0, // gap between adjacent chips
                    runSpacing: 4.0, // gap between lines
                    children: [
                      for (var index = 0; index < photos.length; index++)
                        GestureDetector(
                          onTap: () => open(context, index),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: Hero(
                              tag: index.toString(),
                              child: Image.network(
                                photos[index],
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                  return const Center(child: Text('This image type is not supported'));
                                },
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void open(BuildContext context, final int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhotosGallery(
          links: photos,
          initialIndex: index,
        ),
      ),
    );
  }
}
