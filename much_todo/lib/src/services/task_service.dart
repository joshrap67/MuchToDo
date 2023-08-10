import 'package:image_picker/image_picker.dart';
import 'package:much_todo/src/domain/task.dart';
import 'package:uuid/uuid.dart';

import '../domain/person.dart';
import '../domain/room.dart';
import '../domain/tag.dart';

class TaskService {
  static Task createTask(String name, int priority, int effort, String createdBy, TaskRoom room,
      {double? estimatedCost,
      String? note,
      DateTime? completeBy,
      List<String> links = const [],
      List<Tag> tags = const [],
      List<Person> people = const [],
      List<XFile> photos = const []}) {
    // upload photos to cloud
    var task = Task.named(
        id: const Uuid().v4(),
        name: name.trim(),
        priority: priority,
        effort: effort,
        createdBy: createdBy,
        tags: tags.map((e) => e.convert()).toList(),
        estimatedCost: estimatedCost,
        completeBy: completeBy,
        inProgress: false,
        isCompleted: false,
        links: links,
        note: note,
        people: people.map((e) => e.convert()).toList(),
        room: room,
        creationDate: DateTime.now().toUtc());

    return task;
  }

  static Task editTask(String name, int priority, int effort, String createdBy, Room room,
      {double? estimatedCost,
      String? note,
      DateTime? completeBy,
      List<String> links = const [],
      List<Tag> tags = const [],
      List<Person> people = const [],
      List<XFile> photos = const []}) {
    // upload photos to cloud
    var task = Task.named(
        id: const Uuid().v4(),
        name: name.trim(),
        priority: priority,
        effort: effort,
        createdBy: createdBy,
        tags: tags.map((e) => e.convert()).toList(),
        estimatedCost: estimatedCost,
        completeBy: completeBy,
        inProgress: false,
        isCompleted: false,
        links: links,
        note: note,
        people: people.map((e) => e.convert()).toList(),
        room: room.convert(),
        creationDate: DateTime.now().toUtc());

    return task;
  }

  static List<Task> createTasks(String name, int priority, int effort, String createdBy, List<Room> rooms,
      {double? estimatedCost,
      String? note,
      DateTime? completeBy,
      List<String> links = const [],
      List<Tag> tags = const [],
      List<Person> people = const [],
      List<XFile> photos = const []}) {
    // todo upload photos to cloud
    List<Task> createdTasks = [];
    if (rooms.isEmpty) {
      throw Exception('Room cannot be empty');
    }

    for (var room in rooms) {
      var task = Task.named(
          id: const Uuid().v4(),
          name: name.trim(),
          priority: priority,
          effort: effort,
          createdBy: createdBy,
          tags: tags.map((e) => e.convert()).toList(),
          estimatedCost: estimatedCost,
          completeBy: completeBy,
          inProgress: false,
          isCompleted: false,
          links: links,
          note: note,
          people: people.map((e) => e.convert()).toList(),
          room: room.convert(),
          creationDate: DateTime.now().toUtc());
      createdTasks.add(task);
    }

    return createdTasks;
  }
}
