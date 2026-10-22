import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../../models/app_models.dart';

/// Read/write access to the exercise catalogue.
///
/// The Discover screen needs three things from the catalogue: a filtered and
/// searched result list, the total number of matches, and a single exercise
/// by id. All three are answered by SQL so the 650 record dataset never has
/// to be scanned in Dart.
abstract class ExerciseRepository {
  /// Every exercise, ordered by name.
  Future<List<Exercise>> loadAll();

  /// One exercise by its catalogue id.
  Future<Exercise?> byId(String id);

  /// The exercises matching [query] and [bodyPartFilter].
  ///
  /// [limit] of 0 returns every match.
  Future<List<Exercise>> search({
    String query = '',
    String bodyPartFilter = 'All',
    int limit = 60,
    int offset = 0,
  });

  /// How many exercises match [query] and [bodyPartFilter].
  Future<int> count({String query = '', String bodyPartFilter = 'All'});

  /// How many catalogue exercises (the ones that are not user-created) exist.
  Future<int> countCatalogue();

  /// Inserts or updates a single exercise.
  Future<void> upsert(Exercise exercise);

  /// Inserts or updates many exercises in one transaction.
  Future<void> upsertAll(List<Exercise> exercises);

  /// Soft deletes an exercise.
  Future<void> softDelete(String id);
}

/// SQLite backed [ExerciseRepository].
class SqliteExerciseRepository implements ExerciseRepository {
  SqliteExerciseRepository(this._database);

  final Database _database;

  @override
  Future<List<Exercise>> loadAll() async {
    final List<Map<String, Object?>> rows = await _database.query(
      'exercises',
      where: 'deleted_at_utc IS NULL',
      orderBy: 'name COLLATE NOCASE ASC',
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<Exercise?> byId(String id) async {
    final List<Map<String, Object?>> rows = await _database.query(
      'exercises',
      where: 'id = ? AND deleted_at_utc IS NULL',
      whereArgs: <Object?>[id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<List<Exercise>> search({
    String query = '',
    String bodyPartFilter = 'All',
    int limit = 60,
    int offset = 0,
  }) async {
    final _Where where = _buildWhere(query, bodyPartFilter);
    final List<Object?> args = <Object?>[...where.args];
    final StringBuffer sql = StringBuffer('SELECT * FROM exercises')
      ..write(where.clause)
      ..write(' ORDER BY name COLLATE NOCASE ASC');
    if (limit > 0) {
      sql.write(' LIMIT ? OFFSET ?');
      args
        ..add(limit)
        ..add(offset);
    }
    final List<Map<String, Object?>> rows = await _database.rawQuery(
      sql.toString(),
      args,
    );
    return rows.map(_fromRow).toList(growable: false);
  }

  @override
  Future<int> count({String query = '', String bodyPartFilter = 'All'}) async {
    final _Where where = _buildWhere(query, bodyPartFilter);
    final List<Map<String, Object?>> rows = await _database.rawQuery(
      'SELECT COUNT(*) AS total FROM exercises${where.clause}',
      where.args,
    );
    if (rows.isEmpty) return 0;
    final Object? total = rows.first['total'];
    return total is int ? total : 0;
  }

  @override
  Future<int> countCatalogue() async {
    final List<Map<String, Object?>> rows = await _database.rawQuery(
      'SELECT COUNT(*) AS total FROM exercises '
      'WHERE deleted_at_utc IS NULL AND is_custom = 0',
    );
    if (rows.isEmpty) return 0;
    final Object? total = rows.first['total'];
    return total is int ? total : 0;
  }

  @override
  Future<void> upsert(Exercise exercise) async {
    await _database.insert(
      'exercises',
      _toRow(exercise),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> upsertAll(List<Exercise> exercises) async {
    if (exercises.isEmpty) return;
    final Batch batch = _database.batch();
    for (final Exercise exercise in exercises) {
      batch.insert(
        'exercises',
        _toRow(exercise),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> softDelete(String id) async {
    await _database.update(
      'exercises',
      <String, Object?>{
        'deleted_at_utc': DateTime.now().toUtc().toIso8601String()
      },
      where: 'id = ?',
      whereArgs: <Object?>[id],
    );
  }

  _Where _buildWhere(String query, String bodyPartFilter) {
    final List<String> clauses = <String>['deleted_at_utc IS NULL'];
    final List<Object?> args = <Object?>[];

    final String filter = bodyPartFilter.trim();
    if (filter.isNotEmpty && filter != 'All') {
      if (filter == 'Stretching / Mobility') {
        clauses.add(
          "(body_part_label = ? OR exercise_category = ? "
          "OR goals LIKE ? OR tags LIKE ? OR tags LIKE ?)",
        );
        args
          ..add('Stretching / Mobility')
          ..add('stretching')
          ..add('%mobility%')
          ..add('%stretching%')
          ..add('%mobility%');
      } else {
        clauses.add('body_part_label = ?');
        args.add(filter);
      }
    }

    final List<String> tokens = query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((String token) => token.isNotEmpty)
        .toList(growable: false);
    for (final String token in tokens) {
      clauses.add('search_index LIKE ?');
      args.add('%$token%');
    }

    final String clause =
        clauses.isEmpty ? '' : ' WHERE ${clauses.join(' AND ')}';
    return _Where(clause, args);
  }

  Map<String, Object?> _toRow(Exercise exercise) => <String, Object?>{
        'id': exercise.id,
        'user_id': exercise.userId,
        'name': exercise.name,
        'name_en': exercise.nameEn,
        'description': exercise.description,
        'description_en': exercise.descriptionEn,
        'body_part': exercise.bodyPart,
        'body_part_label': exercise.bodyPartLabel,
        'category': exercise.category,
        'exercise_category': exercise.exerciseCategory,
        'equipment': exercise.equipment,
        'difficulty': exercise.difficulty,
        'primary_muscles': jsonEncode(exercise.primaryMuscles),
        'secondary_muscles': jsonEncode(exercise.secondaryMuscles),
        'goals': jsonEncode(exercise.goals),
        'tags': jsonEncode(exercise.tags),
        'instructions': jsonEncode(exercise.instructions),
        'tips': jsonEncode(exercise.tips),
        'images': jsonEncode(exercise.images),
        'is_bodyweight': exercise.isBodyweight ? 1 : 0,
        'is_unilateral': exercise.isUnilateral ? 1 : 0,
        'met': exercise.met,
        'mechanic': exercise.mechanic,
        'force_type': exercise.forceType,
        'variation_group': exercise.variationGroup,
        'default_kg': exercise.defaultKg,
        'default_reps': exercise.defaultReps,
        'default_sets': exercise.defaultSets,
        'is_custom': exercise.isCustom ? 1 : 0,
        'search_index': exercise.searchIndex,
        'created_at_utc': exercise.createdAtUtc,
        'updated_at_utc': exercise.updatedAtUtc,
        'deleted_at_utc': exercise.deletedAtUtc,
      };

  Exercise _fromRow(Map<String, Object?> row) => Exercise(
        id: (row['id'] ?? '').toString(),
        userId: (row['user_id'] ?? '').toString(),
        name: (row['name'] ?? '').toString(),
        nameEn: (row['name_en'] ?? '').toString(),
        description: (row['description'] ?? '').toString(),
        descriptionEn: (row['description_en'] ?? '').toString(),
        bodyPart: (row['body_part'] ?? '').toString(),
        bodyPartLabel: (row['body_part_label'] ?? '').toString(),
        category: (row['category'] ?? '').toString(),
        exerciseCategory: (row['exercise_category'] ?? '').toString(),
        equipment: (row['equipment'] ?? '').toString(),
        difficulty: (row['difficulty'] ?? '').toString(),
        primaryMuscles: _decodeList(row['primary_muscles']),
        secondaryMuscles: _decodeList(row['secondary_muscles']),
        goals: _decodeList(row['goals']),
        tags: _decodeList(row['tags']),
        instructions: _decodeList(row['instructions']),
        tips: _decodeList(row['tips']),
        images: _decodeMap(row['images']),
        isBodyweight: (row['is_bodyweight'] as int? ?? 0) == 1,
        isUnilateral: (row['is_unilateral'] as int? ?? 0) == 1,
        met: row['met'] == null ? null : (row['met'] as num).toDouble(),
        mechanic: (row['mechanic'] ?? '').toString(),
        forceType: (row['force_type'] ?? '').toString(),
        variationGroup: (row['variation_group'] ?? '').toString(),
        defaultKg: (row['default_kg'] as num? ?? 0).toDouble(),
        defaultReps: (row['default_reps'] as int? ?? 10).toInt(),
        defaultSets: (row['default_sets'] as int? ?? 3).toInt(),
        isCustom: (row['is_custom'] as int? ?? 0) == 1,
        searchIndex: (row['search_index'] ?? '').toString(),
        createdAtUtc: (row['created_at_utc'] ?? '').toString(),
        updatedAtUtc: (row['updated_at_utc'] ?? '').toString(),
        deletedAtUtc: row['deleted_at_utc']?.toString(),
      );
}

class _Where {
  const _Where(this.clause, this.args);

  final String clause;
  final List<Object?> args;
}

List<String> _decodeList(Object? value) {
  if (value is! String || value.isEmpty) return const <String>[];
  final Object? decoded = jsonDecode(value);
  if (decoded is! List) return const <String>[];
  return decoded
      .map((dynamic e) => e.toString())
      .where((String e) => e.isNotEmpty)
      .toList(growable: false);
}

Map<String, dynamic> _decodeMap(Object? value) {
  if (value is! String || value.isEmpty) return const <String, dynamic>{};
  final Object? decoded = jsonDecode(value);
  if (decoded is! Map) return const <String, dynamic>{};
  return decoded
      .map((dynamic key, dynamic e) =>
          MapEntry<String, dynamic>(key.toString(), e))
      .cast<String, dynamic>();
}
