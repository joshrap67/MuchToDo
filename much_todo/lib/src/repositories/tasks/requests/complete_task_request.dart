import 'package:much_todo/src/repositories/api_request.dart';

class CompleteTaskRequest implements ApiRequest {
  DateTime completeDate;

  CompleteTaskRequest({
    required this.completeDate,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'completeDate': completeDate.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'CompleteTaskRequest{completeDate: $completeDate}';
  }
}
