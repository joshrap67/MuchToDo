import 'package:much_todo/src/domain/task.dart';

class Room {
  // todo rename to something generic like "Space"? Just since if you had outside areas they really aren't rooms
  String id;
  String name;
  String? note;
  List<RoomTask> tasks = [];

  // todo generic note

  Room(this.id, this.name, this.note, this.tasks);

  void update(String name, String? note){
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
  String id;
  String name;
  double? estimatedCost;
  // todo isActive

  RoomTask(this.id, this.name, this.estimatedCost);

  @override
  String toString() {
    return 'RoomTask{Id: $id, name: $name, estimatedCost: $estimatedCost}';
  }
}
