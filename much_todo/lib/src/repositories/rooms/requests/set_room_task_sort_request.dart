import 'package:much_todo/src/repositories/api_request.dart';

class SetRoomTaskSortRequest implements ApiRequest {
  int taskSort;
  int taskSortDirection;

  SetRoomTaskSortRequest(this.taskSort, this.taskSortDirection);

  @override
  Map<String, dynamic> toJson() {
    return {
      'taskSort': taskSort,
      'taskSortDirection': taskSortDirection,
    };
  }

  @override
  String toString() {
    return 'SetRoomTaskSortRequest{taskSort: $taskSort, taskSortDirection: $taskSortDirection}';
  }
}
