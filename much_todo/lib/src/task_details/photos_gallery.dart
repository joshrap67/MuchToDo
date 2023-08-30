import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotosGallery extends StatefulWidget {
  final List<String> links;
  final int initialIndex;

  const PhotosGallery({super.key, this.initialIndex = 0, required this.links});

  @override
  State<PhotosGallery> createState() => _PhotosGalleryState();
}

class _PhotosGalleryState extends State<PhotosGallery> {
  late int currentIndex;
  PageController controller = PageController();

  @override
  void initState() {
    super.initState();
    controller = PageController(initialPage: widget.initialIndex);
    currentIndex = widget.initialIndex;
  }

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
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (context, index) {
                var url = widget.links[index];
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(url),
                  initialScale: PhotoViewComputedScale.contained,
                  minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
                  maxScale: PhotoViewComputedScale.covered * 4.1,
                  heroAttributes: PhotoViewHeroAttributes(tag: url.hashCode), // todo remove since causes issues when you scroll on gallery
                );
              },
              itemCount: widget.links.length,
              onPageChanged: onPageChanged,
              scrollDirection: Axis.horizontal,
              pageController: controller,
              backgroundDecoration: BoxDecoration(color: Theme.of(context).colorScheme.background),
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Photo ${currentIndex + 1}",
                style: const TextStyle(
                  fontSize: 17.0,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }
}
