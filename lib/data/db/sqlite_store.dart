import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../store.dart';
import 'app_database.dart';

/// The document shape shared by every store implementation.
Map<String, dynamic> _emptyDocument() => <String, dynamic>{
      'schemaVersion': 1,
      'seedVersion': 1,
    };

/// SQLite backed [AtomFitStore].
///
/// The store keeps the prototype's document contract (`read()` /
/// `write(Map)`) but stores it relationally:
///
/// | document key        | table                                     |
/// |---------------------|-------------------------------------------|
/// | `user`, `accounts`  | `accounts`                                |
/// | `settings`          | `settings`                                |
/// | `programs`          | `programs`                                |
/// | `history`           | `sessions` + `set_logs`                   |
/// | `activeWorkout`, …  | `app_state` (key/value)                   |
/// | `catalogue`         | `exercises` (owned by the exercise repo)  |
class SqliteStore implements AtomFitStore {
  SqliteStore(this._appDatabase);

  final AppDatabase _appDatabase;

  @override
  Future<Map<String, dynamic>?> read() async {
    final Database db = await _appDatabase.database;

    final List<Map<String, Object?>> accountRows = await db.query(
      'accounts',
      where: 'deleted_at_utc IS NULL',
      orderBy: 'created_at_utc ASC',
    );
    final List<Map<String, Object?>> settingsRows =
        await db.query('settings', limit: 1);
    final List<Map<String, Object?>> programRows = await db.query(
      'programs',
      where: 'deleted_at_utc IS NULL',
    );
    final List<Map<String, Object?>> sessionRows = await db.query(
      'sessions',
      where: 'deleted_at_utc IS NULL',
    );
    final List<Map<String, Object?>> setRows =
        await db.query('set_logs', where: 'deleted_at_utc IS NULL');
    final List<Map<String, Object?>> stateRows = await db.query('app_state');

    if (accountRows.isEmpty &&
        settingsRows.isEmpty &&
        programRows.isEmpty &&
        sessionRows.isEmpty &&
        stateRows.isEmpty) {
      return null;
    }

    final Map<String, Object?> settings =
        settingsRows.isEmpty ? <String, Object?>{} : settingsRows.first;
    final Map<String, String> state = <String, String>{
      for (final Map<String, Object?> row in stateRows)
        (row['key'] ?? '').toString(): (row['value'] ?? '').toString(),
    };

    final List<Map<String, dynamic>> accounts =
        accountRows.map(_accountToJson).toList(growable: false);

    final String? currentAccountId = settings['current_account_id']?.toString();
    Map<String, dynamic>? user;
    if (currentAccountId != null && currentAccountId.isNotEmpty) {
      for (final Map<String, dynamic> account in accounts) {
        if (account['id'] == currentAccountId) {
          user = account;
          break;
        }
      }
    }
    user ??= accounts.isEmpty ? null : accounts.first;

    final Map<String, dynamic> document = _emptyDocument()
      ..['accounts'] = accounts
      ..['isLoggedIn'] = (settings['is_logged_in'] as int? ?? 0) == 1
      ..['isDarkMode'] = (settings['is_dark_mode'] as int? ?? 0) == 1
      ..['isProgramAdjusted'] =
          (settings['is_program_adjusted'] as int? ?? 0) == 1
      ..['adjustmentFactor'] = settings['adjustment_factor'] is num
          ? (settings['adjustment_factor'] as num).toDouble()
          : 0.9;

    if (user != null) {
      document['user'] = user;
    }

    final Map<String, dynamic> settingsFlags = <String, dynamic>{
      'id': 'settings',
      'userId': (settings['user_id'] ?? '').toString(),
      'sensorAutoDetect': (settings['sensor_auto_detect'] as int? ?? 1) == 1,
      'voiceLogging': (settings['voice_logging'] as int? ?? 1) == 1,
      'hapticFeedback': (settings['haptic_feedback'] as int? ?? 1) == 1,
      'lockscreenWidget': (settings['lockscreen_widget'] as int? ?? 1) == 1,
      'bellSound': (settings['bell_sound'] as int? ?? 1) == 1,
      'restNotifications': (settings['rest_notifications'] as int? ?? 1) == 1,
      'createdAtUtc': (settings['created_at_utc'] ?? '').toString(),
      'updatedAtUtc': (settings['updated_at_utc'] ?? '').toString(),
      'deletedAtUtc': settings['deleted_at_utc'],
    };
    document['settings'] = settingsFlags;

    document['programs'] =
        programRows.map(_programToJson).toList(growable: false);
    document['history'] = _assembleHistory(sessionRows, setRows);
    document['activeWorkout'] =
        _decodeJson(state['activeWorkout']) ?? <String, dynamic>{};
    document['scheduledWorkouts'] =
        _decodeJson(state['scheduledWorkouts']) ?? <dynamic>[];
    document['quizAnswers'] =
        _decodeJson(state['quizAnswers']) ?? <String, dynamic>{};
    document['showQuizBannerOnHome'] = state['showQuizBannerOnHome'] != 'false';
    document['quizShortMode'] = state['quizShortMode'] == 'true';
    document['quizStepIndex'] = int.tryParse(state['quizStepIndex'] ?? '') ?? 0;

    return document;
  }

  @override
  Future<void> write(Map<String, dynamic> document) async {
    final Database db = await _appDatabase.database;
    final String now = DateTime.now().toUtc().toIso8601String();

    await db.transaction((Transaction txn) async {
      // ------------------------------------------------------------ accounts
      final Map<String, dynamic>? user = _asMap(document['user']);
      final List<Map<String, dynamic>> accounts =
          _asMapList(document['accounts']);
      final Map<String, Map<String, dynamic>> merged =
          <String, Map<String, dynamic>>{};
      for (final Map<String, dynamic> account in accounts) {
        final String id = (account['id'] ?? '').toString();
        if (id.isNotEmpty) merged[id] = account;
      }
      if (user != null) {
        final String id = (user['id'] ?? '').toString();
        if (id.isNotEmpty) {
          merged[id] = <String, dynamic>{
            ...merged[id] ?? <String, dynamic>{},
            ...user,
          };
        }
      }
      for (final Map<String, dynamic> account in merged.values) {
        await txn.insert(
          'accounts',
          _accountToRow(account, now),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // ------------------------------------------------------------ settings
      // A partial document must not reset the stored preferences, so the
      // existing row is merged with whatever the document carries.
      final List<Map<String, Object?>> existingSettings =
          await txn.query('settings', limit: 1);
      final Map<String, Object?> storedSettings = existingSettings.isEmpty
          ? <String, Object?>{}
          : existingSettings.first;
      final Map<String, dynamic> settings =
          _asMap(document['settings']) ?? <String, dynamic>{};

      bool flag(String key, String column) {
        final Object? value = settings[key];
        if (value is bool) return value;
        final Object? stored = storedSettings[column];
        return stored is int ? stored == 1 : true;
      }

      bool documentFlag(String key, String column, {bool fallback = false}) {
        final Object? value = document[key];
        if (value is bool) return value;
        final Object? stored = storedSettings[column];
        return stored is int ? stored == 1 : fallback;
      }

      final String currentAccountId =
          (user?['id'] ?? document['currentAccountId'] ?? '').toString();
      await txn.insert(
        'settings',
        <String, Object?>{
          'id': 'settings',
          'user_id': (settings['userId'] ?? currentAccountId).toString(),
          'sensor_auto_detect':
              flag('sensorAutoDetect', 'sensor_auto_detect') ? 1 : 0,
          'voice_logging': flag('voiceLogging', 'voice_logging') ? 1 : 0,
          'haptic_feedback': flag('hapticFeedback', 'haptic_feedback') ? 1 : 0,
          'lockscreen_widget':
              flag('lockscreenWidget', 'lockscreen_widget') ? 1 : 0,
          'bell_sound': flag('bellSound', 'bell_sound') ? 1 : 0,
          'rest_notifications':
              flag('restNotifications', 'rest_notifications') ? 1 : 0,
          'is_dark_mode': documentFlag('isDarkMode', 'is_dark_mode') ? 1 : 0,
          'is_logged_in': documentFlag('isLoggedIn', 'is_logged_in') ? 1 : 0,
          'current_account_id': currentAccountId,
          'is_program_adjusted':
              documentFlag('isProgramAdjusted', 'is_program_adjusted') ? 1 : 0,
          'adjustment_factor':
              (document['adjustmentFactor'] as num?)?.toDouble() ??
                  (storedSettings['adjustment_factor'] as num?)?.toDouble() ??
                  0.9,
          'created_at_utc': now,
          'updated_at_utc': now,
          'deleted_at_utc': null,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // ------------------------------------------------------------ programs
      await txn.delete('programs');
      for (final Map<String, dynamic> program
          in _asMapList(document['programs'])) {
        await txn.insert(
          'programs',
          <String, Object?>{
            'id': (program['id'] ?? '').toString(),
            'user_id': (program['userId'] ?? '').toString(),
            'name': (program['name'] ?? '').toString(),
            'split_group': (program['splitGroup'] ?? '').toString(),
            'type': (program['type'] ?? '').toString(),
            'duration': (program['duration'] ?? '').toString(),
            'frequency': (program['frequency'] ?? '').toString(),
            'difficulty': (program['difficulty'] ?? '').toString(),
            'active': program['active'] == true ? 1 : 0,
            'exercises': jsonEncode(program['exercises'] ?? const <dynamic>[]),
            'created_at_utc': (program['createdAtUtc'] ?? now).toString(),
            'updated_at_utc': (program['updatedAtUtc'] ?? now).toString(),
            'deleted_at_utc': program['deletedAtUtc'],
          },
        );
      }

      // ------------------------------------------------------------ sessions
      await txn.delete('set_logs');
      await txn.delete('sessions');
      for (final Map<String, dynamic> session
          in _asMapList(document['history'])) {
        await _insertSession(txn, session, now, null);
        for (final Map<String, dynamic> child
            in _asMapList(session['children'])) {
          await _insertSession(
              txn, child, now, (session['id'] ?? '').toString());
        }
      }

      // ----------------------------------------------------------- app state
      await txn.insert(
        'app_state',
        <String, Object?>{
          'key': 'activeWorkout',
          'value': jsonEncode(document['activeWorkout'] ?? <String, dynamic>{}),
          'updated_at_utc': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      if (document['scheduledWorkouts'] != null) {
        // A partial document must not clear the planned workouts, so the key
        // is only written when the state actually carries it.
        await txn.insert(
          'app_state',
          <String, Object?>{
            'key': 'scheduledWorkouts',
            'value': jsonEncode(document['scheduledWorkouts']),
            'updated_at_utc': now,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await txn.insert(
        'app_state',
        <String, Object?>{
          'key': 'quizAnswers',
          'value': jsonEncode(document['quizAnswers'] ?? <String, dynamic>{}),
          'updated_at_utc': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'app_state',
        <String, Object?>{
          'key': 'showQuizBannerOnHome',
          'value': document['showQuizBannerOnHome'] == false ? 'false' : 'true',
          'updated_at_utc': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'app_state',
        <String, Object?>{
          'key': 'quizShortMode',
          'value': document['quizShortMode'] == true ? 'true' : 'false',
          'updated_at_utc': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'app_state',
        <String, Object?>{
          'key': 'quizStepIndex',
          'value': (document['quizStepIndex'] ?? 0).toString(),
          'updated_at_utc': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  Future<void> _insertSession(
    Transaction txn,
    Map<String, dynamic> session,
    String now,
    String? parentId,
  ) async {
    final String id = (session['id'] ?? '').toString();
    if (id.isEmpty) return;
    await txn.insert(
      'sessions',
      <String, Object?>{
        'id': id,
        'user_id': (session['userId'] ?? '').toString(),
        'name': (session['name'] ?? '').toString(),
        'type': (session['type'] ?? 'full').toString(),
        'date_label': (session['dateLabel'] ?? '').toString(),
        'day_of_month': (session['dayOfMonth'] as num?)?.toInt() ?? 1,
        'started_at_utc': (session['startedAtUtc'] ?? '').toString(),
        'duration_min': (session['durationMin'] as num?)?.toInt() ?? 0,
        'reps': (session['reps'] as num?)?.toInt() ?? 0,
        'volume': (session['volume'] as num?)?.toDouble() ?? 0,
        'sets_count': (session['setsCount'] as num?)?.toInt() ?? 0,
        'methods': jsonEncode(session['methods'] ?? const <dynamic>[]),
        'parent_id': parentId,
        'created_at_utc': (session['createdAtUtc'] ?? now).toString(),
        'updated_at_utc': (session['updatedAtUtc'] ?? now).toString(),
        'deleted_at_utc': session['deletedAtUtc'],
      },
    );
    for (final Map<String, dynamic> set in _asMapList(session['setsDetail'])) {
      final String setId = (set['id'] ?? '').toString();
      if (setId.isEmpty) continue;
      await txn.insert(
        'set_logs',
        <String, Object?>{
          'id': setId,
          'user_id': (set['userId'] ?? '').toString(),
          'session_id': id,
          'exercise_name': (set['exerciseName'] ?? '').toString(),
          'set_no': (set['setNo'] as num?)?.toInt() ?? 1,
          'exercise_set_no': (set['exerciseSetNo'] as num?)?.toInt() ?? 1,
          'weight_kg': (set['weightKg'] as num?)?.toDouble() ?? 0,
          'reps': (set['reps'] as num?)?.toInt() ?? 0,
          'rest_s': (set['restS'] as num?)?.toInt() ?? 0,
          'input_method': (set['inputMethod'] ?? 'manual').toString(),
          'logged_at_utc': (set['loggedAtUtc'] ?? '').toString(),
          'created_at_utc': (set['createdAtUtc'] ?? now).toString(),
          'updated_at_utc': (set['updatedAtUtc'] ?? now).toString(),
          'deleted_at_utc': set['deletedAtUtc'],
        },
      );
    }
  }

  List<Map<String, dynamic>> _assembleHistory(
    List<Map<String, Object?>> sessionRows,
    List<Map<String, Object?>> setRows,
  ) {
    final Map<String, List<Map<String, Object?>>> setsBySession =
        <String, List<Map<String, Object?>>>{};
    for (final Map<String, Object?> row in setRows) {
      final String sessionId = (row['session_id'] ?? '').toString();
      setsBySession
          .putIfAbsent(sessionId, () => <Map<String, Object?>>[])
          .add(row);
    }

    final Map<String, List<Map<String, Object?>>> childrenByParent =
        <String, List<Map<String, Object?>>>{};
    for (final Map<String, Object?> row in sessionRows) {
      final Object? parentId = row['parent_id'];
      if (parentId == null) continue;
      childrenByParent
          .putIfAbsent(parentId.toString(), () => <Map<String, Object?>>[])
          .add(row);
    }

    final List<Map<String, dynamic>> history = <Map<String, dynamic>>[];
    for (final Map<String, Object?> row in sessionRows) {
      if (row['parent_id'] != null) continue;
      final String id = (row['id'] ?? '').toString();
      history.add(<String, dynamic>{
        ..._sessionToJson(row),
        'setsDetail': (setsBySession[id] ?? const <Map<String, Object?>>[])
            .map(_setToJson)
            .toList(growable: false),
        'children': (childrenByParent[id] ?? const <Map<String, Object?>>[])
            .map(_sessionToJson)
            .toList(growable: false),
      });
    }
    return history;
  }

  Map<String, dynamic> _sessionToJson(Map<String, Object?> row) {
    return <String, dynamic>{
      'id': (row['id'] ?? '').toString(),
      'userId': (row['user_id'] ?? '').toString(),
      'name': (row['name'] ?? '').toString(),
      'type': (row['type'] ?? 'full').toString(),
      'dateLabel': (row['date_label'] ?? '').toString(),
      'dayOfMonth': (row['day_of_month'] as num?)?.toInt() ?? 1,
      'startedAtUtc': (row['started_at_utc'] ?? '').toString(),
      'durationMin': (row['duration_min'] as num?)?.toInt() ?? 0,
      'reps': (row['reps'] as num?)?.toInt() ?? 0,
      'volume': (row['volume'] as num?)?.toDouble() ?? 0,
      'setsCount': (row['sets_count'] as num?)?.toInt() ?? 0,
      'methods': _decodeList(row['methods']),
      'createdAtUtc': (row['created_at_utc'] ?? '').toString(),
      'updatedAtUtc': (row['updated_at_utc'] ?? '').toString(),
      'deletedAtUtc': row['deleted_at_utc'],
    };
  }

  Map<String, dynamic> _setToJson(Map<String, Object?> row) {
    return <String, dynamic>{
      'id': (row['id'] ?? '').toString(),
      'userId': (row['user_id'] ?? '').toString(),
      'sessionId': row['session_id'],
      'exerciseName': (row['exercise_name'] ?? '').toString(),
      'setNo': (row['set_no'] as num?)?.toInt() ?? 1,
      'exerciseSetNo': (row['exercise_set_no'] as num?)?.toInt() ?? 1,
      'weightKg': (row['weight_kg'] as num?)?.toDouble() ?? 0,
      'reps': (row['reps'] as num?)?.toInt() ?? 0,
      'restS': (row['rest_s'] as num?)?.toInt() ?? 0,
      'inputMethod': (row['input_method'] ?? 'manual').toString(),
      'loggedAtUtc': (row['logged_at_utc'] ?? '').toString(),
      'createdAtUtc': (row['created_at_utc'] ?? '').toString(),
      'updatedAtUtc': (row['updated_at_utc'] ?? '').toString(),
      'deletedAtUtc': row['deleted_at_utc'],
    };
  }

  Map<String, dynamic> _programToJson(Map<String, Object?> row) {
    return <String, dynamic>{
      'id': (row['id'] ?? '').toString(),
      'userId': (row['user_id'] ?? '').toString(),
      'name': (row['name'] ?? '').toString(),
      'splitGroup': (row['split_group'] ?? '').toString(),
      'type': (row['type'] ?? '').toString(),
      'duration': (row['duration'] ?? '').toString(),
      'frequency': (row['frequency'] ?? '').toString(),
      'difficulty': (row['difficulty'] ?? '').toString(),
      'active': (row['active'] as int? ?? 0) == 1,
      'exercises': _decodeJson(row['exercises']) ?? const <dynamic>[],
      'createdAtUtc': (row['created_at_utc'] ?? '').toString(),
      'updatedAtUtc': (row['updated_at_utc'] ?? '').toString(),
      'deletedAtUtc': row['deleted_at_utc'],
    };
  }

  Map<String, dynamic> _accountToJson(Map<String, Object?> row) {
    return <String, dynamic>{
      'id': (row['id'] ?? '').toString(),
      'userId': (row['user_id'] ?? '').toString(),
      'email': (row['email'] ?? '').toString(),
      'username': (row['username'] ?? '').toString(),
      'passwordHash': (row['password_hash'] ?? '').toString(),
      'passwordSalt': (row['password_salt'] ?? '').toString(),
      'gender': (row['gender'] ?? 'Prefer not to say').toString(),
      'dobDay': (row['dob_day'] ?? '').toString(),
      'dobMonth': (row['dob_month'] ?? '').toString(),
      'dobYear': (row['dob_year'] ?? '').toString(),
      'weightKg': (row['weight_kg'] ?? '').toString(),
      'heightCm': (row['height_cm'] ?? '').toString(),
      'personalDetailsComplete':
          (row['personal_details_complete'] as int? ?? 0) == 1,
      'createdAt': (row['created_at'] ?? '').toString(),
      'createdAtUtc': (row['created_at_utc'] ?? '').toString(),
      'updatedAtUtc': (row['updated_at_utc'] ?? '').toString(),
      'deletedAtUtc': row['deleted_at_utc'],
    };
  }

  Map<String, Object?> _accountToRow(Map<String, dynamic> account, String now) {
    return <String, Object?>{
      'id': (account['id'] ?? '').toString(),
      'user_id': (account['userId'] ?? account['id'] ?? '').toString(),
      'email': (account['email'] ?? '').toString(),
      'username': (account['username'] ?? '').toString(),
      'password_hash': (account['passwordHash'] ?? '').toString(),
      'password_salt': (account['passwordSalt'] ?? '').toString(),
      'gender': (account['gender'] ?? 'Prefer not to say').toString(),
      'dob_day': (account['dobDay'] ?? '').toString(),
      'dob_month': (account['dobMonth'] ?? '').toString(),
      'dob_year': (account['dobYear'] ?? '').toString(),
      'weight_kg': (account['weightKg'] ?? '').toString(),
      'height_cm': (account['heightCm'] ?? '').toString(),
      'personal_details_complete':
          account['personalDetailsComplete'] == true ? 1 : 0,
      'created_at': (account['createdAt'] ?? '').toString(),
      'created_at_utc': (account['createdAtUtc'] ?? now).toString(),
      'updated_at_utc': (account['updatedAtUtc'] ?? now).toString(),
      'deleted_at_utc': account['deletedAtUtc'],
    };
  }
}

Map<String, dynamic>? _asMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  return null;
}

List<Map<String, dynamic>> _asMapList(Object? value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map<dynamic, dynamic>>()
      .map((Map<dynamic, dynamic> e) => e.cast<String, dynamic>())
      .toList(growable: false);
}

List<String> _decodeList(Object? value) {
  if (value is! String || value.isEmpty) return const <String>[];
  final Object? decoded = jsonDecode(value);
  if (decoded is! List) return const <String>[];
  return decoded.map((dynamic e) => e.toString()).toList(growable: false);
}

Object? _decodeJson(Object? value) {
  if (value is! String || value.isEmpty) return null;
  try {
    return jsonDecode(value);
  } on FormatException {
    return null;
  }
}
