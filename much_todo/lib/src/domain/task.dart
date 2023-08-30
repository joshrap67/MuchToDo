import 'package:much_todo/src/domain/room.dart';

// todo list of steps?
// todo date last updated?
class Task {
  static const lowEffort = 1;
  static const mediumEffort = 2;
  static const highEffort = 3;

  late String id;
  late String createdBy;
  late String name;
  late int priority;
  late int effort;
  late TaskRoom room;
  double? estimatedCost;
  String? note;
  List<TaskTag> tags = [];
  List<String> links = [];
  List<String> photos = [];
  List<TaskContact> contacts = [];
  bool isCompleted = false;
  bool inProgress = false;
  late DateTime? completeBy;
  late DateTime creationDate;

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

  Task.named({
    required this.id,
    required this.name,
    required this.priority,
    required this.effort,
    required this.createdBy,
    required this.room,
    required this.creationDate,
    this.tags = const [],
    this.estimatedCost,
    this.note,
    this.links = const [],
    this.photos = const [],
    this.contacts = const [],
    this.isCompleted = false,
    this.inProgress = false,
    this.completeBy,
  });

  Task.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    priority = json['priority'];
    effort = json['effort'];
    createdBy = json['createdBy'];

    var rawRoom = json['room'];
    room = TaskRoom(rawRoom['id'], rawRoom['name']);

    creationDate = DateTime.parse(json['creationDate']);

    var rawTags = json['tags'] as List<dynamic>;
    var tags = <TaskTag>[];
    for (var rawTag in rawTags) {
      tags.add(TaskTag(rawTag['id'], rawTag['name']));
    }
    this.tags = tags;

    var rawContacts = json['contacts'] as List<dynamic>;
    var contacts = <TaskContact>[];
    for (var rawContact in rawContacts) {
      contacts.add(TaskContact(rawContact['id'], rawContact['name'], rawContact['email'], rawContact['phoneNumber']));
    }
    this.contacts = contacts;

    estimatedCost = json['estimatedCost']?.toDouble();
    note = json['note'];

    var links = <String>[];
    for (var link in json['links']) {
      links.add(link);
    }
    this.links = links;

    var photos = <String>[];
    for (var photo in json['photos']) {
      photos.add(photo);
    }
    this.photos = photos;

    inProgress = json['inProgress'];
    completeBy = json['completeBy'] != null ? DateTime.parse(json['completeBy']) : null;
  }

  @override
  String toString() {
    return 'Task{id: $id, name: $name, priority: $priority, effort: $effort, createdBy: $createdBy, tags: $tags, '
        'room: $room, estimatedCost: $estimatedCost, note: $note, links: $links, photos: $photos, '
        'contacts: $contacts, isCompleted: $isCompleted, inProgress: $inProgress, completeBy: $completeBy}';
  }

  RoomTask convert() {
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
