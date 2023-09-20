import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:much_todo/src/screens/home/home.dart';
import 'package:much_todo/src/services/auth_service.dart';
import 'package:much_todo/src/screens/sign_in/login_header.dart';
import 'package:much_todo/src/utils/themes.dart';
import 'package:much_todo/src/utils/utils.dart';

class UnverifiedScreen extends StatefulWidget {
  const UnverifiedScreen({super.key});

  static const routeName = '/unverified';

  @override
  State<UnverifiedScreen> createState() => _UnverifiedScreenState();
}

class _UnverifiedScreenState extends State<UnverifiedScreen> with WidgetsBindingObserver {
  bool _isEmailSending = false;
  bool _isReloading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    checkVerified();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkVerified();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
                            onPressed: resendVerificationEmail,
                            child: _isEmailSending
                                ? const CircularProgressIndicator()
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
                            onPressed: () {
                              setState(() {
                                checkVerified();
                              });
                            },
                            child: _isReloading
                                ? const CircularProgressIndicator()
                                : const Text('CHECK VERIFICATION STATUS'),
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
    if (FirebaseAuth.instance.currentUser!.emailVerified && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, Home.routeName, (route) => false);
    }
  }

  Future<void> resendVerificationEmail() async {
    setState(() {
      _isEmailSending = true;
    });

    var result = await AuthService.sendEmailVerification();
    setState(() {
      _isEmailSending = false;
    });

    if (result.success && context.mounted) {
      showSnackbar('Email sent, check your inbox', context);
    }
  }
}
