import 'package:much_todo/src/repositories/api_request.dart';

class CreateTasksRequest implements ApiRequest {
  late String name;
  late int priority;
  late int effort;
  late String roomId;
  double? estimatedCost;
  String? note;
  List<String> tagIds = [];
  List<String> links = [];
  List<String> contactIds = [];
  bool inProgress = false;
  late DateTime? completeBy;

  CreateTasksRequest(
    this.name,
    this.priority,
    this.effort,
    this.tagIds,
    this.contactIds,
    this.roomId,
    this.estimatedCost,
    this.note,
    this.links,
    this.inProgress,
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
      'inProgress': inProgress,
      'completeBy': completeBy?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'CreateTasksRequest{name: $name, priority: $priority, effort: $effort, estimatedCost: $estimatedCost, note: $note, links: $links, '
        'tagIds: $tagIds, contactIds: $contactIds, roomId: $roomId, inProgress: $inProgress, completeBy: $completeBy}';
  }
}
