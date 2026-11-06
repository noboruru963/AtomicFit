import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// What came back from Firebase after a sign-up or sign-in.
class AuthResult {
  const AuthResult.ok(this.uid) : error = null;
  const AuthResult.failed(this.error) : uid = null;

  final String? uid;
  final String? error;

  bool get isOk => error == null;
}

/// Everything the app needs from the online backend.
abstract class AuthService {
  Future<AuthResult> register(String email, String password);
  Future<AuthResult> signIn(String email, String password);
  Future<void> signOut();

  /// Returns an error message, or `null` when the e-mail was sent.
  Future<String?> sendPasswordReset(String email);

  Future<void> saveProfile(String uid, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> loadProfile(String uid);
}

/// The real implementation, backed by Firebase.
class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Future<AuthResult> register(String email, String password) async {
    try {
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = cred.user;
      if (user == null) return const AuthResult.failed(_generic);
      return AuthResult.ok(user.uid);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failed(_message(e.code));
    } catch (_) {
      return const AuthResult.failed(_generic);
    }
  }

  @override
  Future<AuthResult> signIn(String email, String password) async {
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = cred.user;
      if (user == null) return const AuthResult.failed(_generic);
      return AuthResult.ok(user.uid);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failed(_message(e.code));
    } catch (_) {
      return const AuthResult.failed(_generic);
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      // Same answer for "no such account", so nobody can probe for accounts.
      if (e.code == 'user-not-found') return null;
      return _message(e.code);
    } catch (_) {
      return _generic;
    }
  }

  @override
  Future<void> saveProfile(String uid, Map<String, dynamic> data) {
    return _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  @override
  Future<Map<String, dynamic>?> loadProfile(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _db.collection('users').doc(uid).get();
    return snap.data();
  }

  static const String _generic = 'Something went wrong. Please try again';

  /// Turns Firebase error codes into the app's own wording.
  String _message(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'invalid-email':
        return 'Please enter a valid email address';
      case 'weak-password':
        return 'Password must be at least 6 characters';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      case 'network-request-failed':
        return 'No internet connection';
      default:
        return _generic;
    }
  }
}