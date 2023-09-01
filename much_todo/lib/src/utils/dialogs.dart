import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/domain/tag.dart';
import 'package:much_todo/src/providers/user_provider.dart';
import 'package:much_todo/src/services/user_service.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/utils/validation.dart';
import 'package:provider/provider.dart';

class Dialogs {
  static Future<Tag?> promptAddTag(BuildContext context, String initialName) async {
    hideKeyboard();
    // todo max amount check
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
    final nameController = TextEditingController(text: initialName); // shortcut for user
    var tag = await showDialog<Tag?>(
        context: context,
        barrierDismissible: !isLoading,
        builder: (ctx) {
          return StatefulBuilder(builder: (dialogContext, setState) {
            return AlertDialog.adaptive(
              actions: <Widget>[
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
                      var tag = await _addTag(context, nameController.text);
                      setState(() {
                        isLoading = false;
                      });
                      if (context.mounted) {
                        Navigator.pop(context, tag);
                      }
                    }
                  },
                  child: isLoading ? const CircularProgressIndicator() : const Text('CREATE'),
                )
              ],
              insetPadding: const EdgeInsets.all(8.0),
              title: const Text('Create Tag'),
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
        });
    return tag;
  }

  static Future<Contact?> promptAddContact(BuildContext context, String initialName) async {
    hideKeyboard();
    // todo max amount check
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;
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
                      var tag = await _addContact(
                          context, nameController.text, emailController.text, phoneNumberController.text);
                      setState(() {
                        isLoading = false;
                      });
                      if (context.mounted) {
                        Navigator.pop(context, tag);
                      }
                    }
                  },
                  child: isLoading ? const CircularProgressIndicator() : const Text('CREATE'),
                )
              ],
              insetPadding: const EdgeInsets.all(8.0),
              title: const Text('Create Contact'),
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
        });
    return tag;
  }

  static Future<Tag?> _addTag(BuildContext context, String text) async {
    var tag = await UserService.createTag(context, text);
    return tag;
  }

  static Future<Contact?> _addContact(BuildContext context, String name, String email, String phoneNumber) async {
    var contact = await UserService.createContact(context, name, email, phoneNumber);
    return contact;
  }
}
