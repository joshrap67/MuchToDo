import 'package:flutter/material.dart';
import 'package:much_todo/src/task_details/photos_gallery.dart';

class PhotosCardReadOnly extends StatelessWidget {
  final List<String> _photos;
  final VoidCallback setPhotos;

  const PhotosCardReadOnly({super.key, required this.setPhotos, List<String> photos = const []}) : _photos = photos;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ElevatedButton(onPressed: setPhotos, child: const Text('Set Photos')),
          Theme(
            // removes weird borders that are enabled by default on expansion tile
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Text('Photos (${_photos.length})'),
              textColor: Theme.of(context).colorScheme.primary,
              children: [
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Wrap(
                    direction: Axis.horizontal,
                    spacing: 12.0, // gap between adjacent photos
                    runSpacing: 4.0, // gap between lines
                    children: [
                      for (var index = 0; index < _photos.length; index++)
                        GestureDetector(
                          onTap: () => open(context, index),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: Hero(
                              tag: _photos[index].hashCode,
                              child: Image.network(
                                _photos[index],
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                  return const Center(child: Icon(Icons.broken_image));
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
          links: _photos,
          initialIndex: index,
        ),
      ),
    );
  }
}
