import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UploadedPhotosSkeleton extends StatefulWidget {
  const UploadedPhotosSkeleton({super.key});

  @override
  State<UploadedPhotosSkeleton> createState() => _UploadedPhotosSkeletonState();
}

class _UploadedPhotosSkeletonState extends State<UploadedPhotosSkeleton> {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [Text('20 MB of 100 MB used')],
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemCount: 20,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: GestureDetector(
                    child: const Skeleton.replace(
                      child: Icon(Icons.accessibility, size: 40),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
