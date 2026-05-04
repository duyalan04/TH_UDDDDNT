import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<String> createAccountWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return "Account Created";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  Future<String> loginWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return "Login Successful";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    }
  }

  Future logout() async {
    await FirebaseAuth.instance.signOut();
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.signOut();
    }
  }

  Future<bool> isLoggedIn() async {
    var user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  Future<String> continueWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) return "Login Cancelled";

      final GoogleSignInAuthentication gAuth = await googleUser.authentication;
      final creds = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken, idToken: gAuth.idToken);

      await FirebaseAuth.instance.signInWithCredential(creds);

      return "Google Login Successful";
    } on FirebaseAuthException catch (e) {
      return e.message.toString();
    } catch (e) {
      return e.toString();
    }
  }
}