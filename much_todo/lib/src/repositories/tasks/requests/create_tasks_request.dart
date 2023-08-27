import 'package:much_todo/src/repositories/api_request.dart';

class CreateTasksRequest implements ApiRequest {
  late String name;
  late int priority;
  late int effort;
  late List<String> roomIds;
  double? estimatedCost;
  String? note;
  List<String> tagIds = [];
  List<String> links = [];
  List<String> photos = [];
  List<String> contactIds = [];
  bool inProgress = false;
  late DateTime? completeBy;

  CreateTasksRequest(
    this.name,
    this.priority,
    this.effort,
    this.tagIds,
    this.contactIds,
    this.roomIds,
    this.estimatedCost,
    this.note,
    this.links,
    this.photos,
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
      'photos': photos,
      'tagIds': tagIds,
      'contactIds': contactIds,
      'roomIds': roomIds,
      'inProgress': inProgress,
      'completeBy': completeBy,
    };
  }

  @override
  String toString() {
    return 'CreateTasksRequest{name: $name, priority: $priority, effort: $effort, estimatedCost: $estimatedCost, note: $note, links: $links,'
        'photos: $photos, tagIds: $tagIds, contactIds: $contactIds, roomIds: $roomIds, inProgress: $inProgress, completeBy: $completeBy}';
  }
}
