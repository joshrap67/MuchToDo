import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:much_todo/src/domain/task_photo.dart';
import 'package:much_todo/src/domain/uploaded_photo.dart';
import 'package:much_todo/src/utils/result.dart';

class PhotoService {
  static Future<List<TaskPhoto>> loadPhotos(List<String> files) async {
    if (files.isEmpty) {
      return [];
    }
    final storageRef = FirebaseStorage.instance.ref();

    var photos = <TaskPhoto>[];
    for (var file in files) {
      try {
        final url = await storageRef.child(file).getDownloadURL();
        photos.add(TaskPhoto(filePath: file, publicUrl: url));
      } catch (e, s) {
        if (e is FirebaseException) {
          if (e.code != 'object-not-found') {
            // object not found is not technically an error, so don't record it as such
            FirebaseCrashlytics.instance.recordError(e, s);
          }
          // still need file path so user can decide to delete the photo
          photos.add(TaskPhoto(filePath: file));
        } else {
          FirebaseCrashlytics.instance.recordError(e, s);
          return Future.error('error');
        }
      }
    }
    return photos;
  }

  static Future<List<UploadedPhoto>> getAllUploadedPhotos(String userId) async {
    final storageRefRoot = FirebaseStorage.instance.ref().child(userId);
    final storageRef = FirebaseStorage.instance.ref();
    try {
      var files = await storageRefRoot.listAll();
      var photos = <UploadedPhoto>[];
      for (var prefix in files.prefixes) {
        var objects = await prefix.listAll();
        for (var object in objects.items) {
          var url = await storageRef.child(object.fullPath).getDownloadURL();
          var metadata = await storageRef.child(object.fullPath).getMetadata();
          photos.add(UploadedPhoto(
              publicUrl: url, path: object.fullPath, bytes: metadata.size!, uploadDate: metadata.updated!));
        }
      }
      return photos;
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      return Future.error('error');
    }
  }

  static Future<Result<void>> deleteUploadedPhoto(String path) async {
    final storageRef = FirebaseStorage.instance.ref().child(path);
    var result = Result();
    try {
      await storageRef.delete();
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
      result.setErrorMessage('There was a problem deleting the uploaded photo');
    }
    return result;
  }
}
