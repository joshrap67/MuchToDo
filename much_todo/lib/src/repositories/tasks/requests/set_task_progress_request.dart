import 'package:much_todo/src/repositories/api_request.dart';

class SetTaskProgressRequest implements ApiRequest {
  bool inProgress;

  SetTaskProgressRequest({required this.inProgress});

  @override
  Map<String, dynamic> toJson() {
    return {
      'inProgress': inProgress,
    };
  }

  @override
  String toString() {
    return 'SetTaskPhotosRequest{inProgress: $inProgress}';
  }
}
