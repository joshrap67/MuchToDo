import 'package:flutter/cupertino.dart';
import 'package:much_todo/src/domain/person.dart';
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
        Person(const Uuid().v4(), 'Dennis Reynolds', 'example@gmail.com', '+18038675309'),
        Person(const Uuid().v4(), 'Charlie Kelly', 'example@gmail.com', '+18038675309'),
        Person(const Uuid().v4(), 'Frank Reynolds', 'example@gmail.com', '+18038675309'),
        Person(const Uuid().v4(), 'Deandra Reynolds', 'example@gmail.com', '+18038675309'),
        Person(const Uuid().v4(), 'Ronald MacDonald', 'example@gmail.com', '+18038675309'),
      ]);
  final User _user = initialData;

  User? get user => _user;

  List<Person> get people => [..._user.people];

  List<Tag> get tags => [..._user.tags];

  void addTag(Tag tag) {
    _user.tags.add(tag);
    notifyListeners();
  }

  void addPerson(Person person) {
    _user.people.add(person);
    notifyListeners();
  }

  void updateTag(Tag tag) {
    var index = _user.tags.indexWhere((t) => t.id == tag.id);
    if (index >= 0) {
      _user.tags[index] = tag;
    }
    notifyListeners();
  }

  void updatePerson(Person person) {
    var index = _user.people.indexWhere((p) => p.id == person.id);
    if (index >= 0) {
      _user.people[index] = person;
    }
    notifyListeners();
  }

  void deleteTag(Tag tag) {
    _user.tags.removeWhere((t) => t.id == tag.id);
    notifyListeners();
  }

  void deletePerson(Person person) {
    _user.people.removeWhere((p) => p.id == person.id);
    notifyListeners();
  }

  void addTasks(List<Task> createdTasks) {
    Map<String, Tag> tagIdToTag = {};
    Map<String, Person> personIdToPerson = {};
    // for quicker lookup
    for (var tag in _user.tags) {
      tagIdToTag[tag.id] = tag;
    }
    for (var person in _user.people) {
      personIdToPerson[person.id] = person;
    }

    for (var task in createdTasks) {
      for (TaskTag taskTag in task.tags) {
        Tag? tag = tagIdToTag[taskTag.id];
        tag?.tasks.add(task.id);
      }
      for (TaskPerson taskPerson in task.people) {
        Person? person = personIdToPerson[taskPerson.id];
        person?.tasks.add(task.id);
      }
    }

    notifyListeners();
  }

  void updateTask(Task task) {
    for (var person in _user.people) {
      person.tasks.removeWhere((t) => t == task.id);
    }
    for (var person in _user.tags) {
      person.tasks.removeWhere((t) => t == task.id);
    }
    // honestly easier to just assume the tag or person was removed from the task, then add it back instead of keeping track of old task
    addTasks([task]);
  }

  void removeTask(Task task) {
    for (var person in _user.people) {
      person.tasks.removeWhere((t) => t == task.id);
    }
    for (var person in _user.tags) {
      person.tasks.removeWhere((t) => t == task.id);
    }

    notifyListeners();
  }
}
