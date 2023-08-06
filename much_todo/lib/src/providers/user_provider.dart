import 'package:flutter/cupertino.dart';
import 'package:much_todo/src/domain/person.dart';
import 'package:much_todo/src/domain/tag.dart';
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
}
