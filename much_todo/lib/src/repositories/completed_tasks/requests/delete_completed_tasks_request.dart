import 'package:much_todo/src/repositories/api_request.dart';

class DeleteCompletedTasksRequest implements ApiRequest {
  List<String> taskIds = [];

  DeleteCompletedTasksRequest({required this.taskIds});

  @override
  Map<String, dynamic> toJson() {
    return {'taskIds': taskIds};
  }

  @override
  String toString() {
    return 'DeleteCompletedTasksRequest{taskIds: $taskIds}';
  }
}
