import 'package:much_todo/src/domain/todo.dart';

class Tag {
  String id;
  String name;
  List<String> todos;

  Tag(this.id, this.name, {this.todos = const []});

  TodoTag convert() {
    return TodoTag(id, name);
  }

  @override
  String toString() {
    return 'Tag{id: $id, name: $name, todos: $todos}';
  }
}
