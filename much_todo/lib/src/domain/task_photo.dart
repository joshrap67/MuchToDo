class TaskPhoto {
  String filePath;
  String? publicUrl;

  TaskPhoto({required this.filePath, this.publicUrl});

  @override
  String toString() {
    return 'TaskPhoto{filePath: $filePath, publicUrl: $publicUrl}';
  }
}
