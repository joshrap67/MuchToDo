import 'package:much_todo/src/domain/task.dart';

class Room {
  late String id;
  late String name;
  String? note;
  bool isFavorite = false;
  late DateTime creationDate;
  List<RoomTask> tasks = [];

  Room(this.id, this.name, this.note, this.tasks);

  Room.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    note = json['note'];
    isFavorite = json['isFavorite'];
    creationDate = json['creationDate'] != null ? DateTime.parse(json['creationDate']) : DateTime.now();
    tasks = <RoomTask>[];
    for (var task in json['tasks']) {
      tasks.add(RoomTask.fromJson(task));
    }
  }

  void update(String newName, String? newNote) {
    name = newName;
    note = newNote;
  }

  @override
  String toString() {
    return 'Room{Id: $id, name: $name, note: $note, creationDate: $creationDate, tasks: $tasks}';
  }

  TaskRoom convert() {
    return TaskRoom(id, name);
  }

  double totalCost() {
    var cost = 0.0;
    for (var task in tasks) {
      if (task.estimatedCost != null) {
        cost += task.estimatedCost!;
      }
    }

    return cost;
  }
}

class RoomTask {
  late String id;
  late String name;
  double? estimatedCost;

  RoomTask(this.id, this.name, this.estimatedCost);

  RoomTask.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    estimatedCost = json['estimatedCost']?.toDouble();
  }

  void update(String newName, double? newEstimatedCost) {
    name = newName;
    estimatedCost = newEstimatedCost;
  }

  @override
  String toString() {
    return 'RoomTask{Id: $id, name: $name, estimatedCost: $estimatedCost}';
  }
}
