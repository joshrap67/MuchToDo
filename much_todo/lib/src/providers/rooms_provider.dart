import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:much_todo/src/utils/enums.dart';
import 'package:much_todo/src/utils/utils.dart';

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
    sortRoomsAndNotify();
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

  void updateRoom(String id, String name, String? note) {
    var index = _rooms.indexWhere((element) => element.id == id);
    if (index >= 0) {
      _rooms[index].update(name, note);
      notifyListeners();
    }
  }

  void setRoomIsFavorite(String id, bool isFavorite) {
    var index = _rooms.indexWhere((element) => element.id == id);
    if (index >= 0) {
      _rooms[index].isFavorite = isFavorite;
    }
  }

  void setRoomTaskSort(String id, int taskSort, int taskSortDirection) {
    var index = _rooms.indexWhere((element) => element.id == id);
    if (index >= 0) {
      _rooms[index].taskSort = taskSort;
      _rooms[index].taskSortDirection = taskSortDirection;
    }
  }

  void setSort(RoomSortOption sort, SortDirection sortDirection) {
    _sort = sort;
    _sortDirection = sortDirection;
    sortRoomsAndNotify();
  }

  void sortRoomsAndNotify() {
    // first sort by favorites, then by option
    switch (_sort) {
      case RoomSortOption.name:
        _rooms.sort((a, b) {
          var sortByFavorite = compareToBool(a.isFavorite, b.isFavorite);
          if (sortByFavorite == 0) {
            return a.name.toLowerCase().compareTo(b.name.toLowerCase()) *
                (_sortDirection == SortDirection.descending ? -1 : 1);
          }
          return sortByFavorite;
        });
        break;
      case RoomSortOption.taskCount:
        _rooms.sort((a, b) {
          var sortByFavorite = compareToBool(a.isFavorite, b.isFavorite);
          if (sortByFavorite == 0) {
            return a.tasks.length.compareTo(b.tasks.length) * (_sortDirection == SortDirection.descending ? -1 : 1);
          }
          return sortByFavorite;
        });
        break;
      case RoomSortOption.creationDate:
        _rooms.sort((a, b) {
          var sortByFavorite = compareToBool(a.isFavorite, b.isFavorite);
          if (sortByFavorite == 0) {
            return a.creationDate.compareTo(b.creationDate) * (_sortDirection == SortDirection.descending ? -1 : 1);
          }
          return sortByFavorite;
        });
        break;
      case RoomSortOption.totalCost:
        _rooms.sort((a, b) {
          var sortByFavorite = compareToBool(a.isFavorite, b.isFavorite);
          if (sortByFavorite == 0) {
            return a.totalCost().compareTo(b.totalCost()) * (_sortDirection == SortDirection.descending ? -1 : 1);
          }
          return sortByFavorite;
        });
        break;
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
