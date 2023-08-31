import 'package:much_todo/src/domain/task.dart';

class Tag {
  late String id;
  late String name;
  List<String> tasks = [];

  Tag(this.id, this.name);

  Tag.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    tasks = <String>[];
    for (var task in json['tasks']) {
      tasks.add(task);
    }
  }

  TaskTag convert() {
    return TaskTag(id, name);
  }

  void update(String newName) {
    name = newName;
  }

  @override
  String toString() {
    return 'Tag{id: $id, name: $name, tasks: $tasks}';
  }
}
