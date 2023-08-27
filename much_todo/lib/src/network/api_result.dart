class ApiResult {
  String data;
  bool success = true;
  int? statusCode;

  ApiResult.success(this.data);

  ApiResult.failure(this.data, this.statusCode) : success = false;

  @override
  String toString() {
    return 'ApiResult{data: $data, success: $success, statusCode: $statusCode}';
  }
}
