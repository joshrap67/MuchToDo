import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/screens/task_details/task_photo_view.dart';
import 'package:much_todo/src/services/task_service.dart';
import 'package:much_todo/src/utils/utils.dart';

class PhotoWrapper {
  String? networkUrl;
  XFile? localPhoto;

  PhotoWrapper({this.networkUrl, this.localPhoto});

  bool isNetwork() {
    return networkUrl != null;
  }

  bool isLocal() {
    return localPhoto != null;
  }
}

class SetTaskPhotosScreen extends StatefulWidget {
  final String taskId;
  final List<String> firebaseUrls;

  const SetTaskPhotosScreen({super.key, required this.taskId, required this.firebaseUrls});

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
    _photos.addAll(widget.firebaseUrls.map((e) => PhotoWrapper(networkUrl: e)).toList());
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
        actions: [TextButton(onPressed: save, child: const Text('SAVE'))],
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
                return Card(
                  child: GestureDetector(
                    onTap: () => openPhoto(context, photo),
                    child: Hero(
                      tag: photo.hashCode,
                      child: photo.isNetwork()
                          ? Image.network(
                              photo.networkUrl!,
                              fit: BoxFit.fill,
                              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                return const Center(child: Icon(Icons.broken_image));
                              },
                            )
                          : Image.file(
                              fit: BoxFit.fill,
                              File(
                                photo.localPhoto!.path,
                              ),
                            ),
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
                  onPressed: addPhoto,
                  icon: const Icon(Icons.add),
                  label: const Text('ADD PHOTO'),
                  heroTag: 'TaskFab',
                )),
          )
        ],
      ),
    );
  }

  Future<void> openPhoto(BuildContext context, PhotoWrapper photo) async {
    bool? deleted = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskPhotoView(
          photo: photo,
        ),
      ),
    );
    if (deleted != null && deleted) {
      if (photo.isNetwork()) {
        _removedPhotos.add(photo.networkUrl!);
      }
      _photos.remove(photo);
      setState(() {});
    }
  }

  Future<void> addPhoto() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
	// todo max file size?
	// todo compression
    if (image != null) {
      setState(() {
        _photos.add(PhotoWrapper(localPhoto: image));
      });
    }
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
      Task? task = await TaskService.setTaskPhotos(context, widget.taskId, uploadedPhotos, _removedPhotos);

      if (task != null && context.mounted) {
        closePopup(context); // todo ugh
        Navigator.pop(context, task);
      } else if (context.mounted) {
        closePopup(context);
      }
    }
  }
}
