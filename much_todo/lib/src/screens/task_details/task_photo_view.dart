import 'dart:io';

import 'package:flutter/material.dart';
import 'package:much_todo/src/screens/task_details/set_task_photos_screen.dart';
import 'package:photo_view/photo_view.dart';

class TaskPhotoView extends StatefulWidget {
  final PhotoWrapper photo;

  const TaskPhotoView({super.key, required this.photo});

  @override
  State<TaskPhotoView> createState() => _TaskPhotoViewState();
}

class _TaskPhotoViewState extends State<TaskPhotoView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton.icon(
            onPressed: deletePhoto,
            icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.onBackground),
            label: Text(
              'DELETE',
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.background),
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: <Widget>[
            if (hasPhoto())
              PhotoView(
                  heroAttributes: PhotoViewHeroAttributes(tag: widget.photo.hashCode),
                  backgroundDecoration: BoxDecoration(color: Theme.of(context).colorScheme.background),
                  imageProvider: widget.photo.isNetwork()
                      ? NetworkImage(widget.photo.taskPhoto!.publicUrl!)
                      : FileImage(File(widget.photo.localPhoto!.path)) as ImageProvider),
            if (!hasPhoto())
              const Center(
                child: Icon(Icons.broken_image),
              ),
          ],
        ),
      ),
    );
  }

  bool hasPhoto() {
    return widget.photo.localPhoto != null ||
        (widget.photo.taskPhoto != null && widget.photo.taskPhoto!.publicUrl != null);
  }

  void deletePhoto() {
    Navigator.pop(context, true);
  }
}
