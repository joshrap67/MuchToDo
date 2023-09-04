import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/providers/tasks_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/repositories/exceptions/user_not_found_exception.dart';
import 'package:much_todo/src/repositories/rooms/requests/create_room_request.dart';
import 'package:much_todo/src/repositories/user/requests/create_user_request.dart';
import 'package:much_todo/src/repositories/user/requests/set_contact_request.dart';
import 'package:much_todo/src/repositories/user/requests/set_tag_request.dart';
import 'package:much_todo/src/repositories/user/user_repository.dart';
import 'package:much_todo/src/screens/sign_in/create_account.dart';
import 'package:much_todo/src/utils/result.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:much_todo/src/domain/contact.dart';

class UserService {
  static Future<void> loadUserBlindSend(BuildContext context) async {
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
    } on Exception {
      if (context.mounted) {
        showSnackbar('There was a problem loading user data', context);
      }
    } finally {
      if (context.mounted) {
        context.read<UserProvider>().setLoading(false);
      }
    }
  }

  static Future<Result<void>> createUser(List<Room> rooms) async {
    var result = Result();
    try {
      await UserRepository.createUser(
          CreateUserRequest(rooms.map((e) => CreateRoomRequest(e.name.trim(), e.note?.trim())).toList()));
    } catch (e) {
      result.setErrorMessage('There was a problem creating the account');
    }
    return result;
  }

  static Future<Result<void>> deleteUser(BuildContext context) async {
    var result = Result();
    try {
      await UserRepository.deleteUser();
      if (context.mounted) {
        await signOut(context);
      }
    } catch (e) {
      result.setErrorMessage('There was a problem creating the account');
    }
    return result;
  }

  static Future<Result<Tag>> createTag(BuildContext context, String name) async {
    var result = Result<Tag>();
    try {
      var tag = await UserRepository.createTag(SetTagRequest(name.trim()));
      result.setData(tag);
      if (context.mounted) {
        context.read<UserProvider>().addTag(tag);
      }
    } catch (e) {
      result.setErrorMessage('There was a problem creating the tag');
    }
    return result;
  }

  static Future<Result<Contact>> createContact(BuildContext context, String name, String? email, String? number) async {
    var result = Result<Contact>();
    try {
      var contact = await UserRepository.createContact(SetContactRequest(name.trim(), email?.trim(), number?.trim()));
      result.setData(contact);
      if (context.mounted) {
        context.read<UserProvider>().addContact(contact);
      }
    } catch (e) {
      result.setErrorMessage('There was a problem creating the contact');
    }

    return result;
  }

  static Future<Result<void>> deleteTag(BuildContext context, Tag tag) async {
    var result = Result();
    try {
      await UserRepository.deleteTag(tag.id);
      if (context.mounted) {
        context.read<UserProvider>().deleteTag(tag);
        context.read<TasksProvider>().removeTagFromTasks(tag);
      }
    } catch (e) {
      result.setErrorMessage('There was a problem deleting the tag');
    }
    return result;
  }

  static Future<Result<void>> updateTag(BuildContext context, String id, String newName) async {
    var result = Result();
    try {
      await UserRepository.updateTag(id, SetTagRequest(newName.trim()));
      if (context.mounted) {
        context.read<UserProvider>().updateTag(id, newName);
        context.read<TasksProvider>().updateTagForTasks(id, newName);
      }
    } catch (e) {
      result.setErrorMessage('There was a problem updating the tag');
    }
    return result;
  }

  static Future<Result<void>> deleteContact(BuildContext context, Contact contact) async {
    var result = Result();
    try {
      await UserRepository.deleteContact(contact.id);
      if (context.mounted) {
        context.read<UserProvider>().deleteContact(contact);
        context.read<TasksProvider>().removeContactFromTasks(contact);
      }
    } catch (e) {
      result.setErrorMessage('There was a problem deleting the contact');
    }
    return result;
  }

  static Future<Result<void>> updateContact(
      BuildContext context, String id, String name, String? email, String? phoneNumber) async {
    var result = Result();
    try {
      await UserRepository.updateContact(id, SetContactRequest(name.trim(), email?.trim(), phoneNumber?.trim()));
      if (context.mounted) {
        context.read<UserProvider>().updateContact(id, name, email, phoneNumber);
        context.read<TasksProvider>().updateContactForTasks(id, name, email, phoneNumber);
      }
    } catch (e) {
      result.setErrorMessage('There was a problem updating the contact');
    }
    return result;
  }

  static Future<Result<void>> signOut(BuildContext context) async {
    var result = Result();

    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        context.read<RoomsProvider>().clearRooms();
        context.read<TasksProvider>().clearTasks();
        context.read<UserProvider>().clearUser();
      }
    } catch (e) {
      result.setErrorMessage('There was a problem signing out');
    }
    return result;
  }
}
