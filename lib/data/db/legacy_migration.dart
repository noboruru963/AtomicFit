import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/app_models.dart';
import 'app_database.dart';
import 'exercise_repository.dart';
import 'password_hasher.dart';
import 'sqlite_store.dart';

/// Moves the data of the previous (shared-preferences blob) build into the
/// SQLite database.
///
/// The first native build stored everything in one JSON blob under
/// `atomfit_app_v23` / `atomfit_app_v24`. The database build keeps the same
/// document shape, so the migration is a straight conversion — no data model
/// changes, no lossy mapping.
///
/// The migration runs **once**: it only touches an empty database.
class LegacyMigration {
  const LegacyMigration._();

  /// The blob keys the previous builds wrote.
  static const List<String> legacyKeys = <String>[
    'atomfit_app_v23',
    'atomfit_app_v24',
  ];

  /// The password of the migrated account — the demo password of the seeded
  /// accounts, so the migrated profile can still be signed into.
  static const String demoPassword = 'password123';

  /// Converts the legacy blob into the database.
  ///
  /// Returns `true` when a migration was performed.
  static Future<bool> run({
    required AppDatabase appDatabase,
    required SqliteStore store,
    required ExerciseRepository exercises,
    SharedPreferences? preferences,
  }) async {
    final SharedPreferences prefs =
        preferences ?? await SharedPreferences.getInstance();

    String? raw;
    for (final String key in legacyKeys) {
      raw = prefs.getString(key);
      if (raw != null && raw.isNotEmpty) break;
    }
    if (raw == null || raw.isEmpty) return false;

    Map<String, dynamic>? legacy;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) legacy = decoded;
    } on FormatException {
      legacy = null;
    }
    if (legacy == null) return false;

    // Only an empty database is migrated.
    final Map<String, dynamic>? existing = await store.read();
    if (existing != null) return false;

    final Map<String, dynamic> document = _convert(legacy);
    await store.write(document);

    // The custom exercises of the old build are kept; the built-in catalogue
    // is replaced by the RepDB dataset.
    final List<Exercise> custom = _customExercises(legacy);
    if (custom.isNotEmpty) {
      await exercises.upsertAll(custom);
    }

    await _ensureDemoAccounts(store);
    return true;
  }

  /// Builds the new document from the legacy one.
  static Map<String, dynamic> _convert(Map<String, dynamic> legacy) {
    final Object? user = legacy['user'];
    final Map<String, dynamic> profile =
        user is Map<String, dynamic> ? user : <String, dynamic>{};

    final Map<String, dynamic> document = <String, dynamic>{
      'schemaVersion': 1,
      'seedVersion': 1,
      'user': profile,
      'accounts': <Map<String, dynamic>>[_accountFrom(profile)],
      'isLoggedIn': legacy['isLoggedIn'] == true,
      'personalDetailsComplete': true,
      'settings': legacy['settings'],
      'isDarkMode': legacy['isDarkMode'] == true,
      'isProgramAdjusted': legacy['isProgramAdjusted'] == true,
      'adjustmentFactor':
          (legacy['adjustmentFactor'] as num?)?.toDouble() ?? 0.9,
      'programs': legacy['programs'],
      'history': legacy['history'],
      'activeWorkout': legacy['activeWorkout'],
      'quizAnswers': legacy['quizAnswers'],
      'showQuizBannerOnHome': legacy['showQuizBannerOnHome'] != false,
      'quizShortMode': legacy['quizShortMode'] == true,
      'quizStepIndex': legacy['quizStepIndex'],
    };

    // The old document also carried the built-in catalogue; it belongs to the
    // `exercises` table now.
    document.remove('catalogue');
    return document;
  }

  /// The account row of the migrated profile.
  ///
  /// The password of the legacy build is unknown (it never had one), so the
  /// account keeps the demo password of the seeded accounts.
  static Map<String, dynamic> _accountFrom(Map<String, dynamic> profile) {
    final String id = (profile['id'] ?? 'u_alex_01').toString();
    return <String, dynamic>{
      'id': id,
      'userId': (profile['userId'] ?? id).toString(),
      'username': (profile['username'] ?? '').toString(),
      'email': (profile['email'] ?? '').toString(),
      'passwordHash': _hashFor(id),
      'passwordSalt': _saltFor(id),
      'gender': (profile['gender'] ?? 'Prefer not to say').toString(),
      'dobDay': (profile['dobDay'] ?? '').toString(),
      'dobMonth': (profile['dobMonth'] ?? '').toString(),
      'dobYear': (profile['dobYear'] ?? '').toString(),
      'weightKg': (profile['weightKg'] ?? '').toString(),
      'heightCm': (profile['heightCm'] ?? '').toString(),
      'personalDetailsComplete': true,
      'createdAt': (profile['createdAt'] ?? '').toString(),
      'createdAtUtc': (profile['createdAtUtc'] ?? '').toString(),
      'updatedAtUtc': (profile['updatedAtUtc'] ?? '').toString(),
    };
  }

  /// The custom exercises of the legacy catalogue.
  static List<Exercise> _customExercises(Map<String, dynamic> legacy) {
    final Object? catalogue = legacy['catalogue'];
    if (catalogue is! List) return const <Exercise>[];
    final List<Exercise> custom = <Exercise>[];
    for (final dynamic entry in catalogue) {
      if (entry is! Map) continue;
      final Map<String, dynamic> json = entry.cast<String, dynamic>();
      if (json['isCustom'] != true) continue;
      custom.add(Exercise.fromJson(json));
    }
    return custom;
  }

  /// Makes sure the demo accounts exist after a migration.
  static Future<void> _ensureDemoAccounts(SqliteStore store) async {
    final Map<String, dynamic>? document = await store.read();
    if (document == null) return;
    final Object? accounts = document['accounts'];
    if (accounts is! List) return;

    final List<Map<String, dynamic>> rows =
        accounts.whereType<Map<String, dynamic>>().toList(growable: false);
    final bool hasJoe = rows.any(
      (Map<String, dynamic> a) => a['id'] == 'u_joe_01',
    );
    if (hasJoe) return;

    final Map<String, dynamic> joe = <String, dynamic>{
      'id': 'u_joe_01',
      'userId': 'u_joe_01',
      'username': 'Joe123',
      'email': 'joe@example.com',
      'passwordHash': _hashFor('u_joe_01'),
      'passwordSalt': _saltFor('u_joe_01'),
      'gender': 'Prefer not to say',
      'dobDay': '14',
      'dobMonth': 'May',
      'dobYear': '1998',
      'weightKg': '74',
      'heightCm': '178',
      'personalDetailsComplete': true,
      'createdAt': 'October 2026',
      'createdAtUtc': '',
      'updatedAtUtc': '',
    };
    await store.write(<String, dynamic>{
      ...document,
      'accounts': <Map<String, dynamic>>[...rows, joe],
    });
  }

  /// A deterministic salt for a migrated account.
  ///
  /// The migration is a one-off on a device that already holds the data, so a
  /// stable salt is enough — it only has to be unique per account.
  static String _saltFor(String id) {
    final List<int> bytes = List<int>.generate(
      16,
      (int index) => id.codeUnitAt(index % id.length) + index * 31,
      growable: false,
    );
    const String alphabet = '0123456789abcdef';
    final StringBuffer buffer = StringBuffer();
    for (final int byte in bytes) {
      buffer
        ..write(alphabet[(byte >> 4) & 0x0f])
        ..write(alphabet[byte & 0x0f]);
    }
    return buffer.toString();
  }

  /// The hash of the demo password for a migrated account.
  static String _hashFor(String id) {
    final String salt = _saltFor(id);
    return const PasswordHasher().hash(demoPassword, salt);
  }
}
