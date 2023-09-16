import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:much_todo/src/screens/task_details/set_task_photos_screen.dart';
import 'package:much_todo/src/screens/task_details/task_photo_view.dart';
import 'package:much_todo/src/services/photo_service.dart';
import 'package:much_todo/src/services/task_service.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
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
