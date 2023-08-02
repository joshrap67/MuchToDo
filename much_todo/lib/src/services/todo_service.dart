import 'package:image_picker/image_picker.dart';
import 'package:much_todo/src/domain/todo.dart';
import 'package:uuid/uuid.dart';

import '../domain/person.dart';
import '../domain/room.dart';
import '../domain/tag.dart';

class TodoService {
  static Todo createTodo(String name, int priority, int effort, String createdBy,
      {double? approximateCost,
      String? note,
      DateTime? completeBy,
      TodoRoom? room,
      List<String> links = const [],
      List<Tag> tags = const [],
      List<Person> people = const [],
      List<XFile> photos = const []}) {
    // upload photos to cloud
    var todo = Todo.named(
        id: const Uuid().v4(),
        name: name.trim(),
        priority: priority,
        effort: effort,
        createdBy: createdBy,
        tags: tags.map((e) => e.convert()).toList(),
        approximateCost: approximateCost,
        completeBy: completeBy,
        inProgress: false,
        isCompleted: false,
        links: links,
        note: note,
        people: people.map((e) => e.convert()).toList(),
        room: room,
        creationDate: DateTime.now().toUtc());

    return todo;
  }

  static Todo editTodo(String name, int priority, int effort, String createdBy,
	  {double? approximateCost,
		  String? note,
		  DateTime? completeBy,
		  Room? room,
		  List<String> links = const [],
		  List<Tag> tags = const [],
		  List<Person> people = const [],
		  List<XFile> photos = const []}) {
	  // upload photos to cloud
	  var todo = Todo.named(
		  id: const Uuid().v4(),
		  name: name.trim(),
		  priority: priority,
		  effort: effort,
		  createdBy: createdBy,
		  tags: tags.map((e) => e.convert()).toList(),
		  approximateCost: approximateCost,
		  completeBy: completeBy,
		  inProgress: false,
		  isCompleted: false,
		  links: links,
		  note: note,
		  people: people.map((e) => e.convert()).toList(),
		  room: room?.convert(),
		  creationDate: DateTime.now().toUtc());

	  return todo;
  }

  static List<Todo> createTodos(String name, int priority, int effort, String createdBy, List<Room> rooms,
      {double? approximateCost,
      String? note,
      DateTime? completeBy,
      List<String> links = const [],
      List<Tag> tags = const [],
      List<Person> people = const [],
      List<XFile> photos = const []}) {
    // todo upload photos to cloud
    List<Todo> createdTodos = [];
    if (rooms.isEmpty) {
      // empty room is allowed
      var todo = Todo.named(
          id: const Uuid().v4(),
          name: name.trim(),
          priority: priority,
          effort: effort,
          createdBy: createdBy,
          tags: tags.map((e) => e.convert()).toList(),
          approximateCost: approximateCost,
          completeBy: completeBy,
          inProgress: false,
          isCompleted: false,
          links: links,
          note: note,
          people: people.map((e) => e.convert()).toList(),
          room: null,
          creationDate: DateTime.now().toUtc());
      createdTodos.add(todo);
    }

    for (var room in rooms) {
      var todo = Todo.named(
          id: const Uuid().v4(),
          name: name.trim(),
          priority: priority,
          effort: effort,
          createdBy: createdBy,
          tags: tags.map((e) => e.convert()).toList(),
          approximateCost: approximateCost,
          completeBy: completeBy,
          inProgress: false,
          isCompleted: false,
          links: links,
          note: note,
          people: people.map((e) => e.convert()).toList(),
          room: room.convert(),
          creationDate: DateTime.now().toUtc());
      createdTodos.add(todo);
    }

    return createdTodos;
  }
}
