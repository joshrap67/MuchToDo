import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/screens/home/home.dart';
import 'package:much_todo/src/screens/sign_in/sign_in_screen.dart';
import 'package:much_todo/src/services/user_service.dart';
import 'package:much_todo/src/utils/constants.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/utils/validation.dart';
import 'package:uuid/uuid.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  static const routeName = '/create-account';

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final nameController = TextEditingController();
  final noteController = TextEditingController();
  final List<Room> _rooms = [];
  bool _isSigningOut = false;
  bool _isCreatingAccount = false;

  @override
  void initState() {
    super.initState();
    _rooms.add(Room(const Uuid().v4(), 'Miscellaneous Room', null, []));
  }

  @override
  void dispose() {
    nameController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finish Account Setup'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'To complete setting up your Much To Do account, add some rooms!'
              '\n\nRooms can be as broad as you want them to be. They can be outside, inside, small or large. When you create a task you will always associate it with a room.',
              textAlign: TextAlign.start,
            ),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                  child: ElevatedButton.icon(
                    onPressed: launchAddRoom,
                    icon: const Icon(Icons.add),
                    label: const Text('ADD ROOM'),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _rooms.length,
              padding: const EdgeInsets.only(bottom: 65),
              itemBuilder: (ctx, index) {
                var room = _rooms[index];
                return Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        title: Text(room.name),
                        subtitle: Text(
                          getSubtitle(room),
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => deleteRoom(room),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          disabledBackgroundColor: Theme.of(context).colorScheme.primary,
                          disabledForegroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: createAccount,
                        child: _isCreatingAccount
                            ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary)
                            : const Text('CREATE ACCOUNT'),
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                      child: const Divider(
                        height: 36,
                      ),
                    ),
                  ),
                  const Text('OR'),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                      child: const Divider(
                        height: 36,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                      child: ElevatedButton(
                        onPressed: signOut,
                        child: _isSigningOut ? const CircularProgressIndicator() : const Text('SIGN OUT'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getSubtitle(Room room) {
    return room.note == null || room.note!.isEmpty ? '' : '${room.note}';
  }

  void deleteRoom(Room room) {
    _rooms.removeWhere((element) => element.id == room.id);
    setState(() {});
  }

  Future<void> signOut() async {
    setState(() {
      _isSigningOut = true;
    });

    await FirebaseAuth.instance.signOut();
    setState(() {
      _isSigningOut = false;
    });

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, SignInScreen.routeName, (route) => false);
    }
  }

  void addRoom(Room room) {
    _rooms.add(room);
    setState(() {});
  }

  Future<void> createAccount() async {
    setState(() {
      _isCreatingAccount = true;
    });

    var result = await UserService.createUser(_rooms);
    setState(() {
      _isCreatingAccount = false;
    });

    if (context.mounted && result.success) {
      Navigator.pushNamedAndRemoveUntil(context, Home.routeName, (route) => false);
    } else if (context.mounted && result.failure) {
      showSnackbar(result.errorMessage!, context);
    }
  }

  void launchAddRoom() {
    if (_rooms.length > Constants.maxRooms) {
      showSnackbar('Cannot have more than ${Constants.maxRooms} rooms', context);
      return;
    }
    final formKey = GlobalKey<FormState>();
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog.adaptive(
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(context, 'OK');
                  hideKeyboard();
                  addRoom(
                    Room(
                      const Uuid().v4(),
                      nameController.text.trim(),
                      noteController.text.isNotEmpty ? noteController.text.trim() : null,
                      [],
                    ),
                  );
                }
              },
              child: const Text('CREATE'),
            )
          ],
          insetPadding: const EdgeInsets.all(8.0),
          title: const Text('New Room'),
          content: Form(
            key: formKey,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text('Room name *'),
                      border: OutlineInputBorder(),
                    ),
                    validator: validRoomName,
                    keyboardType: TextInputType.name,
                    controller: nameController,
                  ),
                  const Padding(padding: EdgeInsets.all(8)),
                  TextFormField(
                    decoration: const InputDecoration(
                      label: Text('Note'),
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => validRoomNote(val),
                    controller: noteController,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
