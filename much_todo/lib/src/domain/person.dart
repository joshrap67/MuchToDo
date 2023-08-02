import 'package:much_todo/src/domain/todo.dart';

class Person {
  String id;
  String name;
  String? email;
  String? phoneNumber;
  List<String> todos;

  Person(this.id, this.name, this.email, this.phoneNumber, {this.todos = const []});

  TodoPerson convert() {
    return TodoPerson(id, name, email, phoneNumber);
  }

  @override
  String toString() {
    return 'Person{id: $id, name: $name, email: $email, phoneNumber: $phoneNumber, todos: $todos}';
  }
}
