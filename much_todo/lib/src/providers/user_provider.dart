import 'package:flutter/cupertino.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/domain/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = true;

  User? get user => _user;

  bool get isLoading => _isLoading;

  List<Contact> get contacts => [..._user?.contacts ?? []];

  List<Tag> get tags => [..._user?.tags ?? []];

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

  void updateTag(String id, String newName) {
    var index = _user?.tags.indexWhere((t) => t.id == id) ?? -1;
    if (index >= 0) {
      _user?.tags[index].update(newName);
    }
    notifyListeners();
  }

  void updateContact(String id, String name, String? email, String? phoneNumber) {
    var index = _user?.contacts.indexWhere((p) => p.id == id) ?? -1;
    if (index >= 0) {
      _user?.contacts[index].update(name, email, phoneNumber);
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

  void addTask(Task createdTask) {
    if (_user == null) {
      return;
    }
    _user!.tasks.add(createdTask.id);
    Map<String, Tag> tagMap = {};
    Map<String, Contact> contactMap = {};
    // for quicker lookup
    for (var tag in _user!.tags) {
      tagMap[tag.id] = tag;
    }
    for (var contact in _user!.contacts) {
      contactMap[contact.id] = contact;
    }

    for (var taskTag in createdTask.tags) {
      var tag = tagMap[taskTag.id];
      tag?.tasks.add(createdTask.id);
    }
    for (var taskContact in createdTask.contacts) {
      var contact = contactMap[taskContact.id];
      contact?.tasks.add(createdTask.id);
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
    addTask(task);
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

    var deletedTaskIds = room.tasks.map((e) => e.id).toSet();
    _user!.rooms.removeWhere((r) => r == room.id);
    for (final tag in user!.tags) {
      tag.tasks.removeWhere((t) => deletedTaskIds.contains(t));
    }
    for (final contact in user!.contacts) {
      contact.tasks.removeWhere((t) => deletedTaskIds.contains(t));
    }
    notifyListeners();
  }
}
