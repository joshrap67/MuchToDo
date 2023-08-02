import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../providers/rooms_provider.dart';

class RoomsService {
  static Future<Room> createRoom(BuildContext context, String name) async {
    Room? room;
    await Future.delayed(const Duration(seconds: 2), () {
      room = Room(const Uuid().v4(), name.trim(), []);
      context.read<RoomsProvider>().addRoom(room!);
    });
    return room!;
  }
}
