import 'package:much_todo/src/domain/person.dart';
import 'package:much_todo/src/domain/tag.dart';

class User {
  String id;
  List<Tag> tags;
  List<Person> people;
  String email;
  List<String> todos;

  User(this.id, this.tags, this.email, this.todos, this.people);

  @override
  String toString() {
    return 'User{id: $id, tags: $tags, email: $email,  todos: $todos, people: $people}';
  }
}
