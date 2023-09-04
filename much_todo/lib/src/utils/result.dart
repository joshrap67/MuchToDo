class Result<T> {
  late bool _success;
  T? _data;
  String? _errorMessage;

  Result({T? data})
      : _data = data,
        _success = true;

  bool get success => _success;

  bool get failure => !_success;

  T? get data => _data;

  String? get errorMessage => _errorMessage;

  void setData(T data) {
    _data = data;
    _success = true;
  }

  void setErrorMessage(String errorMessage) {
    _errorMessage = errorMessage;
    _success = false;
  }
}
