import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/app/shell.dart';
import 'package:atomfit/data/store.dart';
import 'package:atomfit/screens/verify_email_screen.dart';
import 'package:atomfit/services/auth_service.dart';
import 'package:atomfit/state/app_state.dart';
import 'package:atomfit/strings.dart';
import 'package:atomfit/theme/app_theme.dart';

import 'helpers/fonts.dart';

class _MemoryStore implements AtomFitStore {
  Map<String, dynamic>? data;

  @override
  Future<Map<String, dynamic>?> read() async => data;

  @override
  Future<void> write(Map<String, dynamic> document) async {
    data = document;
  }
}

class _FakeAuthService implements AuthService {
  AuthResult checkResult = const AuthResult.failed('not configured');
  int resendCalls = 0;
  bool signedOut = false;

  @override
  Future<AuthResult> signIn(String email, String password) async =>
      const AuthResult.failed('not configured');

  @override
  Future<AuthResult> register(String email, String password) async =>
      const AuthResult.failed('not configured');

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
  Future<Map<String, dynamic>?> loadProfile(String uid) async => null;
}

Future<AppState> _pendingState(_FakeAuthService auth) async {
  final AppState state = AppState(store: _MemoryStore());
  await state.load();
  state.auth = auth;
  state.pendingVerificationEmail = 'alex@example.com';
  return state;
}

Future<void> _pumpScreen(WidgetTester tester, AppState state) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: AfTheme.light,
      home: AfAppScope(state: state, child: const VerifyEmailScreen()),
      routes: <String, WidgetBuilder>{
        AfScreen.login: (BuildContext context) => const SizedBox.shrink(),
        AfScreen.home: (BuildContext context) => const SizedBox.shrink(),
        AfScreen.personalDetails: (BuildContext context) =>
            const SizedBox.shrink(),
      },
    ),
  );
  await tester.pump();
}

void main() {
  setUp(() async {
    await loadAppFonts();
  });

  testWidgets('the confirmation screen shows the address and both actions',
      (WidgetTester tester) async {
    final _FakeAuthService auth = _FakeAuthService();
    final AppState state = await _pendingState(auth);
    await _pumpScreen(tester, state);

    expect(find.text(AfStrings.verifyTitle), findsOneWidget);
    expect(
      find.textContaining('alex@example.com'),
      findsOneWidget,
      reason: 'the screen must say which address was used',
    );
    expect(find.text(AfStrings.verifyConfirm), findsOneWidget);
    expect(find.text(AfStrings.verifyResend), findsOneWidget);
    expect(find.text(AfStrings.verifyBack), findsOneWidget);
  });

  testWidgets('"I have verified" reports an address that is still unconfirmed',
      (WidgetTester tester) async {
    final _FakeAuthService auth = _FakeAuthService()
      ..checkResult = const AuthResult.unverified('uid-1');
    final AppState state = await _pendingState(auth);
    await _pumpScreen(tester, state);

    await tester.tap(find.text(AfStrings.verifyConfirm));
    await tester.pump();
    await tester.pump();

    expect(find.text(AfStrings.verifyNotYet), findsOneWidget);
    expect(state.isLoggedIn, isFalse);
  });

  testWidgets('resending asks the backend and confirms with a toast',
      (WidgetTester tester) async {
    final _FakeAuthService auth = _FakeAuthService();
    final AppState state = await _pendingState(auth);
    await _pumpScreen(tester, state);

    await tester.tap(find.text(AfStrings.verifyResend));
    await tester.pump();
    await tester.pump();

    expect(auth.resendCalls, 1);
    expect(find.text(AfStrings.verifyResent), findsWidgets);

    // Let the toast timer run out so the test ends with no pending timers.
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('"Back to login" signs the unconfirmed session out',
      (WidgetTester tester) async {
    final _FakeAuthService auth = _FakeAuthService();
    final AppState state = await _pendingState(auth);
    await _pumpScreen(tester, state);

    await tester.tap(find.text(AfStrings.verifyBack));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(auth.signedOut, isTrue);
    expect(state.pendingVerificationEmail, isEmpty);
  });
}
