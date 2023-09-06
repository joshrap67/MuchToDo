import 'package:firebase_storage/firebase_storage.dart';

class PhotoService {
  static Future<List<String>> loadPhotos(List<String> files) async {
    if (files.isEmpty) {
      return [];
    }
    final storageRef = FirebaseStorage.instance.ref();
    try {
      var urls = <String>[];
      for (var photo in files) {
        var url = await storageRef.child(photo).getDownloadURL();
        urls.add(url);
      }
      return urls;
    } catch (e) {
      // todo need to verify this isn't tripped if file is not found since that will cause issues if user deletes it from their photos list
      return Future.error('error');
    }
  }
}
