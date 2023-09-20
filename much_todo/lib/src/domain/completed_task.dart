import 'package:much_todo/src/domain/room.dart';

class CompletedTask {
  late String id;
  late String createdBy;
  late String name;
  late int priority;
  late int effort;
  late String roomId;
  late String roomName;
  double? estimatedCost;
  String? note;
  List<String> tags = [];
  List<String> links = [];
  List<CompletedTaskContact> contacts = [];
  late DateTime completionDate;

  CompletedTask(this.id, this.createdBy, this.name, this.tags, this.priority, this.effort, this.roomId, this.roomName,
      this.estimatedCost, this.note, this.links, this.contacts, this.completionDate);

  CompletedTask.named({
    required this.id,
    required this.name,
    required this.priority,
    required this.effort,
    required this.createdBy,
    required this.roomId,
    required this.roomName,
    required this.completionDate,
    this.tags = const [],
    this.estimatedCost,
    this.note,
    this.links = const [],
    this.contacts = const [],
  });

  CompletedTask.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    priority = json['priority'];
    effort = json['effort'];
    createdBy = json['createdBy'];
    roomId = json['roomId'];
    roomName = json['roomName'];
    completionDate = DateTime.parse(json['completionDate']);

    var tags = <String>[];
    for (var tag in json['tags']) {
      tags.add(tag);
    }
    this.tags = tags;

    var rawContacts = json['contacts'] as List<dynamic>;
    var contacts = <CompletedTaskContact>[];
    for (var rawContact in rawContacts) {
      contacts.add(CompletedTaskContact.fromJson(rawContact));
    }
    this.contacts = contacts;

    estimatedCost = json['estimatedCost']?.toDouble();
    note = json['note'];

    var links = <String>[];
    for (var link in json['links']) {
      links.add(link);
    }
    this.links = links;
  }

  @override
  String toString() {
    return 'CompletedTask{id: $id, name: $name, priority: $priority, effort: $effort, createdBy: $createdBy, tags: $tags, '
        'roomId: $roomId, roomName: $roomName, estimatedCost: $estimatedCost, note: $note, links: $links, '
        'contacts: $contacts, completionDate: $completionDate}';
  }

  RoomTask convert() {
    return RoomTask(id, name, estimatedCost);
  }
}

class CompletedTaskContact {
  late String name;
  String? email;
  String? phoneNumber;

  CompletedTaskContact(this.name, this.email, this.phoneNumber);

  CompletedTaskContact.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
  }

  @override
  String toString() {
    return 'CompletedTaskContact{name: $name, email: $email, phoneNumber: $phoneNumber}';
  }
}
