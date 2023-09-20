import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:much_todo/src/domain/task_photo.dart';
import 'package:much_todo/src/screens/task_details/task_photo_view.dart';
import 'package:much_todo/src/services/task_service.dart';
import 'package:much_todo/src/utils/constants.dart';
import 'package:much_todo/src/utils/utils.dart';

class PhotoWrapper {
  TaskPhoto? taskPhoto;
  XFile? localPhoto;

  PhotoWrapper({this.taskPhoto, this.localPhoto});

  bool isNetwork() {
    return taskPhoto != null;
  }

  bool isLocal() {
    return localPhoto != null;
  }
}

class SetTaskPhotosScreen extends StatefulWidget {
  final String taskId;
  final List<TaskPhoto> photos;

  const SetTaskPhotosScreen({super.key, required this.taskId, required this.photos});

  @override
  State<SetTaskPhotosScreen> createState() => _SetTaskPhotosScreenState();
}

class _SetTaskPhotosScreenState extends State<SetTaskPhotosScreen> {
  final ImagePicker picker = ImagePicker();
  final List<PhotoWrapper> _photos = [];
  final List<String> _removedPhotos = [];
  final PageController _controller = PageController();

  @override
  void initState() {
    super.initState();
    _photos.addAll(widget.photos.map((e) => PhotoWrapper(taskPhoto: e)).toList());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Photos'),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        actions: [
          TextButton(
            onPressed: save,
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
            child: const Text('SAVE'),
          )
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Visibility(
            visible: _photos.isNotEmpty,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: _photos.length,
              itemBuilder: (BuildContext context, int index) {
                var photo = _photos[index];
                return GestureDetector(
                  onTap: () => openPhoto(context, photo),
                  child: Card(
                    child: Hero(
                      tag: photo.hashCode,
                      child: getPhotoWidget(photo),
                    ),
                  ),
                );
              },
            ),
          ),
          Visibility(
            visible: _photos.isEmpty,
            child: const Center(child: Text('No photos for this task')),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 8.0),
              child: FloatingActionButton.extended(
                onPressed: promptAddPhoto,
                icon: const Icon(Icons.add),
                label: const Text('NEW PHOTO'),
                heroTag: 'TaskFab',
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget getPhotoWidget(PhotoWrapper photo) {
    if (photo.localPhoto != null) {
      return Image.file(
        fit: BoxFit.cover,
        File(
          photo.localPhoto!.path,
        ),
      );
    } else if (photo.taskPhoto != null && photo.taskPhoto!.publicUrl != null) {
      return Image.network(
        photo.taskPhoto!.publicUrl!,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
          return const Center(child: Icon(Icons.broken_image));
        },
      );
    } else {
      return const Center(child: Icon(Icons.broken_image));
    }
  }

  void promptAddPhoto() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: const Text('Existing Photo'),
              leading: const Icon(Icons.photo_library),
              onTap: () {
                Navigator.pop(context);
                addPhoto();
              },
            ),
            ListTile(
              title: const Text('New Photo'),
              leading: const Icon(Icons.camera_alt),
              onTap: () {
                Navigator.pop(context);
                takePhoto();
              },
            ),
            const Padding(padding: EdgeInsets.all(16))
          ],
        );
      },
    );
  }

  Future<void> openPhoto(BuildContext context, PhotoWrapper photo) async {
    var deleted = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskPhotoView(
          photo: photo,
        ),
      ),
    );
    if (deleted != null && deleted) {
      if (photo.isNetwork()) {
        _removedPhotos.add(photo.taskPhoto!.filePath);
      }
      _photos.remove(photo);
      setState(() {});
    }
  }

  Future<void> addPhoto() async {
    if (_photos.length >= Constants.maxTaskPhotos) {
      showSnackbar('Cannot have more than ${Constants.maxTaskPhotos} photos on a task', context);
      return;
    }

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 25,
    );
    if (image == null) {
      return;
    }

    var bytes = await image.length();
    if (bytes > 2000000 && context.mounted) {
      showSnackbar('Image file size is too large. Please try a smaller image', context);
      return;
    }

    setState(() {
      _photos.add(PhotoWrapper(localPhoto: image));
    });
  }

  Future<void> takePhoto() async {
    if (_photos.length >= Constants.maxTaskPhotos) {
      showSnackbar('Cannot have more than ${Constants.maxTaskPhotos} photos on a task', context);
      return;
    }

    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 25,
    );
    if (image == null) {
      return;
    }

    var bytes = await image.length();
    if (bytes > 2000000 && context.mounted) {
      showSnackbar('Image file size is too large. Please try a smaller image', context);
      return;
    }

    setState(() {
      _photos.add(PhotoWrapper(localPhoto: image));
    });
  }

  Future<void> save() async {
    var newPhotos = _photos.where((element) => element.isLocal()).map((e) => e.localPhoto);
    if (newPhotos.isEmpty && _removedPhotos.isEmpty) {
      return;
    }

    showLoadingDialog(context, msg: 'Saving...');
    List<String> uploadedPhotos = [];
    for (var photo in newPhotos) {
      var bytes = await photo?.readAsBytes();
      uploadedPhotos.add(base64Encode(bytes as List<int>));
    }
    if (context.mounted) {
      var result = await TaskService.setTaskPhotos(context, widget.taskId, uploadedPhotos, _removedPhotos);

      if (context.mounted) {
        closePopup(context);
      }

      if (context.mounted && result.success) {
        Navigator.pop(context, result.data!);
      } else if (context.mounted && result.failure) {
        showSnackbar('Error, you may have too many photos many uploaded. Free up some space and try again', context);
      }
    }
  }
}
