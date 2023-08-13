import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';

class RoomsService {
  static Future<Room> createRoom(BuildContext context, String name, {String? note}) async {
    Room? room;
    await Future.delayed(const Duration(seconds: 2), () {
      room = Room(const Uuid().v4(), name.trim(), note, []);
      context.read<RoomsProvider>().addRoom(room!);
    });
    return room!;
  }
}
