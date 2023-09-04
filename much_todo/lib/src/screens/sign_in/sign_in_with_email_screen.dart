import 'package:flutter/material.dart';
import 'package:much_todo/src/screens/home/home.dart';
import 'package:much_todo/src/services/auth_service.dart';
import 'package:much_todo/src/screens/sign_in/login_header.dart';
import 'package:much_todo/src/screens/sign_in/reset_password_screen.dart';
import 'package:much_todo/src/screens/sign_in/sign_up_screen.dart';
import 'package:much_todo/src/utils/utils.dart';

class SignInWithEmailScreen extends StatefulWidget {
  const SignInWithEmailScreen({super.key});

  @override
  State<SignInWithEmailScreen> createState() => _SignInWithEmailScreenState();
}

class _SignInWithEmailScreenState extends State<SignInWithEmailScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _hidePassword = true;
  bool _isSigningIn = false;
  final _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context).height;
    return Theme(
      data: ThemeData(
        useMaterial3: true,
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        LoginHeader(size: size, offset: 0.2),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Much To Do',
                              style: TextStyle(
                                fontSize: 45,
                                color: Colors.black,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Form(
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
                                      onFieldSubmitted: (_) {
                                        FocusScope.of(context).requestFocus(_passwordFocusNode);
                                      },
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
                                      focusNode: _passwordFocusNode,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      controller: _passwordController,
                                      obscureText: _hidePassword,
                                      maxLines: 1,
                                      validator: validPassword,
                                      textInputAction: TextInputAction.done,
                                      onFieldSubmitted: (_) => signIn(),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                                            child: ElevatedButton(
                                              onPressed: signIn,
                                              child: _isSigningIn
                                                  ? const CircularProgressIndicator()
                                                  : const Text('SIGN IN'),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: TextButton(
                                        onPressed: resetPassword,
                                        style: TextButton.styleFrom(foregroundColor: Colors.black),
                                        child: const Text(
                                          'Forgot Password?',
                                          style: TextStyle(
                                              decoration: TextDecoration.underline, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 10.0, right: 20.0),
                        child: const Divider(
                          color: Colors.black,
                          height: 36,
                        ),
                      ),
                    ),
                    const Text('DON\'T HAVE ACCOUNT?'),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(left: 20.0, right: 10.0),
                        child: const Divider(
                          color: Colors.black,
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
                          onPressed: signUpWithEmail,
                          child: const Text('SIGN UP WITH EMAIL'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
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
    if (password == null || password.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  void signUpWithEmail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignupScreen(),
      ),
    );
  }

  void resetPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ResetPasswordScreen(),
      ),
    );
  }

  Future<void> signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isSigningIn = true;
    });
    hideKeyboard();

    var result =
        await AuthService.signInWithEmailAndPassword(_emailController.text.trim(), _passwordController.text.trim());
    setState(() {
      _isSigningIn = false;
    });

    if (result.success && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, Home.routeName, (route) => false);
    } else if (context.mounted) {
      showSnackbar('Invalid email or password', context);
    }
  }
}
