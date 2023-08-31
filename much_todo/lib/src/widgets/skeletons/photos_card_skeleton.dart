import 'package:flutter/material.dart';
import 'package:much_todo/src/screens/task_details/photos_card_read_only.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PhotoCardSkeleton extends StatelessWidget {
  const PhotoCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Card(
        child: Column(
          children: [
            ListTile(
              title: const Text('Photos'),
              contentPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 12.0, 0.0),
              trailing: ElevatedButton(onPressed: () {}, child: const Text('SET PHOTOS')),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                direction: Axis.horizontal,
                spacing: 12.0, // gap between adjacent photos
                runSpacing: 4.0, // gap between lines
                children: [
                  for (var index = 0; index < 5; index++)
                    GestureDetector(
                      onTap: () {},
                      child: const SizedBox(
                        width: 60,
                        height: 60,
                        child: Skeleton.replace(
                          child: Icon(Icons.accessibility, size: 40),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
