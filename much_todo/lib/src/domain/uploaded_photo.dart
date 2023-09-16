class UploadedPhoto {
  String path;
  String publicUrl;
  int bytes;
  DateTime uploadDate;

  UploadedPhoto({required this.path, required this.publicUrl, required this.bytes, required this.uploadDate});

  @override
  String toString() {
    return 'UploadedPhoto{path: $path, publicUrl: $publicUrl bytes: $bytes, uploadDate: $uploadDate}';
  }
}
