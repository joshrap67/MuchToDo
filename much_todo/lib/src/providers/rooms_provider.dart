import 'package:flutter/material.dart';

import '../domain/room.dart';

class RoomsProvider with ChangeNotifier {
  static final List<Room> initialData = [
    Room('A', 'Bedroom', 'Note', []),
    Room('B', 'Bathroom', 'Note', []),
    Room('C', 'Kitchen', 'Note', []),
    Room('D', 'Unspecified Room', 'Note', []), // todo call it "No Room" and make it never be deletable? idk seems excessive
  ];
  final List<Room> _rooms = initialData;

  List<Room> get rooms => [..._rooms]; // spread since otherwise widgets could bypass mutation methods

  void addRoom(Room room) {
    _rooms.add(room);
    notifyListeners();
  }

  void removeRoom(Room room) {
    _rooms.removeWhere((r) => r.id == room.id);
    notifyListeners();
  }
}
