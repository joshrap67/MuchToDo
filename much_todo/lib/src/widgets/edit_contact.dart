import 'package:flutter/material.dart';
import 'package:much_todo/src/domain/contact.dart';
import 'package:much_todo/src/services/user_service.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'loading_button.dart';

class EditContact extends StatefulWidget {
  final Contact contact;

  const EditContact({super.key, required this.contact});

  @override
  State<EditContact> createState() => _EditContactState();
}

class _EditContactState extends State<EditContact> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.contact.name;
    _emailController.text = widget.contact.email ?? '';
    _numberController.text = widget.contact.phoneNumber ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Contact'),
        scrolledUnderElevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                label: Text('Name'),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.name,
                              controller: _nameController,
                              validator: validName,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                label: Text('Email'),
                                border: OutlineInputBorder(),
                              ),
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: validEmail,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              decoration: const InputDecoration(
                                label: Text('Phone Number'),
                                border: OutlineInputBorder(),
                              ),
                              controller: _numberController,
                              keyboardType: TextInputType.phone,
                              validator: validPhoneNumber,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LoadingButton(onSubmit: onSubmit),
          )
        ],
      ),
    );
  }

  String? validName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? validEmail(String? email) {
    if (email == null || email.isEmpty) {
      return null;
    }
    return null;
  }

  String? validPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return null;
    }
    return null;
  }

  Future<void> onSubmit() async {
    if (_formKey.currentState!.validate()) {
      String email = _emailController.text.trim();
      String phone = _numberController.text.trim();
      hideKeyboard();

      Contact contact = Contact(widget.contact.id, _nameController.text.trim(), email.isNotEmpty ? email : null,
          phone.isNotEmpty ? phone : null);
      await UserService.updateContact(context, contact);
      if (context.mounted) {
        showSnackbar('Contact updated.', context);
      }
    }
  }
}
