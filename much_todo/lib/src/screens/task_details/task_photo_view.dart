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
      appBar: AppBar(),
      body: Container(
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.background),
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          children: <Widget>[
            PhotoView(
                heroAttributes: PhotoViewHeroAttributes(tag: widget.photo.hashCode),
                backgroundDecoration: BoxDecoration(color: Theme.of(context).colorScheme.background),
                imageProvider: widget.photo.isNetwork()
                    ? NetworkImage(widget.photo.networkUrl!)
                    : FileImage(File(widget.photo.localPhoto!.path)) as ImageProvider),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.all(20.0),
                child: ElevatedButton.icon(
                  onPressed: deletePhoto,
                  icon: const Icon(Icons.delete),
                  label: const Text('DELETE PHOTO'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void deletePhoto() {
    Navigator.pop(context, true);
  }
}
