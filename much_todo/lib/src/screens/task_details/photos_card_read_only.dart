import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/domain/task_photo.dart';
import 'package:much_todo/src/screens/task_details/task_photo_view_read_only.dart';
import 'package:much_todo/src/screens/task_details/set_task_photos_screen.dart';

class PhotosCardReadOnly extends StatefulWidget {
  final String taskId;
  final List<TaskPhoto> photos;
  final ValueChanged<Task?> onSetPhotos;

  const PhotosCardReadOnly({super.key, required this.taskId, required this.onSetPhotos, this.photos = const []});

  @override
  State<PhotosCardReadOnly> createState() => _PhotosCardReadOnlyState();
}

class _PhotosCardReadOnlyState extends State<PhotosCardReadOnly> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: const Text('Photos'),
            contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
            trailing: TextButton(onPressed: setPhotos, child: const Text('SET PHOTOS')),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              direction: Axis.horizontal,
              spacing: 12.0, // gap between adjacent photos
              runSpacing: 4.0, // gap between lines
              children: [
                for (var index = 0; index < widget.photos.length; index++)
                  GestureDetector(
                    onTap: () => openPhoto(context, index),
                    child: SizedBox(
                      width: 60,
                      height: 60,
                      child: Hero(
                        tag: widget.photos[index].hashCode,
                        child: widget.photos[index].publicUrl != null
                            ? Image.network(
                                widget.photos[index].publicUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                  return const Center(child: Icon(Icons.broken_image));
                                },
                              )
                            : const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                if (widget.photos.isEmpty) const Text('No photos')
              ],
            ),
          ),
        ],
      ),
    );
  }

  void openPhoto(BuildContext context, final int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskPhotoViewReadOnly(
          photo: widget.photos[index],
        ),
      ),
    );
  }

  Future<void> setPhotos() async {
    var result = await Navigator.push<Task?>(
      context,
      MaterialPageRoute(
        builder: (context) => SetTaskPhotosScreen(
          taskId: widget.taskId,
          photos: widget.photos,
        ),
      ),
    );

    if (result != null) {
      widget.onSetPhotos(result);
    }
  }
}
