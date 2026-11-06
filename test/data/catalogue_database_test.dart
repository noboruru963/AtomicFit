import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:atomfit/data/db/app_database.dart';
import 'package:atomfit/data/db/catalogue_loader.dart';
import 'package:atomfit/data/db/exercise_repository.dart';
import 'package:atomfit/models/app_models.dart';

/// Runs the **real** RepDB catalogue through SQLite — the same 650 records
/// the app ships, queried the way the Discover screen queries them.
void main() {
  setUpAll(sqfliteFfiInit);

  late AppDatabase appDatabase;
  late SqliteExerciseRepository exercises;

  setUp(() async {
    appDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    exercises = SqliteExerciseRepository(await appDatabase.database);
  });

  tearDown(() async {
    await appDatabase.close();
  });

  Future<void> importCatalogue() async {
    final List<Exercise> catalogue = CatalogueLoader.parse(
      File('assets/data/exercise_catalogue.json').readAsStringSync(),
    );
    await exercises.upsertAll(catalogue);
  }

  test('the whole dataset is queryable', () async {
    await importCatalogue();
    expect(await exercises.countCatalogue(), 650);
  });

  test('a name search finds the exercise', () async {
    await importCatalogue();
    final List<Exercise> results =
        await exercises.search(query: 'barbell squat');
    expect(results, isNotEmpty);
    // Every hit carries both tokens of the query.
    for (final Exercise exercise in results) {
      final String haystack =
          '${exercise.name} ${exercise.searchIndex}'.toLowerCase();
      expect(haystack, contains('barbell'));
      expect(haystack, contains('squat'));
    }
    expect(
      results.map((Exercise e) => e.id),
      contains('barbell-bulgarian-split-squat'),
    );
  });

  test('a search covers muscles, equipment and body parts', () async {
    await importCatalogue();
    expect(await exercises.search(query: 'latissimus'), isNotEmpty);
    expect(await exercises.search(query: 'pull up bar'), isNotEmpty);
    expect(await exercises.search(query: 'cardio'), isNotEmpty);
  });

  test('every token of a search has to match', () async {
    await importCatalogue();
    expect(await exercises.search(query: 'barbell squat'), isNotEmpty);
    expect(await exercises.search(query: 'barbell unicorn'), isEmpty);
  });

  test('a body part filter narrows the dataset', () async {
    await importCatalogue();
    final List<Exercise> chest =
        await exercises.search(bodyPartFilter: 'Chest');
    expect(chest, isNotEmpty);
    for (final Exercise exercise in chest) {
      expect(exercise.bodyPartLabel, 'Chest');
    }
  });

  test('the stretching filter also catches the mobility records', () async {
    await importCatalogue();
    final List<Exercise> mobility =
        await exercises.search(bodyPartFilter: 'Stretching / Mobility');
    expect(mobility, isNotEmpty);
  });

  test('the result count matches the filtered rows', () async {
    await importCatalogue();
    final int chest = await exercises.count(bodyPartFilter: 'Chest');
    final List<Exercise> chestRows =
        await exercises.search(bodyPartFilter: 'Chest', limit: 0);
    expect(chestRows, hasLength(chest));
  });

  test('the pagination walks through the whole result set', () async {
    await importCatalogue();
    final int total = await exercises.count(bodyPartFilter: 'Back');
    expect(total, greaterThan(60));

    final List<Exercise> firstPage =
        await exercises.search(bodyPartFilter: 'Back', limit: 60);
    expect(firstPage, hasLength(60));

    final List<Exercise> secondPage = await exercises.search(
      bodyPartFilter: 'Back',
      limit: 60,
      offset: 60,
    );
    expect(secondPage, isNotEmpty);
    expect(
      secondPage.first.id,
      isNot(firstPage.first.id),
      reason: 'the second page continues where the first one stopped',
    );
  });

  test('an exercise can be read back with all its fields', () async {
    await importCatalogue();
    final Exercise? exercise = await exercises.byId('archer-pull-ups');
    expect(exercise, isNotNull);
    expect(exercise!.name, 'Archer Pull Ups');
    expect(exercise.bodyPartLabel, 'Back');
    expect(exercise.primaryMuscles, isNotEmpty);
    expect(exercise.instructions, isNotEmpty);
    expect(exercise.tips, isNotEmpty);
    expect(exercise.images['start'], isNotNull);
    expect(exercise.searchIndex, isNotEmpty);
  });
}
