import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/uploaded_photo.dart';
import 'package:much_todo/src/screens/more_screen/uploaded_photo_view.dart';
import 'package:much_todo/src/services/photo_service.dart';
import 'package:much_todo/src/utils/constants.dart';
import 'package:much_todo/src/widgets/skeletons/uploaded_photos_skeleton.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class UploadedPhotosScreen extends StatefulWidget {
  final String userId;

  const UploadedPhotosScreen({super.key, required this.userId});

  @override
  State<UploadedPhotosScreen> createState() => _UploadedPhotosScreenState();
}

class _UploadedPhotosScreenState extends State<UploadedPhotosScreen> {
  List<UploadedPhoto> _photos = [];
  bool _isLoading = false;
  double _megaBytesUploaded = 0;

  @override
  void initState() {
    super.initState();
    getPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uploaded Photos'),
        scrolledUnderElevation: 0,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      body: Column(
        children: [
          if (_isLoading) const Expanded(child: UploadedPhotosSkeleton()),
          if (!_isLoading && _photos.isNotEmpty)
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LinearPercentIndicator(
                          percent: getUploadedPercentage(),
                          lineHeight: 20,
                          progressColor: Colors.green,
                        ),
                        Text(
                            '${_megaBytesUploaded.toStringAsFixed(2)}MB of ${(Constants.maxUploadBytes / 1000000).round()}MB used')
                      ],
                    ),
                  ),
                  Expanded(
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
                                child: Image.network(
                                  photo.publicUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                    return const Center(child: Icon(Icons.broken_image));
                                  },
                                )),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          if (!_isLoading && _photos.isEmpty) const Center(child: Text('No images uploaded'))
        ],
      ),
    );
  }

  double getUploadedPercentage() {
    int uploadedBytes = 0;
    for (final photo in _photos) {
      uploadedBytes += photo.bytes;
    }
    _megaBytesUploaded = uploadedBytes / 1000000;
    if (uploadedBytes >= Constants.maxUploadBytes) {
      return 1.0;
    } else {
      return uploadedBytes / Constants.maxUploadBytes;
    }
  }

  Future<void> getPhotos() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _photos = await PhotoService.getAllUploadedPhotos(widget.userId);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> openPhoto(BuildContext context, UploadedPhoto photo) async {
    var deleted = await Navigator.push<bool?>(
      context,
      MaterialPageRoute(
        builder: (context) => UploadedPhotoView(
          photo: photo,
        ),
      ),
    );
    if (deleted != null && deleted) {
      _photos.remove(photo);
      setState(() {});
    }
  }
}
