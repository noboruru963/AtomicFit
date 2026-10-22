import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:atomfit/data/db/app_database.dart';
import 'package:atomfit/data/db/exercise_repository.dart';
import 'package:atomfit/data/db/legacy_migration.dart';
import 'package:atomfit/data/db/sqlite_store.dart';

Map<String, dynamic> _legacyDocument() => <String, dynamic>{
      'schemaVersion': 1,
      'seedVersion': 1,
      'user': <String, dynamic>{
        'id': 'u_alex_01',
        'userId': 'u_alex_01',
        'username': 'Alex',
        'email': 'alex@example.com',
        'gender': 'Male',
        'dobDay': '14',
        'dobMonth': 'May',
        'dobYear': '1998',
        'weightKg': '74',
        'heightCm': '178',
        'createdAt': 'October 2026',
        'createdAtUtc': '2026-10-18T00:00:00.000Z',
        'updatedAtUtc': '2026-10-18T00:00:00.000Z',
      },
      'settings': <String, dynamic>{
        'id': 'settings_u_alex_01',
        'userId': 'u_alex_01',
        'sensorAutoDetect': true,
        'voiceLogging': false,
        'hapticFeedback': true,
        'lockscreenWidget': false,
        'bellSound': true,
        'restNotifications': true,
        'createdAtUtc': '2026-10-18T00:00:00.000Z',
        'updatedAtUtc': '2026-10-18T00:00:00.000Z',
      },
      'isDarkMode': true,
      'isProgramAdjusted': false,
      'adjustmentFactor': 0.9,
      'catalogue': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'cat1',
          'userId': 'u_alex_01',
          'name': 'Barbell shoulder press',
          'category': 'Shoulders',
          'defaultKg': 30.0,
          'defaultReps': 8,
          'defaultSets': 3,
          'description': 'Overhead press with a barbell.',
          'isCustom': false,
          'createdAtUtc': '2026-10-18T00:00:00.000Z',
          'updatedAtUtc': '2026-10-18T00:00:00.000Z',
        },
        <String, dynamic>{
          'id': 'cat_custom_1',
          'userId': 'u_alex_01',
          'name': 'My custom move',
          'category': 'Custom',
          'defaultKg': 20.0,
          'defaultReps': 12,
          'defaultSets': 3,
          'description': 'Custom exercise added manually.',
          'isCustom': true,
          'createdAtUtc': '2026-10-18T00:00:00.000Z',
          'updatedAtUtc': '2026-10-18T00:00:00.000Z',
        },
      ],
      'programs': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 'p_push',
          'userId': 'u_alex_01',
          'name': 'Push Day',
          'splitGroup': 'Push Pull Leg',
          'type': 'Built-in',
          'duration': '35 min',
          'frequency': 'PPL Split • Day 1',
          'difficulty': 'Intermediate',
          'active': true,
          'exercises': <Map<String, dynamic>>[
            <String, dynamic>{
              'name': 'Chest press',
              'sets': 3,
              'reps': 8,
              'weightKg': 22.5,
            },
          ],
          'createdAtUtc': '2026-10-18T00:00:00.000Z',
          'updatedAtUtc': '2026-10-18T00:00:00.000Z',
        },
      ],
      'history': <Map<String, dynamic>>[
        <String, dynamic>{
          'id': 's_1',
          'userId': 'u_alex_01',
          'name': 'Push Day',
          'type': 'full',
          'dateLabel': 'Oct 18, 17:30',
          'dayOfMonth': 18,
          'startedAtUtc': '2026-10-18T17:30:00.000Z',
          'durationMin': 32,
          'reps': 10,
          'volume': 225.0,
          'setsCount': 1,
          'methods': <String>['manual'],
          'setsDetail': <Map<String, dynamic>>[
            <String, dynamic>{
              'id': 'set_1',
              'userId': 'u_alex_01',
              'exerciseName': 'Chest press',
              'setNo': 1,
              'exerciseSetNo': 1,
              'weightKg': 22.5,
              'reps': 10,
              'restS': 120,
              'inputMethod': 'manual',
              'loggedAtUtc': '2026-10-18T17:30:00.000Z',
              'createdAtUtc': '2026-10-18T17:30:00.000Z',
              'updatedAtUtc': '2026-10-18T17:30:00.000Z',
            },
          ],
          'children': <Map<String, dynamic>>[],
          'createdAtUtc': '2026-10-18T17:30:00.000Z',
          'updatedAtUtc': '2026-10-18T17:30:00.000Z',
        },
      ],
      'activeWorkout': <String, dynamic>{
        'programId': 'p_push',
        'sessionName': 'Push Day',
        'sessionType': 'full',
        'exercises': <Map<String, dynamic>>[],
        'currentExercise': 'Chest press',
        'weightInput': '22.5',
        'repsInput': 8,
        'inputMethod': 'manual',
        'restTotalSeconds': 120,
        'restSeconds': 120,
        'sets': <Map<String, dynamic>>[],
        'voiceSimText': '22.5 kg for 8 reps',
      },
    };

void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase appDatabase;
  late SqliteStore store;
  late SqliteExerciseRepository exercises;

  setUp(() async {
    appDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    store = SqliteStore(appDatabase);
    exercises = SqliteExerciseRepository(await appDatabase.database);
  });

  tearDown(() async {
    await appDatabase.close();
  });

  test('moves the legacy blob into the database', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'atomfit_app_v23': jsonEncode(_legacyDocument()),
    });

    final bool migrated = await LegacyMigration.run(
      appDatabase: appDatabase,
      store: store,
      exercises: exercises,
    );
    expect(migrated, isTrue);

    final Map<String, dynamic>? document = await store.read();
    expect(document, isNotNull);

    // The profile moved over.
    final Map<String, dynamic> user = document!['user'] as Map<String, dynamic>;
    expect(user['username'], 'Alex');
    expect(user['email'], 'alex@example.com');
    expect(user['gender'], 'Male');

    // The settings and the theme moved over.
    expect(document['isDarkMode'], isTrue);
    final Map<String, dynamic> settings =
        document['settings'] as Map<String, dynamic>;
    expect(settings['voiceLogging'], isFalse);
    expect(settings['bellSound'], isTrue);

    // The programs and the history moved over.
    expect(document['programs'], hasLength(1));
    expect(document['history'], hasLength(1));
    final Map<String, dynamic> session =
        (document['history'] as List<dynamic>).first as Map<String, dynamic>;
    expect(session['id'], 's_1');
    expect(session['setsDetail'], hasLength(1));

    // The active workout draft moved over.
    final Map<String, dynamic> draft =
        document['activeWorkout'] as Map<String, dynamic>;
    expect(draft['currentExercise'], 'Chest press');
  });

  test('keeps the custom exercises and drops the built-in catalogue', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'atomfit_app_v23': jsonEncode(_legacyDocument()),
    });
    await LegacyMigration.run(
      appDatabase: appDatabase,
      store: store,
      exercises: exercises,
    );

    expect(await exercises.count(), 1);
    expect(await exercises.countCatalogue(), 0);
    final List<dynamic> all = await exercises.loadAll();
    expect(all.single.id, 'cat_custom_1');
  });

  test('the migrated account can sign in with the demo password', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'atomfit_app_v23': jsonEncode(_legacyDocument()),
    });
    await LegacyMigration.run(
      appDatabase: appDatabase,
      store: store,
      exercises: exercises,
    );

    final Map<String, dynamic>? document = await store.read();
    final List<dynamic> accounts = document!['accounts'] as List<dynamic>;
    final Iterable<Map<String, dynamic>> rows =
        accounts.whereType<Map<String, dynamic>>();

    final Map<String, dynamic> alex = rows.firstWhere(
      (Map<String, dynamic> a) => a['id'] == 'u_alex_01',
    );
    expect(alex['passwordHash'], isNotEmpty);
    expect(alex['passwordHash'].toString().contains('password123'), isFalse);

    // The second demo account is created as well.
    expect(
      rows.any((Map<String, dynamic> a) => a['id'] == 'u_joe_01'),
      isTrue,
    );
  });

  test('the migration only runs once', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'atomfit_app_v23': jsonEncode(_legacyDocument()),
    });

    expect(
      await LegacyMigration.run(
        appDatabase: appDatabase,
        store: store,
        exercises: exercises,
      ),
      isTrue,
    );
    expect(
      await LegacyMigration.run(
        appDatabase: appDatabase,
        store: store,
        exercises: exercises,
      ),
      isFalse,
    );
  });

  test('a fresh install without legacy data is left alone', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    expect(
      await LegacyMigration.run(
        appDatabase: appDatabase,
        store: store,
        exercises: exercises,
      ),
      isFalse,
    );
    expect(await store.read(), isNull);
  });

  test('a corrupt legacy blob is ignored', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'atomfit_app_v23': 'not json',
    });
    expect(
      await LegacyMigration.run(
        appDatabase: appDatabase,
        store: store,
        exercises: exercises,
      ),
      isFalse,
    );
    expect(await store.read(), isNull);
  });
}
