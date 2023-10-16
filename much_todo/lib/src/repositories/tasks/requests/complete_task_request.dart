import 'package:much_todo/src/repositories/api_request.dart';

class CompleteTaskRequest implements ApiRequest {
  DateTime completeDate;
  double? cost;

  CompleteTaskRequest({required this.completeDate, this.cost});

  @override
  Map<String, dynamic> toJson() {
    return {'completeDate': completeDate.toIso8601String(), 'cost': cost};
  }

  @override
  String toString() {
    return 'CompleteTaskRequest{completeDate: $completeDate, cost: $cost}';
  }
}
