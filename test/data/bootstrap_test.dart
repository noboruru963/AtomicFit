import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:atomfit/data/db/app_database.dart';
import 'package:atomfit/data/db/bootstrap.dart';
import 'package:atomfit/data/db/exercise_repository.dart';
import 'package:atomfit/data/db/sqlite_store.dart';
import 'package:atomfit/state/app_state.dart';

/// Walks the startup sequence of `main()`: open the database, import the
/// catalogue, load the state.
void main() {
  // The catalogue is read through the asset bundle.
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(sqfliteFfiInit);

  late AppDatabase appDatabase;
  late SqliteExerciseRepository exercises;
  late SqliteStore store;

  setUp(() async {
    appDatabase = AppDatabase(
      factory: databaseFactoryFfi,
      path: inMemoryDatabasePath,
    );
    exercises = SqliteExerciseRepository(await appDatabase.database);
    store = SqliteStore(appDatabase);
  });

  tearDown(() async {
    await appDatabase.close();
  });

  test('a fresh install comes up with the catalogue and the demo accounts',
      () async {
    final int imported = await DatabaseBootstrap.ensureCatalogue(exercises);
    expect(imported, 650);

    final AppState state = AppState(store: store, exercises: exercises);
    await state.load();

    expect(state.isLoaded, isTrue);
    expect(state.catalogue, hasLength(650));
    expect(state.accounts, hasLength(2));
    expect(state.programs, hasLength(7));
    expect(state.history, hasLength(4));
    expect(state.isLoggedIn, isFalse);
    expect(state.getActiveProgram()?.name, 'Push Day');
  });

  test('the catalogue is imported only once', () async {
    expect(await DatabaseBootstrap.ensureCatalogue(exercises), 650);
    expect(await DatabaseBootstrap.ensureCatalogue(exercises), 0);
    expect(await exercises.countCatalogue(), 650);
  });

  test('the demo accounts can sign in after the boot', () async {
    await DatabaseBootstrap.ensureCatalogue(exercises);
    final AppState state = AppState(store: store, exercises: exercises);
    await state.load();

    expect(
      state.login(identifier: 'joe@example.com', password: 'password123'),
      isNull,
    );
    expect(state.isLoggedIn, isTrue);
    expect(state.user.username, 'Joe123');

    expect(
      state.login(identifier: 'Joe123', password: 'password123'),
      isNull,
    );

    // The sign-in persists in the background; wait for it before teardown.
    await state.pendingWrite;
  });

  test('the state survives a restart of the app', () async {
    await DatabaseBootstrap.ensureCatalogue(exercises);
    final AppState first = AppState(store: store, exercises: exercises);
    await first.load();
    first.setThemeExplicit(true);
    first.login(identifier: 'joe@example.com', password: 'password123');
    await first.persist();

    final AppState second = AppState(store: store, exercises: exercises);
    await second.load();
    expect(second.isDarkMode, isTrue);
    expect(second.isLoggedIn, isTrue);
    expect(second.user.username, 'Joe123');
    expect(second.catalogue, hasLength(650));
    expect(second.programs, hasLength(7));
  });

  test('a logged set is stored in the database', () async {
    await DatabaseBootstrap.ensureCatalogue(exercises);
    final AppState state = AppState(store: store, exercises: exercises);
    await state.load();

    state.updateWeightInput('22.5');
    state.updateRepsInput(10);
    expect(state.logCurrentSet(), isNull);
    await state.persist();

    final AppState second = AppState(store: store, exercises: exercises);
    await second.load();
    expect(second.activeWorkout.sets, hasLength(1));
    expect(second.activeWorkout.sets.first.weightKg, 22.5);
    expect(second.activeWorkout.sets.first.reps, 10);
  });
}
