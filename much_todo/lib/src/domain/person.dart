import 'package:much_todo/src/domain/task.dart';

class Person {
  // todo rename contact?
  String id;
  String name;
  String? email;
  String? phoneNumber;
  List<String> tasks = [];

  Person(this.id, this.name, this.email, this.phoneNumber);

  TaskPerson convert() {
    return TaskPerson(id, name, email, phoneNumber);
  }

  @override
  String toString() {
    return 'Person{id: $id, name: $name, email: $email, phoneNumber: $phoneNumber, tasks: $tasks}';
  }
}
