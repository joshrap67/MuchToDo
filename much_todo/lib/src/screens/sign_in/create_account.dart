import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/screens/sign_in/create_account_room_info_card.dart';
import 'package:much_todo/src/screens/sign_in/sign_in_screen.dart';
import 'package:much_todo/src/services/user_service.dart';
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
  bool _isSigningOut = false;
  bool _isCreatingAccount = false;
  final nameController = TextEditingController();
  final noteController = TextEditingController();
  final List<Room> _rooms = [];

  @override
  void initState() {
    super.initState();
    _rooms.add(Room(const Uuid().v4(), 'Unspecified Room', null, []));
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
              '\n\nRooms can be as broad as you want them to be. They can be outside, inside, small or large. When you create a task, you always associate it with a room.',
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
                return CreateAccountRoomInfoCard(
                  room: room,
                  delete: () => deleteRoom(room),
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
                        onPressed: createAccount,
                        child: _isCreatingAccount ? const CircularProgressIndicator() : const Text('CREATE ACCOUNT'),
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
                  const Text("OR"),
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
    await UserService.createUser(context, _rooms);
    setState(() {
      _isCreatingAccount = false;
    });
  }

  void launchAddRoom() {
    // todo max amount check
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
            title: const Text('Create Room'),
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
        }).then(
      (value) {
        nameController.clear();
        noteController.clear();
      },
    );
  }
}
