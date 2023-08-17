import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:much_todo/src/domain/contact.dart';

class UserService {
  static Future<Tag> createTag(BuildContext context, String name) async {
    Tag? tag;
    tag = Tag(const Uuid().v4(), name);
    await Future.delayed(const Duration(seconds: 2), () {
      context.read<UserProvider>().addTag(tag!);
    });
    return tag;
  }

  static Future<Contact> createContact(BuildContext context, String name, String? email, String? number) async {
    Contact? contact;
    await Future.delayed(const Duration(seconds: 2), () {
      contact = Contact(const Uuid().v4(), name, email, number);
      context.read<UserProvider>().addContact(contact!);
    });

    return contact!;
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

  static Future<void> deleteContact(BuildContext context, Contact contact) async {
    await Future.delayed(const Duration(seconds: 2), () {
      context.read<UserProvider>().deleteContact(contact);
      context.read<TasksProvider>().removeContactFromTasks(contact);
    });
  }

  static Future<void> updateContact(BuildContext context, Contact contact) async {
    await Future.delayed(const Duration(seconds: 2), () {
      context.read<UserProvider>().updateContact(contact);
      context.read<TasksProvider>().updateContactForTasks(contact);
    });
  }
}
