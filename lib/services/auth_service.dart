import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lostu/views/data/users.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>['email', 'profile'],
  );

  // Allowed domain for Google Sign-In
  static const String _allowedDomain = '@g.batstate-u.edu.ph';

  User? get currentUser => _auth.currentUser;

  Map<String, dynamic>? validateUser(String srCode, String password) {
    for (var user in users) {
      if (user['srCode'] == srCode && user['password'] == password) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user['id']);
        userDoc.get().then((docSnapshot) {
          if (!docSnapshot.exists) {
            userDoc.set({
              'displayName': user['displayName'],
              'photoURL': user['photoURL'],
              'email': user['email'],
              'role': user['role'],
              'srCode': user['srCode'],
              'id': user['id'],
            });
          }
        });
        return user;
      }
    }
    return null;
  }

  /// Validates if the email domain is allowed
  bool _isEmailDomainAllowed(String? email) {
    if (email == null) return false;
    return email.toLowerCase().endsWith(_allowedDomain.toLowerCase());
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      // Check email domain before proceeding with authentication
      if (!_isEmailDomainAllowed(googleUser.email)) {
        // Sign out from Google to clear the selection
        await _googleSignIn.signOut();
        throw FirebaseAuthException(
          code: 'invalid-email-domain',
          message: 'Only @g.batstate-u.edu.ph email addresses are allowed.',
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);

      // Store user info in Firestore if not already present
      final user = userCredential.user;
      if (user != null) {
        final userDoc = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final docSnapshot = await userDoc.get();
        if (!docSnapshot.exists) {
          await userDoc.set({
            'displayName': user.displayName,
            'photoURL': user.photoURL,
            'email': user.email,
            'role': 'user', // Default role for Google users
            'signInMethod': 'google',
          });
        }
      }
      return userCredential;
    } catch (e) {
      // Re-throw domain validation errors
      if (e is FirebaseAuthException && e.code == 'invalid-email-domain') {
        rethrow;
      }
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
