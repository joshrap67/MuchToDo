import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/screens/home/home.dart';
import 'package:much_todo/src/screens/sign_in/auth_service.dart';
import 'package:much_todo/src/screens/sign_in/login_header.dart';
import 'package:much_todo/src/utils/utils.dart';

class UnverifiedScreen extends StatefulWidget {
  const UnverifiedScreen({super.key});

  static const routeName = '/unverified';

  @override
  State<UnverifiedScreen> createState() => _UnverifiedScreenState();
}

class _UnverifiedScreenState extends State<UnverifiedScreen> {
  bool _isEmailSending = false;
  bool _isReloading = false;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context).height;
    checkVerified();
    return Theme(
      data: ThemeData(
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
                  Color(0xFF9890e3),
                  Color(0xFF9ea7de),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            LoginHeader(size: size, offset: 0.3),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Your email is not yet verified. Please check your inbox to verify your account.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: resendVerificationEmail,
                            child: _isEmailSending
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('RESEND VERIFICATION EMAIL'),
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
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: () {
                              setState(() {});
                            },
                            child: _isReloading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text('RELOAD PAGE'),
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
    );
  }

  Future<void> checkVerified() async {
    setState(() {
      _isReloading = true;
    });
    var user = FirebaseAuth.instance.currentUser!;
    await user.reload();
    setState(() {
      _isReloading = false;
    });
    if (user.emailVerified && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, Home.routeName, (route) => false);
    }
  }

  Future<void> resendVerificationEmail() async {
    setState(() {
      _isEmailSending = true;
    });
    var emailSent = await AuthService.sendEmailVerification();
    setState(() {
      _isEmailSending = false;
    });
    if (emailSent && context.mounted) {
      showSnackbar('Email sent, check your inbox', context);
    }
  }
}
