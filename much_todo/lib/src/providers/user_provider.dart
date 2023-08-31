import 'package:flutter/cupertino.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/domain/user.dart';
import 'package:uuid/uuid.dart';

class UserProvider with ChangeNotifier {
  static User initialData = User(
      const Uuid().v4(),
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
      [],
      [
        Contact(const Uuid().v4(), 'Dennis Reynolds', 'example@gmail.com', '+18038675309'),
        Contact(const Uuid().v4(), 'Charlie Kelly', 'example@gmail.com', '+18038675309'),
        Contact(const Uuid().v4(), 'Frank Reynolds', 'example@gmail.com', '+18038675309'),
        Contact(const Uuid().v4(), 'Deandra Reynolds', 'example@gmail.com', '+18038675309'),
        Contact(const Uuid().v4(), 'Ronald MacDonald', 'example@gmail.com', '+18038675309'),
      ]);
  User? _user;
  bool _isLoading = true;

  User? get user => _user;

  bool get isLoading => _isLoading;

  List<Contact> get contacts => [..._user?.contacts ?? []];

  List<Tag> get tags => [..._user?.tags ?? []];

  Future<void> loadUser(String id) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 4), () {
      _user = initialData;
    });
    _isLoading = false;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void addTag(Tag tag) {
    _user?.tags.add(tag);
    notifyListeners();
  }

  void addContact(Contact contact) {
    _user?.contacts.add(contact);
    notifyListeners();
  }

  void updateTag(Tag tag) {
    var index = _user?.tags.indexWhere((t) => t.id == tag.id) ?? -1;
    if (index >= 0) {
      _user?.tags[index].update(tag.name);
    }
    notifyListeners();
  }

  void updateContact(Contact contact) {
    var index = _user?.contacts.indexWhere((p) => p.id == contact.id) ?? -1;
    if (index >= 0) {
      _user?.contacts[index].update(contact.name, contact.email, contact.phoneNumber);
    }
    notifyListeners();
  }

  void deleteTag(Tag tag) {
    _user?.tags.removeWhere((t) => t.id == tag.id);
    notifyListeners();
  }

  void deleteContact(Contact contact) {
    _user?.contacts.removeWhere((p) => p.id == contact.id);
    notifyListeners();
  }

  void addTasks(List<Task> createdTasks) {
    if (_user == null) {
      return;
    }
    _user!.tasks.addAll(createdTasks.map((e) => e.id));
    Map<String, Tag> tagIdToTag = {};
    Map<String, Contact> contactIdToContact = {};
    // for quicker lookup
    for (var tag in _user!.tags) {
      tagIdToTag[tag.id] = tag;
    }
    for (var contact in _user!.contacts) {
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
    if (_user == null) {
      return;
    }
    for (var contact in _user!.contacts) {
      contact.tasks.removeWhere((t) => t == task.id);
    }
    for (var tag in _user!.tags) {
      tag.tasks.removeWhere((t) => t == task.id);
    }
    // honestly easier to just assume the tag or contact was removed from the task, then add it back instead of keeping track of old task
    addTasks([task]);
  }

  void removeTask(Task task) {
    if (_user == null) {
      return;
    }
    for (var contact in _user!.contacts) {
      contact.tasks.removeWhere((t) => t == task.id);
    }
    for (var tag in _user!.tags) {
      tag.tasks.removeWhere((t) => t == task.id);
    }

    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }

  void addRoom(Room room) {
    if (_user == null) {
      return;
    }

    _user!.rooms.add(room.id);
    notifyListeners();
  }

  void removeRoom(Room room) {
    if (_user == null) {
      return;
    }

    _user!.rooms.removeWhere((r) => r == room.id);
    notifyListeners();
  }
}
