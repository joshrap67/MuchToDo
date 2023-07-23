import 'package:flutter/material.dart';

import '../domain/professional.dart';
import '../utils/utils.dart';
import '../widgets/loading_button.dart';

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
                              validator: validEmail, // todo
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
                              validator: validPhoneNumber, // todo
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
    // todo check other people names
    return null;
  }

  String? validEmail(String? email) {
	  if (email == null || email.isEmpty) {
		  return null;
	  }
	  // todo check valid?
	  return null;
  }

  String? validPhoneNumber(String? phoneNumber) {
	  if (phoneNumber == null || phoneNumber.isEmpty) {
		  return null;
	  }
	  // todo check valid?
	  return null;
  }

  Future<void> onSubmit() async {
    if (_formKey.currentState!.validate()) {
      await Future.delayed(const Duration(seconds: 5), () {
        var room = Professional(_nameController.text, _emailController.text, _numberController.text);
        hideKeyboard();
        Navigator.pop(context, room);
      });
    }
  }
}
