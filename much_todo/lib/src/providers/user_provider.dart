import 'package:flutter/cupertino.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/domain/user.dart';
import 'package:uuid/uuid.dart';

class UserProvider with ChangeNotifier {
  static final User initialData = User(
      const Uuid().v4(),
      [
        Tag(const Uuid().v4(), 'Decoration'),
        Tag(const Uuid().v4(), 'Electrical'),
        Tag(const Uuid().v4(), 'Maintenance'),
        Tag(const Uuid().v4(), 'Outside'),
        Tag(const Uuid().v4(), 'Plumbing'),
        Tag(const Uuid().v4(), 'Structural')
      ],
      'binary0010productions@gmail.com',
      [],
      [
        Contact(const Uuid().v4(), 'Dennis Reynolds', 'example@gmail.com', '+18038675309'),
        Contact(const Uuid().v4(), 'Charlie Kelly', 'example@gmail.com', '+18038675309'),
        Contact(const Uuid().v4(), 'Frank Reynolds', 'example@gmail.com', '+18038675309'),
        Contact(const Uuid().v4(), 'Deandra Reynolds', 'example@gmail.com', '+18038675309'),
        Contact(const Uuid().v4(), 'Ronald MacDonald', 'example@gmail.com', '+18038675309'),
      ]);
  final User _user = initialData;

  User? get user => _user;

  List<Contact> get contacts => [..._user.contacts];

  List<Tag> get tags => [..._user.tags];

  void addTag(Tag tag) {
    _user.tags.add(tag);
    notifyListeners();
  }

  void addContact(Contact contact) {
    _user.contacts.add(contact);
    notifyListeners();
  }

  void updateTag(Tag tag) {
    var index = _user.tags.indexWhere((t) => t.id == tag.id);
    if (index >= 0) {
      _user.tags[index] = tag;
    }
    notifyListeners();
  }

  void updateContact(Contact contact) {
    var index = _user.contacts.indexWhere((p) => p.id == contact.id);
    if (index >= 0) {
      _user.contacts[index] = contact; // todo update method instead
    }
    notifyListeners();
  }

  void deleteTag(Tag tag) {
    _user.tags.removeWhere((t) => t.id == tag.id);
    notifyListeners();
  }

  void deleteContact(Contact contact) {
    _user.contacts.removeWhere((p) => p.id == contact.id);
    notifyListeners();
  }

  void addTasks(List<Task> createdTasks) {
    Map<String, Tag> tagIdToTag = {};
    Map<String, Contact> contactIdToContact = {};
    // for quicker lookup
    for (var tag in _user.tags) {
      tagIdToTag[tag.id] = tag;
    }
    for (var contact in _user.contacts) {
      contactIdToContact[contact.id] = contact;
    }

    for (var task in createdTasks) {
      for (TaskTag taskTag in task.tags) {
        Tag? tag = tagIdToTag[taskTag.id];
        tag?.tasks.add(task.id);
      }
      for (TaskContact taskContact in task.contacts) {
        Contact? contact = contactIdToContact[taskContact.id];
        contact?.tasks.add(task.id);
      }
    }

    notifyListeners();
  }

  void updateTask(Task task) {
    for (var contact in _user.contacts) {
      contact.tasks.removeWhere((t) => t == task.id);
    }
    for (var tag in _user.tags) {
      tag.tasks.removeWhere((t) => t == task.id);
    }
    // honestly easier to just assume the tag or contact was removed from the task, then add it back instead of keeping track of old task
    addTasks([task]);
  }

  void removeTask(Task task) {
    for (var contact in _user.contacts) {
      contact.tasks.removeWhere((t) => t == task.id);
    }
    for (var tag in _user.tags) {
      tag.tasks.removeWhere((t) => t == task.id);
    }

    notifyListeners();
  }
}
