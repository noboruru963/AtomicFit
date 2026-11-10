import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// How a sign-up or sign-in ended.
enum AuthStatus {
  /// Signed in, and the e-mail address is confirmed.
  ok,

  /// Signed in, but the address still has to be confirmed. The session is
  /// kept alive so the confirmation can be re-sent and re-checked.
  unverified,

  /// No session: wrong password, network error, disabled account, ...
  failed,
}

/// What came back from Firebase after a sign-up or sign-in.
class AuthResult {
  const AuthResult.ok(this.uid)
      : status = AuthStatus.ok,
        error = null;
  const AuthResult.unverified(this.uid)
      : status = AuthStatus.unverified,
        error = null;
  const AuthResult.failed(this.error)
      : status = AuthStatus.failed,
        uid = null;

  final AuthStatus status;
  final String? uid;
  final String? error;

  bool get isOk => status == AuthStatus.ok;
  bool get needsVerification => status == AuthStatus.unverified;
}

/// Everything the app needs from the online backend.
abstract class AuthService {
  Future<AuthResult> register(String email, String password);
  Future<AuthResult> signIn(String email, String password);
  Future<void> signOut();

  /// Returns an error message, or `null` when the e-mail was sent.
  Future<String?> sendPasswordReset(String email);

  /// Re-sends the "confirm your email" message to the signed-in account.
  /// Returns an error message, or `null` when the e-mail was sent.
  Future<String?> resendVerification();

  /// Reloads the signed-in account and reports whether the address is
  /// confirmed now. Never signs the account out.
  Future<AuthResult> checkVerification();

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

      // Send the "confirm your email" message. If it fails, the account is
      // still created, so the sign-up does not fail with it — the user can
      // ask for another message from the confirmation screen.
      try {
        await user.sendEmailVerification();
      } catch (_) {}

      // The app opens only after the address is confirmed.
      return AuthResult.unverified(user.uid);
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

      // The local `emailVerified` flag can be stale, so ask Firebase.
      try {
        await user.reload();
      } catch (_) {}
      if (!user.emailVerified) return AuthResult.unverified(user.uid);

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
  Future<String?> resendVerification() async {
    final User? user = _auth.currentUser;
    if (user == null) return _noSession;
    try {
      await user.sendEmailVerification();
      return null;
    } on FirebaseAuthException catch (e) {
      return _message(e.code);
    } catch (_) {
      return _generic;
    }
  }

  @override
  Future<AuthResult> checkVerification() async {
    final User? user = _auth.currentUser;
    if (user == null) return const AuthResult.failed(_noSession);
    try {
      await user.reload();
    } catch (_) {
      return const AuthResult.failed(_generic);
    }
    final User? fresh = _auth.currentUser;
    if (fresh == null) return const AuthResult.failed(_noSession);
    return fresh.emailVerified
        ? AuthResult.ok(fresh.uid)
        : AuthResult.unverified(fresh.uid);
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
  static const String _noSession = 'Please sign in again';

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
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      case 'network-request-failed':
        return 'No internet connection';
      default:
        return _generic;
    }
  }
}
