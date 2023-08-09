import 'package:much_todo/src/domain/todo.dart';

class Room {
  // todo rename to something generic like "Space"? Just since if you had outside areas they really aren't rooms
  String id;
  String name;
  String? note;
  List<RoomTodo> todos = [];

  // todo generic note

  Room(this.id, this.name, this.note, this.todos);

  @override
  String toString() {
    return 'Room{Id: $id, name: $name, note: $note, todos: $todos}';
  }

  TodoRoom convert() {
    return TodoRoom(id, name);
  }

  double totalCost() {
    var cost = 0.0;
    for (var todo in todos) {
      if (todo.estimatedCost != null) {
        cost += todo.estimatedCost!;
      }
    }

    return cost;
  }
}

class RoomTodo {
  String id;
  String name;
  double? estimatedCost;
  // todo isActive

  RoomTodo(this.id, this.name, this.estimatedCost);

  @override
  String toString() {
    return 'RoomTodo{Id: $id, name: $name, estimatedCost: $estimatedCost}';
  }
}
