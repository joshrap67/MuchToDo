import 'package:flutter/material.dart';
import 'package:much_todo/src/screens/home/home.dart';
import 'package:much_todo/src/screens/sign_in/auth_service.dart';
import 'package:much_todo/src/screens/sign_in/login_header.dart';
import 'package:much_todo/src/screens/sign_in/sign_in_with_email_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static const routeName = '/sign-in';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

// todo need to put sha-1 when creating signed bundle for google sign in
class _SignInScreenState extends State<SignInScreen> {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.sizeOf(context).height;
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
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                          child: ElevatedButton.icon(
                            label: const Text('SIGN IN WITH GOOGLE'),
                            icon: const Icon(Icons.email),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                            ),
                            onPressed: signInWithGoogle,
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
                          child: ElevatedButton.icon(
                            label: const Text('SIGN IN WITH EMAIL'),
                            icon: const Icon(Icons.email),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: signInWithEmail,
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
    var signedIn = await AuthService.signInWithGoogle();
    if (signedIn && context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, Home.routeName, (route) => false);
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
