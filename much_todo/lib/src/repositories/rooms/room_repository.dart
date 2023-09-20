import 'dart:convert';

import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/repositories/api_gateway.dart';
import 'package:much_todo/src/repositories/rooms/requests/create_room_request.dart';
import 'package:much_todo/src/repositories/rooms/requests/update_room_request.dart';

class RoomRepository {
  static const basePath = 'rooms';

  static Future<List<Room>> getAllRoomsByUser() async {
    final apiResult = await ApiGateway.get(basePath, forceTokenRefresh: true);
    if (apiResult.success) {
      var rooms = <Room>[];
      var decodedJsonList = jsonDecode(apiResult.data);
      for (var jsonRoom in decodedJsonList) {
        rooms.add(Room.fromJson(jsonRoom));
      }
      return rooms;
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<Room> createRoom(CreateRoomRequest request) async {
    final apiResult = await ApiGateway.post(basePath, request);
    if (apiResult.success) {
      var decodedJson = jsonDecode(apiResult.data);
      return Room.fromJson(decodedJson);
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<void> updateRoom(String roomId, UpdateRoomRequest request) async {
    final apiResult = await ApiGateway.put('$basePath/$roomId', body: request);
    if (!apiResult.success) {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<void> favoriteRoom(String roomId) async {
    final apiResult = await ApiGateway.put('$basePath/$roomId/favorite');
    if (!apiResult.success) {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<void> unfavoriteRoom(String roomId) async {
    final apiResult = await ApiGateway.put('$basePath/$roomId/unfavorite');
    if (!apiResult.success) {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }

  static Future<bool> deleteRoom(String roomId) async {
    final apiResult = await ApiGateway.delete('$basePath/$roomId');
    if (apiResult.success) {
      return true;
    } else {
      throw Exception('Status ${apiResult.statusCode}, message: ${apiResult.data}');
    }
  }
}
