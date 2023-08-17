import 'package:much_todo/src/domain/task.dart';

class Contact {
  String id;
  String name;
  String? email;
  String? phoneNumber;
  List<String> tasks = [];

  Contact(this.id, this.name, this.email, this.phoneNumber);

  TaskContact convert() {
    return TaskContact(id, name, email, phoneNumber);
  }

  @override
  String toString() {
    return 'Contact{id: $id, name: $name, email: $email, phoneNumber: $phoneNumber, tasks: $tasks}';
  }
}
