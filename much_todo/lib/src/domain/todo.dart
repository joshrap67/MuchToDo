import 'package:much_todo/src/domain/professional.dart';

class Todo {
  String id;
  String name;
  List<String> tags;
  int priority;
  int? effort;
  String? roomId;
  double? approximateCost;
  String? note;
  List<String> links = [];
  List<String> pictures = [];
  bool professionalNeeded = false;
  Professional? professional;
  bool isCompleted = false;
  bool inProgress = false;
  DateTime? completeBy;
  DateTime? creationDate; // todo instant

  Todo(
      this.id,
      this.name,
      this.tags,
      this.priority,
      this.effort,
      this.roomId,
      this.approximateCost,
      this.note,
      this.links,
      this.pictures,
      this.professionalNeeded,
      this.professional,
      this.isCompleted,
      this.inProgress,
      this.completeBy);

  Todo.named(
      {required this.id,
      required this.name,
      required this.priority,
      this.tags = const [],
      this.effort,
      this.roomId,
      this.approximateCost,
      this.note,
      this.links = const [],
      this.pictures = const [],
      this.professionalNeeded = false,
      this.professional,
      this.isCompleted = false,
      this.inProgress = false,
      this.completeBy});
}
