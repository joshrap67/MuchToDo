import 'package:flutter/material.dart';
import 'package:much_todo/src/services/user_service.dart';

import '../utils/utils.dart';
import 'loading_button.dart';

class CreatePerson extends StatefulWidget {
  final String? name;

  const CreatePerson({super.key, this.name});

  @override
  State<CreatePerson> createState() => _CreatePersonState();
}

class _CreatePersonState extends State<CreatePerson> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.name != null) {
      _nameController.text = widget.name!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Person'),
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
                          )
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
            child: LoadingButton(
              onSubmit: onSubmit,
              label: 'CREATE',
              icon: const Icon(Icons.add),
            ),
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
      var person = await UserService.createPerson(
          context, _nameController.text.trim(), email.isNotEmpty ? email : null, phone.isNotEmpty ? phone : null);
      hideKeyboard();
      if (context.mounted) {
        Navigator.pop(context, person);
      }
    }
  }
}
