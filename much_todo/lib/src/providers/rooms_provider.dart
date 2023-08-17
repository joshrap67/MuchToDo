import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/utils/globals.dart';

class RoomsProvider with ChangeNotifier {
  static final List<Room> initialData = [
    Room('A', 'Bedroom', 'Note', []),
    Room('B', 'Bathroom', 'Note', []),
    Room('C', 'Kitchen', 'Note', []),
    Room('D', 'Unspecified Room', 'Note', []),
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

  Room? updateRoom(String id, String name, String? note) {
    Room? room;
    var index = _rooms.indexWhere((element) => element.id == id);
    if (index >= 0) {
      _rooms[index].update(name, note);
      room = _rooms[index];
      notifyListeners();
    }
    return room;
  }

  void sortRooms(RoomSortingValues sort) {
    switch (sort) {
      case RoomSortingValues.alphaAscending:
        _rooms.sort((a, b) => a.name.compareTo(b.name));
        break;
      case RoomSortingValues.alphaDescending:
        _rooms.sort((a, b) => b.name.compareTo(a.name));
        break;
    }
    notifyListeners();
  }

  void updateTask(Task task) {
    for (var room in _rooms) {
      for (var roomTask in room.tasks) {
        if (roomTask.id == task.id) {
          roomTask.update(task.name, task.estimatedCost);
          notifyListeners();
          return;
        }
      }
    }
  }

  void addTasks(List<Task> createdTasks) {
    Map<String, Task> roomIdToTask = {};
    for (var task in createdTasks) {
      roomIdToTask[task.room.id] = task;
    }
    for (var room in _rooms) {
      if (roomIdToTask.containsKey(room.id)) {
        room.tasks.add(roomIdToTask[room.id]!.convert());
      }
    }
    notifyListeners();
  }

  void removeTask(Task task) {
    for (var room in _rooms) {
      room.tasks.removeWhere((element) => element.id == task.id);
    }
    notifyListeners();
  }
}
