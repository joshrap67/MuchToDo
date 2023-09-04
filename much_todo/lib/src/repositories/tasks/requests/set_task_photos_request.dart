import 'package:much_todo/src/repositories/api_request.dart';

class SetTaskPhotosRequest implements ApiRequest {
  List<String> photosToUpload = [];
  List<String> deletedPhotos = [];

  SetTaskPhotosRequest({required this.photosToUpload, required this.deletedPhotos});

  @override
  Map<String, dynamic> toJson() {
    return {
      'photosToUpload': photosToUpload,
      'deletedPhotos': deletedPhotos,
    };
  }

  @override
  String toString() {
    return 'SetTaskPhotosRequest{photosToUpload: $photosToUpload, deletedPhotos: $deletedPhotos}';
  }
}
