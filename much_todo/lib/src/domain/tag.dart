import 'package:much_todo/src/domain/task.dart';

class Tag {
  String id;
  String name;
  List<String> tasks;

  Tag(this.id, this.name, {this.tasks = const []});

  TaskTag convert() {
    return TaskTag(id, name);
  }

  @override
  String toString() {
    return 'Tag{id: $id, name: $name, tasks: $tasks}';
  }
}
