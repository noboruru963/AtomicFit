import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Salted password hashing for the local `accounts` table.
///
/// The prototype stores plain-text passwords inside `localStorage`; the
/// database never does. Every account stores a random salt plus the SHA-256
/// digest of `salt + password`.
///
/// This is prototype-grade (the Argon-2 / PBKDF2 requirement of the SRS is
/// out of scope for the local build) — the interface stays small so a stronger
/// KDF can replace it without touching the repository.
class PasswordHasher {
  const PasswordHasher();

  /// Creates a fresh random salt (hex encoded).
  String newSalt() {
    final Random random = Random.secure();
    final List<int> bytes =
        List<int>.generate(16, (_) => random.nextInt(256), growable: false);
    return _toHex(bytes);
  }

  /// Hashes [password] with [salt].
  String hash(String password, String salt) =>
      sha256.convert(utf8.encode('$salt::$password')).toString();

  /// Whether [password] matches the stored [expectedHash]/[salt] pair.
  bool verify({
    required String password,
    required String salt,
    required String expectedHash,
  }) {
    return constantTimeEquals(hash(password, salt), expectedHash);
  }
}

/// Compares two strings without leaking their length through early exit.
bool constantTimeEquals(String a, String b) {
  final int length = max(a.length, b.length);
  int diff = a.length ^ b.length;
  for (int i = 0; i < length; i++) {
    final int x = i < a.length ? a.codeUnitAt(i) : 0;
    final int y = i < b.length ? b.codeUnitAt(i) : 0;
    diff |= x ^ y;
  }
  return diff == 0;
}

/// Encodes bytes as a lower-case hex string.
String _toHex(List<int> bytes) {
  const String alphabet = '0123456789abcdef';
  final StringBuffer buffer = StringBuffer();
  for (final int byte in bytes) {
    buffer
      ..write(alphabet[(byte >> 4) & 0x0f])
      ..write(alphabet[byte & 0x0f]);
  }
  return buffer.toString();
}
