class Todo {
  String id;
  String createdBy;
  String name;
  int priority;
  int effort;
  TodoRoom? room;
  double? approximateCost;
  String? note;
  List<TodoTag> tags;
  List<String> links = [];
  List<String> photos = [];
  List<TodoPerson> people;
  bool isCompleted = false;
  bool inProgress = false;
  DateTime? completeBy;
  DateTime? creationDate;

  // todo equipment needed? maybe use that for note

  Todo(
      this.id,
      this.createdBy,
      this.name,
      this.tags,
      this.priority,
      this.effort,
      this.room,
      this.approximateCost,
      this.note,
      this.links,
      this.photos,
      this.people,
      this.isCompleted,
      this.inProgress,
      this.completeBy,
      this.creationDate);

  Todo.named(
      {required this.id,
      required this.name,
      required this.priority,
      required this.effort,
      required this.createdBy,
      this.tags = const [],
      this.room,
      this.approximateCost,
      this.note,
      this.links = const [],
      this.photos = const [],
      this.people = const [],
      this.isCompleted = false,
      this.inProgress = false,
      this.completeBy,
      this.creationDate});

  @override
  String toString() {
    return 'Todo{id: $id, name: $name, priority: $priority, effort: $effort, createdBy: $createdBy, tags: $tags, '
        'room: $room, approximateCost: $approximateCost, note: $note, links: $links, photos: $photos, '
        'people: $people, isCompleted: $isCompleted, inProgress: $inProgress, completeBy: $completeBy}';
  }
}

class TodoRoom {
  String id;
  String name;

  TodoRoom(this.id, this.name);

  @override
  String toString() {
    return 'TodoRoom{id: $id, name: $name}';
  }
}

class TodoPerson {
  String id;
  String name;
  String? email;
  String? phoneNumber;

  TodoPerson(this.id, this.name, this.email, this.phoneNumber);

  @override
  String toString() {
    return 'TodoPerson{id: $id, name: $name, email: $email, phoneNumber: $phoneNumber}';
  }
}

class TodoTag {
  String id;
  String name;

  TodoTag(this.id, this.name);

  @override
  String toString() {
    return 'TodoTag{id: $id, name: $name}';
  }
}
