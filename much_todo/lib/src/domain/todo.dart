import 'package:much_todo/src/domain/professional.dart';

class Todo {
  String id;
  String name;
  List<String> tags;
  int priority;
  int effort;
  String? roomId;
  double? approximateCost;
  String? note;
  List<String> links = [];
  List<String> pictures = [];
  List<Professional> professionals;
  bool isCompleted = false;
  bool inProgress = false;
  DateTime? completeBy;
  DateTime? creationDate; // todo instant
  // todo equipment needed? maybe use that for note
  // todo created by
  // todo recurring?

  Todo(this.id, this.name, this.tags, this.priority, this.effort, this.roomId, this.approximateCost, this.note,
      this.links, this.pictures, this.professionals, this.isCompleted, this.inProgress, this.completeBy);

  Todo.named(
      {required this.id,
      required this.name,
      required this.priority,
      required this.effort,
      this.tags = const [],
      this.roomId,
      this.approximateCost,
      this.note,
      this.links = const [],
      this.pictures = const [],
      this.professionals = const [],
      this.isCompleted = false,
      this.inProgress = false,
      this.completeBy});
}
