import 'package:flutter/material.dart';
import 'package:much_todo/src/screens/home/home.dart';
import 'package:much_todo/src/services/auth_service.dart';
import 'package:much_todo/src/screens/sign_in/login_header.dart';
import 'package:much_todo/src/screens/sign_in/sign_in_with_email_screen.dart';
import 'package:much_todo/src/utils/themes.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const routeName = '/sign-in';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
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
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                            ),
                            onPressed: signInWithGoogle,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/google_logo.png',
                                  height: 24,
                                  width: 24,
                                  fit: BoxFit.fitHeight,
                                ),
                                const SizedBox(width: 15),
                                const Text('SIGN IN WITH GOOGLE')
                              ],
                            ),
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
                            // label: const Text('SIGN IN WITH EMAIL'),
                            // icon: const Icon(Icons.email),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: signInWithEmail,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.email,
                                  size: 24,
                                ),
                                SizedBox(width: 15),
                                Text('SIGN IN WITH EMAIL')
                              ],
                            ),
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

  Future<void> signInWithGoogle() async {
    var googleSignInResult = await AuthService.getGoogleCredential();
    if (googleSignInResult.success) {
      var signedInResult = await AuthService.signInWithCredential(googleSignInResult.data!);
      if (signedInResult.success && context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, Home.routeName, (route) => false);
      }
    }
  }

  void signInWithEmail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInWithEmailScreen(),
      ),
    );
  }
}
