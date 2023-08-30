import 'package:much_todo/src/domain/task.dart';

class Contact {
  late String id;
  late String name;
  String? email;
  String? phoneNumber;
  List<String> tasks = [];

  Contact(this.id, this.name, this.email, this.phoneNumber);

  Contact.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];

    tasks = <String>[];
    for (var task in json['tasks']) {
      tasks.add(task);
    }
  }

  TaskContact convert() {
    return TaskContact(id, name, email, phoneNumber);
  }

  @override
  String toString() {
    return 'Contact{id: $id, name: $name, email: $email, phoneNumber: $phoneNumber, tasks: $tasks}';
  }
}
