import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/home/home.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/repositories/exceptions/user_not_found_exception.dart';
import 'package:much_todo/src/repositories/rooms/requests/create_room_request.dart';
import 'package:much_todo/src/repositories/user/requests/create_user_request.dart';
import 'package:much_todo/src/repositories/user/requests/set_contact_request.dart';
import 'package:much_todo/src/repositories/user/requests/set_tag_request.dart';
import 'package:much_todo/src/repositories/user/user_repository.dart';
import 'package:much_todo/src/sign_in/create_account.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:much_todo/src/domain/contact.dart';

class UserService {
  static Future<void> loadUser(BuildContext context) async {
    try {
      context.read<UserProvider>().setLoading(true);
      var user = await UserRepository.getUser();
      if (context.mounted) {
        context.read<UserProvider>().setUser(user);
      }
    } on UserNotFoundException {
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, CreateAccountScreen.routeName, (route) => false);
      }
    } on Exception catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem loading user data', context);
      }
    } finally {
      if (context.mounted) {
        context.read<UserProvider>().setLoading(false);
      }
    }
  }

  static Future<void> createUser(BuildContext context, List<Room> rooms) async {
    try {
      await UserRepository.createUser(CreateUserRequest(rooms.map((e) => CreateRoomRequest(e.name, e.note)).toList()));
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, Home.routeName, (route) => false);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem creating the account', context);
      }
    }
  }

  static Future<void> deleteUser(BuildContext context) async {
    try {
      await UserRepository.deleteUser();
      if (context.mounted) {
        signOut(context);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem creating the account', context);
      }
    }
  }

  static Future<Tag?> createTag(BuildContext context, String name) async {
    Tag? tag;
    try {
      tag = await UserRepository.createTag(SetTagRequest(name));
      if (context.mounted) {
        context.read<UserProvider>().addTag(tag);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem creating the tag', context);
      }
    }
    return tag;
  }

  static Future<Contact?> createContact(BuildContext context, String name, String? email, String? number) async {
    Contact? contact;
    try {
      contact = await UserRepository.createContact(SetContactRequest(name, email, number));
      if (context.mounted) {
        context.read<UserProvider>().addContact(contact);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem creating the contact', context);
      }
    }

    return contact!;
  }

  static Future<void> deleteTag(BuildContext context, Tag tag) async {
    try {
      await UserRepository.deleteTag(tag.id);
      if (context.mounted) {
        context.read<UserProvider>().deleteTag(tag);
        context.read<TasksProvider>().removeTagFromTasks(tag);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem deleting the tag', context);
      }
    }
  }

  static Future<void> updateTag(BuildContext context, Tag tag) async {
    try {
      await UserRepository.updateTag(tag.id, SetTagRequest(tag.name));
      if (context.mounted) {
        context.read<UserProvider>().updateTag(tag);
        context.read<TasksProvider>().updateTagForTasks(tag);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem updating the tag', context);
      }
    }
  }

  static Future<void> deleteContact(BuildContext context, Contact contact) async {
    try {
      await UserRepository.deleteContact(contact.id);
      if (context.mounted) {
        context.read<UserProvider>().deleteContact(contact);
        context.read<TasksProvider>().removeContactFromTasks(contact);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem deleting the contact', context);
      }
    }
  }

  static Future<void> updateContact(BuildContext context, Contact contact) async {
    try {
      await UserRepository.updateContact(
          contact.id, SetContactRequest(contact.name, contact.email, contact.phoneNumber));
      if (context.mounted) {
        context.read<UserProvider>().updateContact(contact);
        context.read<TasksProvider>().updateContactForTasks(contact);
		showSnackbar('Contact updated.', context);
      }
    } catch (e) {
      if (context.mounted) {
        showSnackbar('There was a problem updating the contact', context);
      }
    }
  }

  static Future<void> signOut(BuildContext context) async {
    context.read<RoomsProvider>().clearRooms();
    context.read<TasksProvider>().clearTasks();
    context.read<UserProvider>().clearUser();
    await FirebaseAuth.instance.signOut();
  }
}
