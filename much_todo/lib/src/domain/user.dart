import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/tag.dart';

class User {
  late String id;
  late String firebaseId;
  late String email;
  List<Tag> tags = [];
  List<Contact> contacts = [];
  List<String> tasks = [];
  List<String> rooms = [];

  User(this.id, this.firebaseId, this.tags, this.email, this.tasks, this.rooms, this.contacts);

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firebaseId = json['firebaseId'];
    email = json['email'];

    var rawTags = json['tags'] as List<dynamic>;
    tags = <Tag>[];
    for (var rawTag in rawTags) {
      tags.add(Tag.fromJson(rawTag));
    }

    var rawContacts = json['contacts'] as List<dynamic>;
    contacts = <Contact>[];
    for (var rawContact in rawContacts) {
      contacts.add(Contact.fromJson(rawContact));
    }

    tasks = <String>[];
    for (var task in json['tasks']) {
      tasks.add(task);
    }

    rooms = <String>[];
    for (var room in json['rooms']) {
      rooms.add(room);
    }
  }

  @override
  String toString() {
    return 'User{id: $id, firebaseId: $firebaseId, tags: $tags, email: $email, tasks: $tasks, rooms:$rooms, contacts: $contacts}';
  }
}
