class Result<T> {
  late bool success;
  T? data;
  String? errorMessage;

  Result.success({required this.data}) : success = true;

  Result.failure({this.errorMessage}) : success = false;
}
