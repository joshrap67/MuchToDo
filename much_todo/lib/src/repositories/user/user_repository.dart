import 'dart:convert';

import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/domain/user.dart';
import 'package:much_todo/src/repositories/api_gateway.dart';
import 'package:much_todo/src/repositories/exceptions/user_not_found_exception.dart';
import 'package:much_todo/src/repositories/user/requests/create_user_request.dart';
import 'package:much_todo/src/repositories/user/requests/set_contact_request.dart';
import 'package:much_todo/src/repositories/user/requests/set_tag_request.dart';

class UserRepository {
  static const basePath = 'users';

  static Future<User> getUser() async {
    // if user signs up via email, their email will stay unverified on token until it expires. so force a refresh
    final apiResult = await ApiGateway.get(basePath, forceTokenRefresh: true);
    if (apiResult.success) {
      var decodedUser = jsonDecode(apiResult.data);
      return User.fromJson(decodedUser);
    } else if (apiResult.statusCode == 404) {
      throw UserNotFoundException('User does not yet exist');
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<User> createUser(CreateUserRequest request) async {
    final apiResult = await ApiGateway.post(basePath, request);
    if (apiResult.success) {
      var decodedUser = jsonDecode(apiResult.data);
      return User.fromJson(decodedUser);
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<void> deleteUser() async {
    final apiResult = await ApiGateway.delete(basePath);
    if (!apiResult.success) {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<Tag> createTag(SetTagRequest request) async {
    final apiResult = await ApiGateway.post('$basePath/tags', request);
    if (apiResult.success) {
      var decodedTag = jsonDecode(apiResult.data);
      return Tag.fromJson(decodedTag);
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<void> updateTag(String tagId, SetTagRequest request) async {
    final apiResult = await ApiGateway.put('$basePath/tags/$tagId', body: request);
    if (!apiResult.success) {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<void> deleteTag(String tagId) async {
    final apiResult = await ApiGateway.delete('$basePath/tags/$tagId');
    if (!apiResult.success) {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<Contact> createContact(SetContactRequest request) async {
    final apiResult = await ApiGateway.post('$basePath/contacts', request);
    if (apiResult.success) {
      var decodedContact = jsonDecode(apiResult.data);
      return Contact.fromJson(decodedContact);
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<void> updateContact(String contactId, SetContactRequest request) async {
    final apiResult = await ApiGateway.put('$basePath/contacts/$contactId', body: request);
    if (!apiResult.success) {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<void> deleteContact(String contactId) async {
    final apiResult = await ApiGateway.delete('$basePath/contacts/$contactId');
    if (!apiResult.success) {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }
}
