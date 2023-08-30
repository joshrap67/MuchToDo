import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseImage extends StatefulWidget {
  final String fileName;
  final ImageErrorWidgetBuilder? errorBuilder;
  final BoxFit? fit;

  const FirebaseImage({super.key, required this.fileName, this.errorBuilder, this.fit});

  @override
  State<FirebaseImage> createState() => _FirebaseImageState();
}

class _FirebaseImageState extends State<FirebaseImage> {
  late Future<String> _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = loadImage();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
          future: _imageUrl,
          builder: (BuildContext context, AsyncSnapshot<String> image) {
            if (image.hasData && !image.hasError) {
              return Expanded(
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.network(
                    image.data.toString(),
                    errorBuilder: widget.errorBuilder,
                    fit: widget.fit,
                  ),
                ),
              );
            } else if (image.hasError) {
              return const Center(child: Icon(Icons.broken_image));
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ],
    );
  }

  Future<String> loadImage() async {
    final storageRef = FirebaseStorage.instance.ref();
    try {
      return await storageRef.child(widget.fileName).getDownloadURL();
    } catch (e) {
      return Future.error('error');
    }
  }
}
