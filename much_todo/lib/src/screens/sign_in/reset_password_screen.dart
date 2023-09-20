import 'package:flutter/material.dart';
import 'package:much_todo/src/screens/sign_in/login_header.dart';
import 'package:much_todo/src/services/auth_service.dart';
import 'package:much_todo/src/utils/themes.dart';
import 'package:much_todo/src/utils/utils.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? email;

  const ResetPasswordScreen({super.key, this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.email != null) {
      _emailController.text = widget.email!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context).height;
    return Theme(
      data: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  loginGradientColor1,
                  loginGradientColor2,
                ],
              ),
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              LoginHeader(size: size, offset: 0.3),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.email),
                                  border: OutlineInputBorder(),
                                  labelText: 'Email Address *',
                                ),
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                maxLines: 1,
                                validator: validEmail,
                                textInputAction: TextInputAction.next,
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
                                onPressed: resetPassword,
                                child: _isLoading
                                    ? const CircularProgressIndicator()
                                    : const Text('SEND RESET PASSWORD EMAIL'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> resetPassword() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      hideKeyboard();
      await AuthService.sendResetEmail(_emailController.text.trim());
      setState(() {
        _isLoading = false;
      });

      if (context.mounted) {
        showSnackbar('Reset email sent. Check your inbox.', context);
      }
    }
  }

  String? validEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }
}
