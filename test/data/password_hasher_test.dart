import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/data/db/password_hasher.dart';

void main() {
  const PasswordHasher hasher = PasswordHasher();

  test('the same password hashes to the same value with the same salt', () {
    final String salt = hasher.newSalt();
    expect(hasher.hash('password123', salt), hasher.hash('password123', salt));
    expect(hasher.hash('password123', salt), isNot(hasher.hash('other', salt)));
  });

  test('every salt is random', () {
    final Set<String> salts = <String>{
      for (int i = 0; i < 20; i++) hasher.newSalt(),
    };
    expect(salts, hasLength(20));
  });

  test('a correct password verifies', () {
    final String salt = hasher.newSalt();
    final String hash = hasher.hash('password123', salt);
    expect(
      hasher.verify(
        password: 'password123',
        salt: salt,
        expectedHash: hash,
      ),
      isTrue,
    );
  });

  test('a wrong password does not verify', () {
    final String salt = hasher.newSalt();
    final String hash = hasher.hash('password123', salt);
    expect(
      hasher.verify(
        password: 'password124',
        salt: salt,
        expectedHash: hash,
      ),
      isFalse,
    );
  });

  test('the hash never contains the password', () {
    final String salt = hasher.newSalt();
    final String hash = hasher.hash('hunter2', salt);
    expect(hash.contains('hunter2'), isFalse);
    expect(hash.length, 64, reason: 'SHA-256 hex digest');
  });

  test('constant time comparison still compares the values', () {
    expect(constantTimeEquals('abc', 'abc'), isTrue);
    expect(constantTimeEquals('abc', 'abd'), isFalse);
    expect(constantTimeEquals('abc', 'abcd'), isFalse);
    expect(constantTimeEquals('', ''), isTrue);
  });
}
