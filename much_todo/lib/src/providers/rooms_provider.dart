import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/utils/globals.dart';

class RoomsProvider with ChangeNotifier {
  List<Room> _rooms = [];
  bool _isLoading = true;

  List<Room> get rooms => [..._rooms]; // spread since otherwise widgets could bypass mutation methods
  bool get isLoading => _isLoading;

  void setRooms(List<Room> rooms) {
    _rooms = rooms;
    notifyListeners(); // todo sort too?
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

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
      case RoomSortingValues.taskCountAscending:
        _rooms.sort((a, b) => a.tasks.length.compareTo(b.tasks.length));
        break;
      case RoomSortingValues.taskCountDescending:
        _rooms.sort((a, b) => b.tasks.length.compareTo(a.tasks.length));
        break;
      case RoomSortingValues.estimateCostAscending:
        _rooms.sort((a, b) => a.totalCost().compareTo(b.totalCost()));
        break;
      case RoomSortingValues.estimatedCostDescending:
        _rooms.sort((a, b) => b.totalCost().compareTo(a.totalCost()));
        break;
    }
    notifyListeners();
  }

  void updateTask(Task updatedTask, String oldRoomId) {
    // task changed room, need to remove this task from the old room
    var oldRoom = _rooms.firstWhere((r) => r.id == oldRoomId);
    oldRoom.tasks.removeWhere((t) => t.id == updatedTask.id);

    var newRoom = _rooms.firstWhere((r) => r.id == updatedTask.room.id);
    newRoom.tasks.add(updatedTask.convert());
    notifyListeners();
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

  void clearRooms() {
    _rooms = [];
    notifyListeners();
  }
}
