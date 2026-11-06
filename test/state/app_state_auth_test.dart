import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/data/store.dart';
import 'package:atomfit/models/app_account.dart';
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

Future<AppState> _freshState([_MemoryStore? store]) async {
  final AppState state = AppState(store: store ?? _MemoryStore());
  await state.load();
  return state;
}

void main() {
  test('the demo accounts are seeded with hashed passwords', () async {
    final AppState state = await _freshState();
    expect(state.accounts, hasLength(2));
    expect(state.isLoggedIn, isFalse);

    final String hash = state.accounts.first.passwordHash;
    expect(hash, isNotEmpty);
    expect(hash.contains('password123'), isFalse,
        reason: 'the password must never be stored in clear text');
    expect(state.accounts.first.passwordSalt, isNotEmpty);
  });

  test('the seeded demo account can sign in', () async {
    final AppState state = await _freshState();
    final String? error = state.login(
      identifier: 'joe@example.com',
      password: 'password123',
    );
    expect(error, isNull);
    expect(state.isLoggedIn, isTrue);
    expect(state.personalDetailsComplete, isTrue);
    expect(state.user.username, 'Joe123');
  });

  test('the username also works as the sign-in identifier', () async {
    final AppState state = await _freshState();
    expect(
      state.login(identifier: 'Joe123', password: 'password123'),
      isNull,
    );
    expect(state.isLoggedIn, isTrue);
  });

  test('a wrong password is rejected', () async {
    final AppState state = await _freshState();
    final String? error = state.login(
      identifier: 'joe@example.com',
      password: 'nope',
    );
    expect(error, 'Incorrect email or password');
    expect(state.isLoggedIn, isFalse);
  });

  test('registering creates an account that needs personal details', () async {
    final AppState state = await _freshState();
    final String? error = state.registerAccount(
      email: 'new@example.com',
      password: 'secret123',
    );
    expect(error, isNull);
    expect(state.isLoggedIn, isTrue);
    expect(state.personalDetailsComplete, isFalse);
    expect(
        state.accounts.any(
          (AppAccount account) => account.email == 'new@example.com',
        ),
        isTrue);

    // The account can sign in again with its own password.
    final AppState second = await _freshState();
    expect(
      second.login(identifier: 'new@example.com', password: 'secret123'),
      isNull,
    );
  });

  test('registering the same e-mail twice is rejected', () async {
    final AppState state = await _freshState();
    state.registerAccount(email: 'new@example.com', password: 'secret123');
    final String? error = state.registerAccount(
      email: 'new@example.com',
      password: 'other',
    );
    expect(error, isNotNull);
  });

  test('an invalid e-mail is rejected', () async {
    final AppState state = await _freshState();
    expect(
      state.registerAccount(email: 'not-an-email', password: 'secret123'),
      isNotNull,
    );
    expect(
      state.registerAccount(email: 'a@b.com', password: ''),
      isNotNull,
    );
  });

  test('saving the personal details completes the account', () async {
    final AppState state = await _freshState();
    state.registerAccount(email: 'new@example.com', password: 'secret123');

    final invalid = state.savePersonalDetails(
      username: '',
      dobDay: '14',
      dobMonth: 'May',
      dobYear: '1998',
      gender: 'Male',
      weightRaw: '74',
      heightRaw: '178',
    );
    expect(invalid.isValid, isFalse);
    expect(state.personalDetailsComplete, isFalse);

    final valid = state.savePersonalDetails(
      username: 'Newbie',
      dobDay: '14',
      dobMonth: 'May',
      dobYear: '1998',
      gender: 'Male',
      weightRaw: '74',
      heightRaw: '178',
    );
    expect(valid.isValid, isTrue);
    expect(state.personalDetailsComplete, isTrue);
    expect(state.user.username, 'Newbie');
    expect(state.user.dobDay, '14');
    expect(state.user.weightKg, '74');
  });

  test('signing out clears the session', () async {
    final AppState state = await _freshState();
    state.login(identifier: 'joe@example.com', password: 'password123');
    state.logout();
    expect(state.isLoggedIn, isFalse);
  });

  test('the session survives a restart', () async {
    final _MemoryStore store = _MemoryStore();
    final AppState first = await _freshState(store);
    first.login(identifier: 'joe@example.com', password: 'password123');
    await first.persist();

    final AppState second = await _freshState(store);
    expect(second.isLoggedIn, isTrue);
    expect(second.user.username, 'Joe123');
  });
}
