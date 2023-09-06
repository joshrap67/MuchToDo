import 'dart:convert';

import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/repositories/network/api_gateway.dart';
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
      throw Exception('There was a problem getting rooms. Result status ${apiResult.statusCode}');
    }
  }

  static Future<Room> createRoom(CreateRoomRequest request) async {
    final apiResult = await ApiGateway.post(basePath, request);
    if (apiResult.success) {
      var decodedJson = jsonDecode(apiResult.data);
      return Room.fromJson(decodedJson);
    } else {
      throw Exception('There was a problem creating the room. Result status ${apiResult.statusCode}');
    }
  }

  static Future<void> updateRoom(String roomId, UpdateRoomRequest request) async {
    final apiResult = await ApiGateway.put('$basePath/$roomId', request);
    if (!apiResult.success) {
      throw Exception('There was a problem updating the room. Result status ${apiResult.statusCode}');
    }
  }

  static Future<bool> deleteRoom(String roomId) async {
    final apiResult = await ApiGateway.delete('$basePath/$roomId');
    if (apiResult.success) {
      return true;
    } else {
      throw Exception('There was a problem deleting the room. Result status ${apiResult.statusCode}');
    }
  }
}
