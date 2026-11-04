import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'schema.dart';

/// Opens and migrates the AtomFit SQLite database.
///
/// The factory and the path are injectable so tests can run against an
/// in-memory database (`sqflite_common_ffi`) while the app uses the platform
/// implementation on the device.
class AppDatabase {
  AppDatabase({DatabaseFactory? factory, String? path})
      : _factory = factory,
        _path = path;

  final DatabaseFactory? _factory;
  final String? _path;

  Database? _database;

  /// The database factory in use.
  DatabaseFactory get factory => _factory ?? databaseFactory;

  /// The open database. Opening it twice returns the same instance.
  Future<Database> get database async {
    final Database? existing = _database;
    if (existing != null) return existing;
    final Database opened = await _open();
    _database = opened;
    return opened;
  }

  Future<Database> _open() async {
    final DatabaseFactory dbFactory = factory;
    final String dbPath =
        _path ?? p.join(await dbFactory.getDatabasesPath(), kDatabaseName);
    return dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: initialSchemaVersion,
        onCreate: (Database db, int version) async {
          await _createAll(db);
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          await _migrate(db, oldVersion, newVersion);
        },
      ),
    );
  }

  Future<void> _createAll(Database db) async {
    final Batch batch = db.batch();
    for (final String statement in kCreateStatements) {
      batch.execute(statement);
    }
    for (final String statement in kCreateIndexes) {
      batch.execute(statement);
    }
    await batch.commit(noResult: true);
  }

  /// Applies [migrationSteps] from `oldVersion` to `newVersion`.
  ///
  /// Each step runs statement by statement (not as one batch) so a single
  /// "duplicate column" can be tolerated: SQLite has no
  /// `ALTER TABLE ... ADD COLUMN IF NOT EXISTS`, and a database that was
  /// created by a newer build may already carry the column the step adds.
  Future<void> _migrate(Database db, int oldVersion, int newVersion) async {
    for (int version = oldVersion; version < newVersion; version++) {
      final int step = version;
      if (step < 0 || step >= migrationSteps.length) continue;
      for (final String statement in migrationSteps[step]) {
        try {
          await db.execute(statement);
        } on DatabaseException catch (error) {
          if (!error.isDuplicateColumnError()) rethrow;
        }
      }
    }
  }

  /// Closes the database (used by tests and by the "reset demo data" action).
  Future<void> close() async {
    final Database? existing = _database;
    _database = null;
    await existing?.close();
  }
}
