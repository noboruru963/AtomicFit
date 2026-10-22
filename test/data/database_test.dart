import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:atomfit/data/db/app_database.dart';
import 'package:atomfit/data/db/exercise_repository.dart';
import 'package:atomfit/data/db/schema.dart';
import 'package:atomfit/data/db/sqlite_store.dart';
import 'package:atomfit/models/app_models.dart';

void main() {
  // The FFI implementation of sqflite runs the tests against an in-memory
  // SQLite database.
  sqfliteFfiInit();

  group('database', () {
    late AppDatabase appDatabase;
    late SqliteExerciseRepository exercises;
    late SqliteStore store;

    setUp(() async {
      appDatabase = AppDatabase(
        factory: databaseFactoryFfi,
        path: inMemoryDatabasePath,
      );
      final Database database = await appDatabase.database;
      exercises = SqliteExerciseRepository(database);
      store = SqliteStore(appDatabase);
    });

    tearDown(() async {
      await appDatabase.close();
    });

    test('creates every table', () async {
      final Database database = await appDatabase.database;
      final List<String> names = await database.rawQuery(
          'SELECT name FROM sqlite_master WHERE type = ?', <Object?>[
        'table'
      ]).then((List<Map<String, Object?>> rows) => rows
          .map((Map<String, Object?> row) => row['name'].toString())
          .toList());
      for (final String table in kTables) {
        expect(names, contains(table));
      }
    });

    test('stores and reads the exercise catalogue', () async {
      await exercises.upsertAll(_sampleExercises());
      expect(await exercises.count(), 3);

      final Exercise? back = await exercises.byId('ex-back');
      expect(back?.name, 'Barbell Row');
      expect(back?.primaryMuscles, <String>['latissimus_dorsi']);

      final List<Exercise> chestOnly = await exercises.search(
        bodyPartFilter: 'Chest',
      );
      expect(chestOnly, hasLength(1));
      expect(chestOnly.first.id, 'ex-chest');

      final List<Exercise> bySearch = await exercises.search(query: 'row');
      expect(bySearch, hasLength(1));

      final List<Exercise> paged = await exercises.search(limit: 2);
      expect(paged, hasLength(2));
      expect(await exercises.count(), 3);
    });

    test('soft deleted exercises disappear', () async {
      await exercises.upsertAll(_sampleExercises());
      await exercises.softDelete('ex-chest');
      expect(await exercises.count(), 2);
      expect(await exercises.byId('ex-chest'), isNull);
    });

    test('the document survives a round trip', () async {
      await store.write(<String, dynamic>{
        'schemaVersion': 1,
        'seedVersion': 1,
        'user': <String, dynamic>{
          'id': 'u_1',
          'userId': 'u_1',
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
        'accounts': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'u_1',
            'userId': 'u_1',
            'username': 'Alex',
            'email': 'alex@example.com',
            'passwordHash': 'hash-value',
            'passwordSalt': 'salt-value',
            'gender': 'Male',
            'dobDay': '14',
            'dobMonth': 'May',
            'dobYear': '1998',
            'weightKg': '74',
            'heightCm': '178',
            'personalDetailsComplete': true,
            'createdAt': 'October 2026',
            'createdAtUtc': '2026-10-18T00:00:00.000Z',
            'updatedAtUtc': '2026-10-18T00:00:00.000Z',
          },
        ],
        'isLoggedIn': true,
        'isDarkMode': true,
        'settings': <String, dynamic>{
          'id': 'settings_u_1',
          'userId': 'u_1',
          'sensorAutoDetect': true,
          'voiceLogging': false,
          'hapticFeedback': true,
          'lockscreenWidget': false,
          'bellSound': true,
          'restNotifications': true,
          'createdAtUtc': '2026-10-18T00:00:00.000Z',
          'updatedAtUtc': '2026-10-18T00:00:00.000Z',
        },
        'programs': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'p_push',
            'userId': 'u_1',
            'name': 'Push Day',
            'splitGroup': 'Push Pull Leg',
            'type': 'Built-in',
            'duration': '35 min',
            'frequency': '3 days/wk',
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
            'userId': 'u_1',
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
                'userId': 'u_1',
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
      });

      final Map<String, dynamic>? document = await store.read();
      expect(document, isNotNull);
      expect(document!['isLoggedIn'], isTrue);
      expect(document['isDarkMode'], isTrue);

      final Map<String, dynamic> user =
          document['user'] as Map<String, dynamic>;
      expect(user['username'], 'Alex');
      expect(user['email'], 'alex@example.com');

      final List<dynamic> accounts = document['accounts'] as List<dynamic>;
      expect(accounts, hasLength(1));
      expect(
        (accounts.first as Map<String, dynamic>)['passwordHash'],
        'hash-value',
      );

      final List<dynamic> programs = document['programs'] as List<dynamic>;
      expect(programs, hasLength(1));
      expect((programs.first as Map<String, dynamic>)['name'], 'Push Day');

      final List<dynamic> history = document['history'] as List<dynamic>;
      expect(history, hasLength(1));
      final Map<String, dynamic> session =
          history.first as Map<String, dynamic>;
      expect(session['setsCount'], 1);
      expect(session['setsDetail'], hasLength(1));
    });

    test('writing the same document twice does not duplicate rows', () async {
      final Map<String, dynamic> document = <String, dynamic>{
        'history': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 's_1',
            'userId': 'u_1',
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
            'setsDetail': <Map<String, dynamic>>[],
            'children': <Map<String, dynamic>>[],
            'createdAtUtc': '2026-10-18T17:30:00.000Z',
            'updatedAtUtc': '2026-10-18T17:30:00.000Z',
          },
        ],
      };
      await store.write(document);
      await store.write(document);

      final Map<String, dynamic>? restored = await store.read();
      expect(restored!['history'], hasLength(1));
    });

    test('an empty database reads as "no data yet"', () async {
      expect(await store.read(), isNull);
    });
  });
}

List<Exercise> _sampleExercises() {
  const String now = '2026-10-18T00:00:00.000Z';
  return <Exercise>[
    const Exercise(
      id: 'ex-chest',
      userId: '',
      name: 'Bench Press',
      category: 'Chest',
      bodyPart: 'chest',
      bodyPartLabel: 'Chest',
      defaultKg: 40,
      defaultReps: 8,
      defaultSets: 3,
      description: 'Horizontal barbell press.',
      isCustom: false,
      searchIndex: 'bench press chest horizontal barbell',
      createdAtUtc: now,
      updatedAtUtc: now,
    ),
    const Exercise(
      id: 'ex-back',
      userId: '',
      name: 'Barbell Row',
      category: 'Back',
      bodyPart: 'back',
      bodyPartLabel: 'Back',
      primaryMuscles: <String>['latissimus_dorsi'],
      defaultKg: 30,
      defaultReps: 10,
      defaultSets: 3,
      description: 'Bent over barbell row.',
      isCustom: false,
      searchIndex: 'barbell row back bent over latissimus dorsi',
      createdAtUtc: now,
      updatedAtUtc: now,
    ),
    const Exercise(
      id: 'ex-arms',
      userId: '',
      name: 'Dumbbell Curl',
      category: 'Upper Arms',
      bodyPart: 'upper_arms',
      bodyPartLabel: 'Upper Arms',
      defaultKg: 15,
      defaultReps: 10,
      defaultSets: 3,
      description: 'Bicep curl with dumbbells.',
      isCustom: false,
      searchIndex: 'dumbbell curl upper arms bicep',
      createdAtUtc: now,
      updatedAtUtc: now,
    ),
  ];
}
