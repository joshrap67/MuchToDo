import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/task_photo.dart';
import 'package:photo_view/photo_view.dart';

class TaskPhotoViewReadOnly extends StatefulWidget {
  final TaskPhoto photo;

  const TaskPhotoViewReadOnly({super.key, required this.photo});

  @override
  State<TaskPhotoViewReadOnly> createState() => _TaskPhotoViewReadOnlyState();
}

class _TaskPhotoViewReadOnlyState extends State<TaskPhotoViewReadOnly> {
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
            if (hasPhoto())
              PhotoView(
                heroAttributes: PhotoViewHeroAttributes(tag: widget.photo.hashCode),
                backgroundDecoration: BoxDecoration(color: Theme.of(context).colorScheme.background),
                imageProvider: NetworkImage(widget.photo.publicUrl!),
              ),
            if (!hasPhoto())
              const Center(
                child: Icon(Icons.broken_image),
              )
          ],
        ),
      ),
    );
  }

  bool hasPhoto() {
    return widget.photo.publicUrl != null;
  }
}
