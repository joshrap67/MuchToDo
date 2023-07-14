import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/rooms/create_room.dart';
import 'package:uuid/uuid.dart';


class RoomList extends StatefulWidget {
  const RoomList({super.key});

  @override
  State<RoomList> createState() => _RoomListState();
}

class _RoomListState extends State<RoomList> {
  final List<Room> _rooms = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < 10; i++) {
      _rooms.add(Room(const Uuid().v4(), 'Room ${i + 1}', []));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          itemCount: _rooms.length,
          shrinkWrap: true,
          itemBuilder: (ctx, index) {
            var room = _rooms[index];
            return ListTile(
              title: Text(room.name),
              subtitle: Text('${room.todos.length} To Dos'),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.bottomRight,
            child: FloatingActionButton(
              onPressed: launchAddTodo,
              child: const Icon(Icons.add),
            ),
          ),
        )
      ],
    );
  }

  Future<void> launchAddTodo() async {
    var result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateRoom()),
    );
    if (result != null) {
      setState(() {
        _rooms.add(result);
      });
    }
  }
}
