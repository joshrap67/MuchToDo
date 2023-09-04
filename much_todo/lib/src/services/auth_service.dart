import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:much_todo/src/utils/result.dart';

class AuthService {
  static Future<Result<OAuthCredential>> getGoogleCredential() async {
    var result = Result<OAuthCredential>();
    var gUser = await GoogleSignIn().signIn();
    if (gUser == null) {
      result.setErrorMessage('Could not sign into Google');
      return result;
    }

    var gAuth = await gUser.authentication;
    var credential = GoogleAuthProvider.credential(accessToken: gAuth.accessToken, idToken: gAuth.idToken);
    // we only needed to sign in to google for auth token, so sign out
    await GoogleSignIn().signOut();

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      result.setData(credential);
    } catch (e) {
      result.setErrorMessage('Could not sign in with Google');
    }

    return result;
  }

  static Future<Result<void>> signInWithCredential(OAuthCredential credential) async {
    var result = Result();
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      result.setErrorMessage('Could not sign in');
    }
    return result;
  }

  static Future<Result<void>> signInWithEmailAndPassword(String email, String password) async {
    var result = Result();
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
    } catch (_) {
      result.setErrorMessage('Invalid credentials');
    }
    return result;
  }

  static Future<Result<void>> signUpWithEmailAndPassword(String email, String password) async {
    var result = Result();
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      await sendEmailVerification();
    } catch (_) {
      result.setErrorMessage('Could not sign up with this email');
    }
    return result;
  }

  static Future<Result<void>> sendEmailVerification() async {
    var result = Result();
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
    } catch (e) {
      result.setErrorMessage('There was a problem trying to send the verification. Please try again later');
    }
    return result;
  }

  static Future<Result<void>> sendResetEmail(String email) async {
    var result = Result();
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      result.setErrorMessage('There was a problem trying to send the reset link. Please try again later');
    }
    return result;
  }
}
