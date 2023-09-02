import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static Future<OAuthCredential?> getGoogleCredential() async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    if (gUser == null) {
      return null;
    }

    final GoogleSignInAuthentication gAuth = await gUser.authentication;
    final credential = GoogleAuthProvider.credential(accessToken: gAuth.accessToken, idToken: gAuth.idToken);
    // we only needed to sign in to google for auth token, so sign out
    await GoogleSignIn().signOut();

    await FirebaseAuth.instance.signInWithCredential(credential);
    return credential;
  }

  static Future<bool> signInWithCredential(OAuthCredential credential) async {
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> signInWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await sendEmailVerification();
      return true;
    } catch (_) {
      //todo specific messages for email already in use?
      return false;
    }
  }

  static Future<bool> sendEmailVerification() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> sendResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }
}
