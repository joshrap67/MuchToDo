import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/home/home.dart';
import 'package:much_todo/src/sign_in/auth_service.dart';
import 'package:much_todo/src/sign_in/login_header.dart';
import 'package:much_todo/src/sign_in/unverified_screen.dart';
import 'package:much_todo/src/utils/globals.dart';
import 'package:much_todo/src/utils/utils.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isSigningUp = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context).height;
    return Theme(
      data: ThemeData(
        useMaterial3: true,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          scrolledUnderElevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF9890e3),
                  Color(0xFF9ea7de),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            LoginHeader(size: size, offset: 0.2),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.email),
                                border: OutlineInputBorder(),
                                labelText: 'Email Address *',
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              maxLines: 1,
                              validator: validEmail,
                              textInputAction: TextInputAction.next,
                            ),
                            const Padding(padding: EdgeInsets.all(8)),
                            TextFormField(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                border: const OutlineInputBorder(),
                                labelText: 'Password *',
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _hidePassword = !_hidePassword;
                                      });
                                    },
                                    child: Icon(
                                      _hidePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              controller: _passwordController,
                              obscureText: _hidePassword,
                              maxLines: 1,
                              validator: validPassword,
                              textInputAction: TextInputAction.next,
                              onFieldSubmitted: (_) => signUp(),
                            ),
                            const Padding(padding: EdgeInsets.all(8)),
                            TextFormField(
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                border: const OutlineInputBorder(),
                                labelText: 'Confirm Password *',
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _hideConfirmPassword = !_hideConfirmPassword;
                                      });
                                    },
                                    child: Icon(
                                      _hideConfirmPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ),
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              controller: _passwordConfirmController,
                              obscureText: _hideConfirmPassword,
                              maxLines: 1,
                              validator: validConfirmPassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => signUp(),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                                    child: ElevatedButton(
                                      onPressed: signUp,
                                      child: _isSigningUp ? const CircularProgressIndicator() : const Text('SIGN UP'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? validEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? validPassword(String? password) {
    String msg = '';
    if (password == null || password.trim().isEmpty) {
      return msg += 'Required';
    }
    if (password.length < Constants.minimumPasswordLength) {
      msg += 'Password must be at least ${Constants.minimumPasswordLength} characters\n';
    }
    if (password.isNotEmpty &&
        _passwordConfirmController.text.isNotEmpty &&
        _passwordConfirmController.text != password) {
      msg += 'Passwords must match\n';
    }
    msg = msg.trim();

    return msg.isEmpty ? null : msg;
  }

  String? validConfirmPassword(String? password) {
    String msg = '';
    if (password == null || password.trim().isEmpty) {
      return msg += 'Required';
    }
    if (password.length < Constants.minimumPasswordLength) {
      msg += 'Password must be at least ${Constants.minimumPasswordLength} characters\n';
    }
    if (password.isNotEmpty && _passwordController.text.isNotEmpty && _passwordController.text != password) {
      msg += 'Passwords must match\n';
    }
    msg = msg.trim();

    return msg.isEmpty ? null : msg;
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSigningUp = true;
    });
    var signedUp =
        await AuthService.signUpWithEmailAndPassword(_emailController.text.trim(), _passwordController.text.trim());
    setState(() {
      _isSigningUp = false;
    });
    if (signedUp) {
      if (FirebaseAuth.instance.currentUser!.emailVerified && context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, Home.routeName, (route) => false);
      } else if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, UnverifiedScreen.routeName, (route) => false);
      }
    } else if (context.mounted) {
      showSnackbar('Unable to sign up', context);
    }
  }
}
