import 'package:much_todo/src/repositories/api_request.dart';

class UpdateTaskRequest implements ApiRequest {
  late String name;
  late int priority;
  late int effort;
  late String roomId;
  double? estimatedCost;
  String? note;
  List<String> tagIds = [];
  List<String> links = [];
  List<String> contactIds = [];
  late DateTime? completeBy;

  UpdateTaskRequest(
    this.name,
    this.priority,
    this.effort,
    this.estimatedCost,
    this.tagIds,
    this.contactIds,
    this.roomId,
    this.note,
    this.links,
    this.completeBy,
  );

  @override
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'priority': priority,
      'effort': effort,
      'estimatedCost': estimatedCost,
      'note': note,
      'links': links,
      'tagIds': tagIds,
      'contactIds': contactIds,
      'roomId': roomId,
      'completeBy': completeBy?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'CreateTasksRequest{name: $name, priority: $priority, effort: $effort, estimatedCost: $estimatedCost, note: $note, links: $links, '
        'tagIds: $tagIds, contactIds: $contactIds, roomId: $roomId, completeBy: $completeBy}';
  }
}
