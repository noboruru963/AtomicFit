import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/data/store.dart';
import 'package:atomfit/services/auth_service.dart';
import 'package:atomfit/state/app_state.dart';

class _MemoryStore implements AtomFitStore {
  Map<String, dynamic>? data;

  @override
  Future<Map<String, dynamic>?> read() async => data;

  @override
  Future<void> write(Map<String, dynamic> document) async {
    data = document;
  }
}

/// Stands in for Firebase so the sign-in paths can be tested without a phone.
class _FakeAuthService implements AuthService {
  AuthResult signInResult = const AuthResult.failed('not configured');
  AuthResult registerResult = const AuthResult.failed('not configured');
  AuthResult checkResult = const AuthResult.failed('not configured');
  Map<String, dynamic>? profile;

  int resendCalls = 0;
  bool signedOut = false;
  String? lastLoadedUid;

  @override
  Future<AuthResult> signIn(String email, String password) async =>
      signInResult;

  @override
  Future<AuthResult> register(String email, String password) async =>
      registerResult;

  @override
  Future<void> signOut() async {
    signedOut = true;
  }

  @override
  Future<String?> sendPasswordReset(String email) async => null;

  @override
  Future<String?> resendVerification() async {
    resendCalls += 1;
    return null;
  }

  @override
  Future<AuthResult> checkVerification() async => checkResult;

  @override
  Future<void> saveProfile(String uid, Map<String, dynamic> data) async {}

  @override
  Future<Map<String, dynamic>?> loadProfile(String uid) async {
    lastLoadedUid = uid;
    return profile;
  }
}

Future<AppState> _freshState(_FakeAuthService auth) async {
  final AppState state = AppState(store: _MemoryStore());
  await state.load();
  state.auth = auth;
  return state;
}

void main() {
  test('an unconfirmed sign-in does not open the app', () async {
    final _FakeAuthService auth = _FakeAuthService()
      ..signInResult = const AuthResult.unverified('uid-1');
    final AppState state = await _freshState(auth);
    final int accountsBefore = state.accounts.length;

    final SignInOutcome outcome = await state.loginOnline(
      identifier: 'alex@example.com',
      password: 'password123',
    );

    expect(outcome.needsVerification, isTrue);
    expect(outcome.email, 'alex@example.com');
    expect(state.isLoggedIn, isFalse);
    expect(state.pendingVerificationEmail, 'alex@example.com');
    expect(state.accounts, hasLength(accountsBefore));
  });

  test('registration stops at the confirmation step', () async {
    final _FakeAuthService auth = _FakeAuthService()
      ..registerResult = const AuthResult.unverified('uid-2');
    final AppState state = await _freshState(auth);

    final SignInOutcome outcome = await state.registerOnline(
      email: 'New@Example.com',
      password: 'password123',
    );

    expect(outcome.needsVerification, isTrue);
    expect(state.isLoggedIn, isFalse);
    expect(state.pendingVerificationEmail, 'new@example.com');
    expect(
      state.accounts.where((account) => account.id == 'uid-2'),
      isEmpty,
      reason: 'the account is only created once the address is confirmed',
    );
  });

  test('a confirmed sign-in opens the account right away', () async {
    final _FakeAuthService auth = _FakeAuthService()
      ..signInResult = const AuthResult.ok('uid-3');
    final AppState state = await _freshState(auth);

    final SignInOutcome outcome = await state.loginOnline(
      identifier: 'alex@example.com',
      password: 'password123',
    );

    expect(outcome.isOk, isTrue);
    expect(state.isLoggedIn, isTrue);
    expect(auth.lastLoadedUid, 'uid-3');
    expect(state.pendingVerificationEmail, isEmpty);
  });

  test('confirmEmailVerified opens the account once Firebase agrees', () async {
    final _FakeAuthService auth = _FakeAuthService()
      ..signInResult = const AuthResult.unverified('uid-4')
      ..checkResult = const AuthResult.ok('uid-4');
    final AppState state = await _freshState(auth);
    await state.loginOnline(
      identifier: 'alex@example.com',
      password: 'password123',
    );

    final VerificationCheck check = await state.confirmEmailVerified();

    expect(check, VerificationCheck.verified);
    expect(state.isLoggedIn, isTrue);
    expect(state.pendingVerificationEmail, isEmpty);
    expect(
      state.accounts.any((account) => account.userId == 'uid-4'),
      isTrue,
    );
  });

  test('confirmEmailVerified stays closed while the address is unconfirmed',
      () async {
    final _FakeAuthService auth = _FakeAuthService()
      ..signInResult = const AuthResult.unverified('uid-5')
      ..checkResult = const AuthResult.unverified('uid-5');
    final AppState state = await _freshState(auth);
    await state.loginOnline(
      identifier: 'alex@example.com',
      password: 'password123',
    );

    expect(await state.confirmEmailVerified(), VerificationCheck.notYet);
    expect(state.isLoggedIn, isFalse);
  });

  test('resendVerification asks the backend again', () async {
    final _FakeAuthService auth = _FakeAuthService();
    final AppState state = await _freshState(auth);

    expect(await state.resendVerification(), isNull);
    expect(auth.resendCalls, 1);
  });

  test('cancelVerification signs out and forgets the pending address',
      () async {
    final _FakeAuthService auth = _FakeAuthService()
      ..signInResult = const AuthResult.unverified('uid-6');
    final AppState state = await _freshState(auth);
    await state.loginOnline(
      identifier: 'alex@example.com',
      password: 'password123',
    );

    state.cancelVerification();

    expect(auth.signedOut, isTrue);
    expect(state.pendingVerificationEmail, isEmpty);
    expect(state.isLoggedIn, isFalse);
  });

  test('a wrong password still returns a plain error', () async {
    final _FakeAuthService auth = _FakeAuthService()
      ..signInResult = const AuthResult.failed('Incorrect email or password');
    final AppState state = await _freshState(auth);

    final SignInOutcome outcome = await state.loginOnline(
      identifier: 'alex@example.com',
      password: 'nope',
    );

    expect(outcome.status, SignInStatus.error);
    expect(outcome.message, 'Incorrect email or password');
    expect(state.isLoggedIn, isFalse);
  });
}
