import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/services/rooms_service.dart';
import 'package:much_todo/src/services/user_service.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/utils/validation.dart';
import 'package:provider/provider.dart';

class Dialogs {
  static Future<Tag?> promptAddTag(BuildContext context, String initialName) async {
    hideKeyboard();
    // todo max amount check
    final formKey = GlobalKey<FormState>();
    var isLoading = false;
    final nameController = TextEditingController(text: initialName); // shortcut for user
    var tag = await showDialog<Tag?>(
      context: context,
      barrierDismissible: !isLoading,
      builder: (ctx) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog.adaptive(
            actions: <Widget>[
              if (!isLoading)
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('CANCEL'),
                ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });

                    hideKeyboard();
                    var result = await UserService.createTag(context, nameController.text.trim());
                    setState(() {
                      isLoading = false;
                    });

                    if (dialogContext.mounted && result.success) {
                      Navigator.pop(dialogContext, result.data!);
                    } else if (dialogContext.mounted && result.failure) {
                      Navigator.pop(dialogContext, null);
                      showSnackbar(result.errorMessage!, context);
                    }
                  }
                },
                child: isLoading ? const CircularProgressIndicator() : const Text('CREATE'),
              )
            ],
            insetPadding: const EdgeInsets.all(8.0),
            title: const Text('New Tag'),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: TextFormField(
                  decoration: const InputDecoration(
                    label: Text('Tag name'),
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => validNewTag(val, context.read<UserProvider>().tags),
                  controller: nameController,
                ),
              ),
            ),
          );
        });
      },
    );
    return tag;
  }

  static Future<Contact?> promptAddContact(BuildContext context, String initialName) async {
    hideKeyboard();
    // todo max amount check
    final formKey = GlobalKey<FormState>();
    var isLoading = false;
    final nameController = TextEditingController(text: initialName); // shortcut for user
    final emailController = TextEditingController();
    final phoneNumberController = TextEditingController();
    var tag = await showDialog<Contact?>(
      context: context,
      barrierDismissible: !isLoading,
      builder: (ctx) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog.adaptive(
            actions: <Widget>[
              if (!isLoading)
                TextButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('CANCEL'),
                ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });

                    hideKeyboard();
                    var result = await UserService.createContact(
                        context, nameController.text, emailController.text, phoneNumberController.text);
                    setState(() {
                      isLoading = false;
                    });

                    if (dialogContext.mounted && result.success) {
                      Navigator.pop(dialogContext, result.data!);
                    } else if (dialogContext.mounted && result.failure) {
                      Navigator.pop(dialogContext, null);
                      showSnackbar(result.errorMessage!, context); // todo test
                    }
                  }
                },
                child: isLoading ? const CircularProgressIndicator() : const Text('CREATE'),
              )
            ],
            insetPadding: const EdgeInsets.all(8.0),
            title: const Text('New Contact'),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Name'),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.name,
                        controller: nameController,
                        validator: validContactName,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Email'),
                          border: OutlineInputBorder(),
                        ),
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: validContactEmail,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Phone Number'),
                          border: OutlineInputBorder(),
                        ),
                        controller: phoneNumberController,
                        keyboardType: TextInputType.phone,
                        validator: validContactPhoneNumber,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
    return tag;
  }

  static Future<Room?> promptAddRoom(BuildContext context, {String? initialName}) async {
    // todo max amount check
    final formKey = GlobalKey<FormState>();
    var isLoading = false;
    final nameController = TextEditingController(text: initialName);
    final noteController = TextEditingController();
    var room = await showDialog<Room?>(
      context: context,
      barrierDismissible: !isLoading,
      builder: (ctx) {
        return StatefulBuilder(builder: (dialogContext, setState) {
          return AlertDialog.adaptive(
            actions: <Widget>[
              if (!isLoading)
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, null),
                  child: const Text('CANCEL'),
                ),
              TextButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });

                    hideKeyboard();
                    var result = await RoomsService.createRoom(context, nameController.text, note: noteController.text);
                    setState(() {
                      isLoading = false;
                    });

                    if (dialogContext.mounted && result.success) {
                      Navigator.pop(dialogContext, result.data!);
                    } else if (dialogContext.mounted && result.failure) {
                      Navigator.pop(dialogContext, null);
                      showSnackbar(result.errorMessage!, context); // todo test
                    }
                  }
                },
                child: isLoading ? const CircularProgressIndicator() : const Text('CREATE'),
              )
            ],
            insetPadding: const EdgeInsets.all(8.0),
            title: const Text('New Room'),
            content: Form(
              key: formKey,
              child: SizedBox(
                width: MediaQuery.of(dialogContext).size.width,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Room name *'),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.name,
                      controller: nameController,
                      validator: validRoomName,
                    ),
                    const Padding(padding: EdgeInsets.all(8)),
                    TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Note'),
                        border: OutlineInputBorder(),
                      ),
                      controller: noteController,
                      validator: validRoomNote,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
    return room;
  }
}
