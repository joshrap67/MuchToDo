import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/room.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/providers/rooms_provider.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/services/rooms_service.dart';
import 'package:much_todo/src/services/user_service.dart';
import 'package:much_todo/src/utils/constants.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/utils/validation.dart';
import 'package:provider/provider.dart';

class Dialogs {
  static Future<Tag?> promptAddTag(BuildContext context, String initialName) async {
    hideKeyboard();
    if (context.read<UserProvider>().tags.length > Constants.maxTags) {
      showSnackbar('Cannot have more than ${Constants.maxTags} tags', context);
      return null;
    }

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
                    label: Text('Tag Name *'),
                    border: OutlineInputBorder(),
                    counterText: '',
                  ),
                  maxLength: Constants.maxTagName,
                  keyboardType: TextInputType.name,
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
    if (context.read<UserProvider>().contacts.length > Constants.maxContacts) {
      showSnackbar('Cannot have more than ${Constants.maxContacts} contacts', context);
      return null;
    }

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
                      showSnackbar(result.errorMessage!, context);
                    }
                  }
                },
                child: isLoading ? const CircularProgressIndicator() : const Text('CREATE'),
              )
            ],
            insetPadding: const EdgeInsets.all(8.0),
            title: const Text('New Contact'),
            content: SingleChildScrollView(
              child: Form(
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
                            label: Text('Name *'),
                            border: OutlineInputBorder(),
                            counterText: '',
                          ),
                          maxLength: Constants.maxContactName,
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
                            counterText: '',
                          ),
                          maxLength: Constants.maxEmailLength,
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
                            counterText: '',
                          ),
                          maxLength: Constants.maxPhoneLength,
                          controller: phoneNumberController,
                          keyboardType: TextInputType.phone,
                          validator: validContactPhoneNumber,
                        ),
                      )
                    ],
                  ),
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
    if (context.read<RoomsProvider>().rooms.length > Constants.maxRooms) {
      showSnackbar('Cannot have more than ${Constants.maxRooms} rooms', context);
      return null;
    }

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
                      showSnackbar(result.errorMessage!, context);
                    }
                  }
                },
                child: isLoading ? const CircularProgressIndicator() : const Text('CREATE'),
              )
            ],
            insetPadding: const EdgeInsets.all(8.0),
            title: const Text('New Room'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: SizedBox(
                  width: MediaQuery.of(dialogContext).size.width,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Room Name *'),
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
                        textCapitalization: TextCapitalization.sentences,
                        controller: noteController,
                        validator: validRoomNote,
                      ),
                    ],
                  ),
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
