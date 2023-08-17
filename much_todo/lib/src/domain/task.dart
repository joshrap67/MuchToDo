import 'package:much_todo/src/domain/room.dart';

class Task {
  static const lowEffort = 1;
  static const mediumEffort = 2;
  static const highEffort = 3;

  String id;
  String createdBy;
  String name;
  int priority;
  int effort;
  TaskRoom room;

  // todo should i use the decimal package for this? idk i mean this are approximate anyway so im not too concerned with small floating point errors
  double? estimatedCost;
  String? note;
  List<TaskTag> tags;
  List<String> links = [];
  List<String> photos = [];
  List<TaskContact> contacts;
  bool isCompleted = false;
  bool inProgress = false;
  DateTime? completeBy;
  DateTime? creationDate; // todo shouldn't be nullable
  // todo completionDate? could just have that replace isCompleted and make isCompleted a function

  Task(
      this.id,
      this.createdBy,
      this.name,
      this.tags,
      this.priority,
      this.effort,
      this.room,
      this.estimatedCost,
      this.note,
      this.links,
      this.photos,
      this.contacts,
      this.isCompleted,
      this.inProgress,
      this.completeBy,
      this.creationDate);

  Task.named(
      {required this.id,
      required this.name,
      required this.priority,
      required this.effort,
      required this.createdBy,
      required this.room,
      this.tags = const [],
      this.estimatedCost,
      this.note,
      this.links = const [],
      this.photos = const [],
      this.contacts = const [],
      this.isCompleted = false,
      this.inProgress = false,
      this.completeBy,
      this.creationDate});

  @override
  String toString() {
    return 'Task{id: $id, name: $name, priority: $priority, effort: $effort, createdBy: $createdBy, tags: $tags, '
        'room: $room, estimatedCost: $estimatedCost, note: $note, links: $links, photos: $photos, '
        'contacts: $contacts, isCompleted: $isCompleted, inProgress: $inProgress, completeBy: $completeBy}';
  }

  RoomTask convert(){
	  return RoomTask(id, name, estimatedCost);
  }
}

class TaskRoom {
  String id;
  String name;

  TaskRoom(this.id, this.name);

  @override
  String toString() {
    return 'TaskRoom{id: $id, name: $name}';
  }
}

class TaskContact {
  String id;
  String name;
  String? email;
  String? phoneNumber;

  TaskContact(this.id, this.name, this.email, this.phoneNumber);

  @override
  String toString() {
    return 'TaskContact{id: $id, name: $name, email: $email, phoneNumber: $phoneNumber}';
  }
}

class TaskTag {
  String id;
  String name;

  TaskTag(this.id, this.name);

  @override
  String toString() {
    return 'TaskTag{id: $id, name: $name}';
  }
}
