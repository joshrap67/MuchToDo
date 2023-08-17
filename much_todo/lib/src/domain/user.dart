import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/tag.dart';

class User {
  String id;
  String email;
  List<Tag> tags;
  List<Contact> contacts;
  List<String> tasks;

  User(this.id, this.tags, this.email, this.tasks, this.contacts);

  @override
  String toString() {
    return 'User{id: $id, tags: $tags, email: $email, tasks: $tasks, contacts: $contacts}';
  }
}
