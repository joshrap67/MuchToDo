import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/utils/enums.dart';

class RoomsProvider with ChangeNotifier {
  List<Room> _rooms = [];
  bool _isLoading = true;
  RoomSortOption _sort = RoomSortOption.name;
  SortDirection _sortDirection = SortDirection.ascending;

  List<Room> get rooms => [..._rooms]; // spread since otherwise widgets could bypass mutation methods
  bool get isLoading => _isLoading;

  RoomSortOption get sort => _sort;

  SortDirection get sortDirection => _sortDirection;

  void setRooms(List<Room> rooms) {
    _rooms = rooms;
    sortRooms();
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

  void setSort(RoomSortOption sort, SortDirection sortDirection) {
    _sort = sort;
    _sortDirection = sortDirection;
    sortRooms();
  }

  void sortRooms() {
    // initially ascending
    switch (_sort) {
      case RoomSortOption.name:
        _rooms.sort((a, b) => a.name.compareTo(b.name));
        break;
      case RoomSortOption.taskCount:
        _rooms.sort((a, b) => a.tasks.length.compareTo(b.tasks.length));
        break;

      case RoomSortOption.creationDate:
        _rooms.sort((a, b) => a.creationDate.compareTo(b.creationDate));
        break;
      case RoomSortOption.totalCost:
        _rooms.sort((a, b) => a.totalCost().compareTo(b.totalCost()));
        break;
    }
    if (_sortDirection == SortDirection.descending) {
      for (var i = 0; i < _rooms.length / 2; i++) {
        var temp = _rooms[i];
        _rooms[i] = _rooms[_rooms.length - 1 - i];
        _rooms[_rooms.length - 1 - i] = temp;
      }
    }
    notifyListeners();
  }

  void addTask(Task createdTask) {
    var index = _rooms.indexWhere((element) => element.id == createdTask.room.id);
    if (index >= 0) {
      _rooms[index].tasks.add(createdTask.convert());
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
