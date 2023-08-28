import 'package:much_todo/src/domain/task.dart';

class Room {
  // todo rename to something generic like "Space"? Just since if you had outside areas they really aren't rooms
  late String id;
  late String name;
  String? note;
  List<RoomTask> tasks = [];

  Room(this.id, this.name, this.note, this.tasks);

  Room.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    note = json['note'];
    tasks = <RoomTask>[];
    for (var task in json['tasks']) {
      tasks.add(RoomTask.fromJson(task));
    }
  }

  void update(String name, String? note) {
    this.name = name;
    this.note = note;
  }

  @override
  String toString() {
    return 'Room{Id: $id, name: $name, note: $note, tasks: $tasks}';
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

  void update(String name, double? estimatedCost) {
    this.name = name;
    this.estimatedCost = estimatedCost;
  }

  @override
  String toString() {
    return 'RoomTask{Id: $id, name: $name, estimatedCost: $estimatedCost}';
  }
}
