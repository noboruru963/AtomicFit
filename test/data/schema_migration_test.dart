import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:atomfit/data/db/app_database.dart';
import 'package:atomfit/data/db/schema.dart';

/// BA-011: the back exercise is called "Lat pulldown". A database written by
/// the first release still holds the old name, so the upgrade has to rename it
/// in the catalogue, in the built-in programs, in the logged sets and in the
/// workout that was left in progress.
void main() {
  sqfliteFfiInit();

  group('schema migrations', () {
    late Directory tempDir;
    late String dbPath;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('atomfit_migration');
      dbPath = '${tempDir.path}${Platform.pathSeparator}atomfit.db';
    });

    tearDown(() {
      if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
    });

    test('renames the back exercise in a version 1 database', () async {
      // A database created by the first release.
      final Database old = await databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (Database db, int version) async {
            for (final String statement in kCreateStatements) {
              await db.execute(statement);
            }
            for (final String statement in kCreateIndexes) {
              await db.execute(statement);
            }
          },
        ),
      );

      const String stamp = '2026-10-18T00:00:00.000Z';
      await old.insert('exercises', <String, Object?>{
        'id': 'cat7',
        'name': 'Lateral pushdown',
        'description': 'Cable or band lateral pushdown for triceps and lats.',
        'category': 'Arms',
        'search_index': 'lateral pushdown arms',
        'created_at_utc': stamp,
        'updated_at_utc': stamp,
      });
      await old.insert('programs', <String, Object?>{
        'id': 'p_push',
        'name': 'Push Day',
        'exercises':
            '[{"name":"Chest press","sets":3,"reps":8,"weightKg":22.5},'
                '{"name":"Lateral pushdown","sets":3,"reps":12,"weightKg":18}]',
        'created_at_utc': stamp,
        'updated_at_utc': stamp,
      });
      await old.insert('set_logs', <String, Object?>{
        'id': 'set-1',
        'exercise_name': 'Lateral pushdown',
        'weight_kg': 18.0,
        'reps': 12,
        'created_at_utc': stamp,
        'updated_at_utc': stamp,
      });
      await old.insert('app_state', <String, Object?>{
        'key': 'activeWorkout',
        'value': '{"exerciseName":"Lateral pushdown","reps":4}',
        'updated_at_utc': stamp,
      });
      await old.close();

      // Reopening through [AppDatabase] applies the upgrade.
      final AppDatabase upgraded =
          AppDatabase(factory: databaseFactoryFfi, path: dbPath);
      final Database db = await upgraded.database;

      expect(await db.getVersion(), initialSchemaVersion);

      final Map<String, Object?> exercise = (await db.query(
        'exercises',
        where: 'id = ?',
        whereArgs: <Object?>['cat7'],
      ))
          .single;
      expect(exercise['name'], 'Lat pulldown');
      expect(exercise['category'], 'Back');
      expect(exercise['description'], isNot(contains('Lateral pushdown')));
      expect(exercise['search_index'], contains('lat pulldown'));

      final Map<String, Object?> program = (await db.query('programs',
              where: 'id = ?', whereArgs: <Object?>['p_push']))
          .single;
      expect(program['exercises'], contains('Lat pulldown'));
      expect(program['exercises'], isNot(contains('Lateral pushdown')));

      final Map<String, Object?> log = (await db.query(
        'set_logs',
        where: 'id = ?',
        whereArgs: <Object?>['set-1'],
      ))
          .single;
      expect(log['exercise_name'], 'Lat pulldown');

      final Map<String, Object?> state = (await db.query(
        'app_state',
        where: 'key = ?',
        whereArgs: <Object?>['activeWorkout'],
      ))
          .single;
      expect(state['value'], contains('Lat pulldown'));
      expect(state['value'], isNot(contains('Lateral pushdown')));

      await upgraded.close();
    });

    test('leaves a database without the old name untouched', () async {
      final Database old = await databaseFactoryFfi.openDatabase(
        dbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (Database db, int version) async {
            for (final String statement in kCreateStatements) {
              await db.execute(statement);
            }
          },
        ),
      );
      await old.close();

      final AppDatabase upgraded =
          AppDatabase(factory: databaseFactoryFfi, path: dbPath);
      final Database db = await upgraded.database;
      expect(await db.getVersion(), initialSchemaVersion);
      expect(await db.query('exercises'), isEmpty);
      await upgraded.close();
    });
  });
}
