import 'package:flutter/material.dart';
import 'package:much_todo/src/services/user_service.dart';
import 'package:much_todo/src/utils/utils.dart';
import 'package:much_todo/src/utils/validation.dart';
import 'loading_button.dart';

class CreateContact extends StatefulWidget {
  final String? name;

  const CreateContact({super.key, this.name});

  @override
  State<CreateContact> createState() => _CreateContactState();
}

class _CreateContactState extends State<CreateContact> {
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
        title: const Text('Create Contact'),
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
                              controller: _emailController,
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
                              controller: _numberController,
                              keyboardType: TextInputType.phone,
                              validator: validContactPhoneNumber,
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

  Future<void> onSubmit() async {
    if (_formKey.currentState!.validate()) {
      hideKeyboard();
      String email = _emailController.text.trim();
      String phone = _numberController.text.trim();
      var contact = await UserService.createContact(
          context, _nameController.text.trim(), email.isNotEmpty ? email : null, phone.isNotEmpty ? phone : null);

      if (context.mounted) {
        Navigator.pop(context, contact);
      }
    }
  }
}
