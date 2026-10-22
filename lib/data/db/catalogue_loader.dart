import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../../models/app_models.dart';
import 'catalogue.dart';

/// Parses the RepDB catalogue asset into [Exercise] records.
///
/// The asset (`assets/data/exercise_catalogue.json`) is the 650 record dataset
/// extracted from the prototype's `DEFAULT_CATALOGUE`
/// (`index.html` line 600, RepDB free tier).
class CatalogueLoader {
  const CatalogueLoader._();

  /// Asset path of the bundled catalogue.
  static const String assetPath = 'assets/data/exercise_catalogue.json';

  /// Reads the catalogue from the app bundle.
  static Future<List<Exercise>> loadFromAsset({String path = assetPath}) async {
    final String raw = await rootBundle.loadString(path);
    return parse(raw);
  }

  /// Parses a catalogue JSON payload.
  static List<Exercise> parse(String raw) {
    final Object? decoded = jsonDecode(raw);
    if (decoded is! List) return const <Exercise>[];
    final String now = DateTime.now().toUtc().toIso8601String();
    final List<Exercise> exercises = <Exercise>[];
    for (final dynamic entry in decoded) {
      if (entry is! Map) continue;
      final Exercise? exercise = fromRecord(
        entry.cast<String, dynamic>(),
        timestamp: now,
      );
      if (exercise != null) exercises.add(exercise);
    }
    return exercises;
  }

  /// Converts one catalogue record into an [Exercise].
  static Exercise? fromRecord(
    Map<String, dynamic> json, {
    String timestamp = '',
  }) {
    final String id = (json['id'] ?? '').toString();
    if (id.isEmpty) return null;
    final String now = timestamp.isEmpty
        ? DateTime.now().toUtc().toIso8601String()
        : timestamp;

    final String name = (json['name'] ?? '').toString();
    final String nameEn = (json['name_en'] ?? name).toString();
    final String description = (json['description'] ?? '').toString();
    final String descriptionEn =
        (json['description_en'] ?? description).toString();
    final String bodyPart = (json['body_part'] ?? '').toString();
    final List<String> primaryMuscles = _strings(json['primary_muscles']);
    final List<String> secondaryMuscles = _strings(json['secondary_muscles']);
    final List<String> goals = _strings(json['goals']);
    final List<String> tags = _strings(json['tags']);
    final String equipment = (json['equipment'] ?? '').toString();
    final bool isBodyweight = json['is_bodyweight'] == true;
    final bool isUnilateral = json['is_unilateral'] == true;

    final String bodyPartLabel =
        (json['bodyPartLabel'] ?? '').toString().isEmpty
            ? normalizeExerciseBodyPart(
                bodyPart.isEmpty ? (json['category'] ?? '') : bodyPart,
                primaryMuscles: primaryMuscles,
              )
            : (json['bodyPartLabel'] ?? '').toString();

    final String equipmentLabel =
        equipment.trim().isNotEmpty && equipment.trim().toLowerCase() != 'none'
            ? formatExerciseIdentifier(equipment)
            : (isBodyweight ? 'Bodyweight' : 'No equipment');

    final String difficulty = (json['difficulty'] ?? 'beginner').toString();

    final String searchIndex = buildSearchIndex(
      id: id,
      name: nameEn,
      description: descriptionEn,
      bodyPart: bodyPart,
      bodyPartLabel: bodyPartLabel,
      exerciseCategory: (json['exercise_category'] ?? '').toString(),
      difficulty: difficulty,
      equipment: equipment,
      equipmentLabel: equipmentLabel,
      isBodyweight: isBodyweight,
      isUnilateral: isUnilateral,
      primaryMuscles: primaryMuscles,
      secondaryMuscles: secondaryMuscles,
      goals: goals,
      tags: tags,
    );

    final Object? met = json['met'];

    return Exercise(
      id: id,
      userId: '',
      name: name,
      nameEn: nameEn,
      description: description,
      descriptionEn: descriptionEn,
      bodyPart: bodyPart,
      bodyPartLabel: bodyPartLabel,
      category: (json['category'] ?? bodyPartLabel).toString(),
      exerciseCategory: (json['exercise_category'] ?? '').toString(),
      mechanic: (json['mechanic'] ?? '').toString(),
      forceType: (json['force_type'] ?? '').toString(),
      difficulty: difficulty,
      equipment: equipment,
      primaryMuscles: primaryMuscles,
      secondaryMuscles: secondaryMuscles,
      goals: goals,
      tags: tags,
      instructions: _strings(json['instructions_en']),
      tips: _strings(json['tips_en']),
      images: _map(json['images']),
      isBodyweight: isBodyweight,
      isUnilateral: isUnilateral,
      met: met is num ? met.toDouble() : null,
      variationGroup: (json['variation_group'] ?? '').toString(),
      defaultKg: _double(json['defaultKg']),
      defaultReps: _int(json['defaultReps'], 10),
      defaultSets: _int(json['defaultSets'], 3),
      isCustom: json['isCustom'] == true,
      searchIndex: searchIndex,
      createdAtUtc: now,
      updatedAtUtc: now,
    );
  }
}

List<String> _strings(Object? value) {
  if (value is! List) return const <String>[];
  return value
      .map((dynamic e) => e.toString())
      .where((String e) => e.isNotEmpty)
      .toList(growable: false);
}

Map<String, dynamic> _map(Object? value) {
  if (value is! Map) return const <String, dynamic>{};
  return value
      .map((dynamic key, dynamic e) =>
          MapEntry<String, dynamic>(key.toString(), e))
      .cast<String, dynamic>();
}

double _double(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _int(Object? value, int fallback) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}
