import 'dart:convert';

import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/domain/user.dart';
import 'package:much_todo/src/network/api_gateway.dart';
import 'package:much_todo/src/repositories/exceptions/user_not_found_exception.dart';
import 'package:much_todo/src/repositories/user/requests/set_contact_request.dart';
import 'package:much_todo/src/repositories/user/requests/set_tag_request.dart';
import 'package:much_todo/src/repositories/user/requests/create_user_request.dart';

class UserRepository {
  static const basePath = '/users';

  static Future<User> getUser() async {
    final apiResult = await ApiGateway.get(basePath);
    if (apiResult.success) {
      var decodedUser = jsonDecode(apiResult.data);
      return User.fromJson(decodedUser);
    } else if (apiResult.statusCode == 404) {
      throw UserNotFoundException('User does not yet exist. Re-routing...');
    } else {
      throw Exception('There was a problem getting the user.');
    }
  }

  static Future<User> createUser(CreateUserRequest request) async {
	  print(request);
    final apiResult = await ApiGateway.post(basePath, request);
    if (apiResult.success) {
      var decodedUser = jsonDecode(apiResult.data);
      return User.fromJson(decodedUser);
    } else {
      throw Exception('There was a problem creating the user.');
    }
  }

  static Future<Tag> createTag(SetTagRequest request) async {
    final apiResult = await ApiGateway.post('$basePath/tags', request);
    if (apiResult.success) {
      var decodedTag = jsonDecode(apiResult.data);
      return Tag.fromJson(decodedTag);
    } else {
      throw Exception('There was a problem creating the tag.');
    }
  }

  static Future<void> updateTag(String tagId, SetTagRequest request) async {
    final apiResult = await ApiGateway.put('$basePath/tags/$tagId', request);
    if (!apiResult.success) {
      throw Exception('There was a problem updating the tag.');
    }
  }

  static Future<void> deleteTag(String tagId) async {
    final apiResult = await ApiGateway.delete('$basePath/tags/$tagId');
    if (!apiResult.success) {
      throw Exception('There was a problem deleting the tag.');
    }
  }

  static Future<Contact> createContact(SetContactRequest request) async {
    final apiResult = await ApiGateway.post('$basePath/contacts', request);
    if (apiResult.success) {
      var decodedContact = jsonDecode(apiResult.data);
      return Contact.fromJson(decodedContact);
    } else {
      throw Exception('There was a problem creating the contact.');
    }
  }

  static Future<void> updateContact(String contactId, SetContactRequest request) async {
    final apiResult = await ApiGateway.put('$basePath/contacts/$contactId', request);
    if (!apiResult.success) {
      throw Exception('There was a problem updating the contact.');
    }
  }

  static Future<void> deleteContact(String contactId) async {
    final apiResult = await ApiGateway.delete('$basePath/contacts/$contactId');
    if (!apiResult.success) {
      throw Exception('There was a problem deleting the contact.');
    }
  }
}
