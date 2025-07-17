import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lostu/views/data/users.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  User? get currentUser => _auth.currentUser;

  Map<String, dynamic>? validateUser(String srCode, String password) {
    for (var user in users) {
      if (user['srCode'] == srCode && user['password'] == password) {
        return user; 
      }
    }
    return null;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  bool isSignedIn() {
    return _auth.currentUser != null;
  }

  String? getUserDisplayName() {
    return _auth.currentUser?.displayName;
  }

  String? getUserEmail() {
    return _auth.currentUser?.email;
  }

  String? getUserPhotoURL() {
    return _auth.currentUser?.photoURL;
  }
}
