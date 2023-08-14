import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:much_todo/src/domain/person.dart';

class UserService {
  static Future<Tag> createTag(BuildContext context, String name) async {
    Tag? tag;
    tag = Tag(const Uuid().v4(), name);
    await Future.delayed(const Duration(seconds: 2), () {
      context.read<UserProvider>().addTag(tag!);
    });
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

  static Future<void> deleteTag(BuildContext context, Tag tag) async {
    await Future.delayed(const Duration(seconds: 2), () {
      context.read<UserProvider>().deleteTag(tag);
      context.read<TasksProvider>().removeTagFromTasks(tag);
    });
  }

  static Future<void> updateTag(BuildContext context, Tag tag) async {
    await Future.delayed(const Duration(seconds: 2), () {
      context.read<UserProvider>().updateTag(tag);
      context.read<TasksProvider>().updateTagForTasks(tag);
    });
  }

  static Future<void> deletePerson(BuildContext context, Person person) async {
    await Future.delayed(const Duration(seconds: 2), () {
      context.read<UserProvider>().deletePerson(person);
      context.read<TasksProvider>().removePersonFromTasks(person);
    });
  }

  static Future<void> updatePerson(BuildContext context, Person person) async {
    await Future.delayed(const Duration(seconds: 2), () {
      context.read<UserProvider>().updatePerson(person);
      context.read<TasksProvider>().updatePersonForTasks(person);
    });
  }
}
