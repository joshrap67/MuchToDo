import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../domain/person.dart';

class UserService {
  static Tag createTag(BuildContext context, String name) {
    var tag = Tag(const Uuid().v4(), name);
    context.read<UserProvider>().addTag(tag);
    return tag;
  }

  static Future<Person> createPerson(BuildContext context, String name, String? email, String? number) async {
    Person? person;
    await Future.delayed(const Duration(seconds: 2), () {
      person = Person(const Uuid().v4(), name, email, number);
      context.read<UserProvider>().addPerson(person!);
    });

    return person!;
  }
}
