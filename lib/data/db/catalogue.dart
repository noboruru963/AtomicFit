/// Pure helpers for the RepDB exercise catalogue.
///
/// These mirror the prototype's JavaScript helpers one-for-one
/// (`index.html`: `formatExerciseIdentifier`, `normalizeExerciseBodyPart`,
/// `getExerciseBodyPartLabel`, `getExerciseEquipmentLabel`,
/// `getExerciseDifficultyLabel`, `getExerciseThumbnailRelPath`,
/// `getExerciseIllustrationsList`, `matchesDiscoverBodyPart`,
/// `matchesDiscoverSearch`).
///
/// Everything here is deliberately free of Flutter and of `package:sqflite` so
/// the rules can be unit tested without a database.
library;

/// Body part filter pills, in the order the prototype renders them.
const List<String> discoverBodyPartFilters = <String>[
  'All',
  'Chest',
  'Back',
  'Shoulders',
  'Upper Arms',
  'Forearms',
  'Core / Waist',
  'Hips / Glutes',
  'Upper Legs',
  'Lower Legs / Calves',
  'Cardio / Full Body',
  'Stretching / Mobility',
  'Other',
];

/// Primary muscles that force an "upper_legs" record into "Hips / Glutes".
const Set<String> hipGlutePrimarySet = <String>{
  'gluteus_maximus',
  'gluteus_medius',
  'gluteus_minimus',
  'hip_flexors',
  'abductors',
};

/// Converts `snake_case` / `kebab-case` identifiers into `Title Case`.
///
/// Mirrors `formatExerciseIdentifier` — `it` and `ez` keep their upper-case
/// spelling, everything else is capitalised word by word.
String formatExerciseIdentifier(String? raw) {
  final String value = (raw ?? '').trim();
  if (value.isEmpty) return '';
  return value
      .split(RegExp(r'[_\-\s]+'))
      .where((String word) => word.isNotEmpty)
      .map((String word) {
    final String lower = word.toLowerCase();
    if (lower == 'it') return 'IT';
    if (lower == 'ez') return 'EZ';
    if (lower == 'db') return 'DB';
    return lower.substring(0, 1).toUpperCase() + lower.substring(1);
  }).join(' ');
}

/// Maps a raw body part onto one of the prototype's display labels.
///
/// Mirrors `normalizeExerciseBodyPart`.
String normalizeExerciseBodyPart(
  String? rawBodyPart, {
  List<String> primaryMuscles = const <String>[],
}) {
  final String bodyPart = (rawBodyPart ?? '').trim().toLowerCase();
  final List<String> muscles = primaryMuscles
      .map((String m) => m.trim().toLowerCase())
      .where((String m) => m.isNotEmpty)
      .toList(growable: false);

  switch (bodyPart) {
    case 'chest':
      return 'Chest';
    case 'back':
      return 'Back';
    case 'shoulders':
      return 'Shoulders';
    case 'upper_arms':
    case 'arms':
      return 'Upper Arms';
    case 'lower_arms':
    case 'forearms':
      return 'Forearms';
    case 'core':
    case 'waist':
    case 'abs':
      return 'Core / Waist';
    case 'hips':
    case 'glutes':
    case 'hips_glutes':
      return 'Hips / Glutes';
    case 'upper_legs':
    case 'legs':
      if (muscles.isNotEmpty &&
          muscles.every((String m) => hipGlutePrimarySet.contains(m))) {
        return 'Hips / Glutes';
      }
      return 'Upper Legs';
    case 'lower_legs':
    case 'calves':
      return 'Lower Legs / Calves';
    case 'full_body':
    case 'cardio':
      return 'Cardio / Full Body';
    case 'stretching':
    case 'mobility':
      return 'Stretching / Mobility';
    default:
      return 'Other';
  }
}

/// One illustration of an exercise (start / peak position).
class ExerciseIllustration {
  const ExerciseIllustration({required this.label, required this.relPath});

  final String label;
  final String relPath;
}

/// The exercise-data host used for remote illustrations.
const String repDbRemoteBase = 'https://exercise-dataset.com/';

/// Resolves a catalogue image path to its remote URL.
///
/// Mirrors `toRepDbRemoteUrl`: absolute URLs and `data:` URIs pass through,
/// everything else is resolved against the dataset host.
String toRepDbRemoteUrl(String? relPath) {
  final String clean = (relPath ?? '').trim().replaceFirst(RegExp(r'^/+'), '');
  if (clean.isEmpty) return '';
  if (clean.startsWith('http') || clean.startsWith('data:')) return clean;
  return '$repDbRemoteBase$clean';
}

/// The thumbnail path of an exercise (`images.start` → `images.main` →
/// `images.peak`).
///
/// Mirrors `getExerciseThumbnailRelPath`.
String exerciseThumbnailPath(Map<String, dynamic>? images) {
  if (images == null || images.isEmpty) return '';
  for (final String key in <String>['start', 'main', 'peak']) {
    final Object? value = images[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return '';
}

/// The illustrations of an exercise, labelled like the prototype.
///
/// Mirrors `getExerciseIllustrationsList`.
List<ExerciseIllustration> exerciseIllustrations(Map<String, dynamic>? images) {
  if (images == null || images.isEmpty) return const <ExerciseIllustration>[];
  final List<ExerciseIllustration> list = <ExerciseIllustration>[];
  final Object? start = images['start'];
  if (start is String && start.trim().isNotEmpty) {
    list.add(
      ExerciseIllustration(label: 'Start position', relPath: start.trim()),
    );
  }
  final Object? peak = images['peak'];
  if (peak is String && peak.trim().isNotEmpty) {
    list.add(
      ExerciseIllustration(label: 'Peak position', relPath: peak.trim()),
    );
  }
  if (list.isEmpty) {
    final Object? main = images['main'];
    if (main is String && main.trim().isNotEmpty) {
      list.add(
        ExerciseIllustration(label: 'Exercise position', relPath: main.trim()),
      );
    }
  }
  return list;
}

/// Whether an exercise matches the selected body-part filter.
///
/// Mirrors `matchesDiscoverBodyPart`.
bool matchesBodyPartFilter({
  required String bodyPartLabel,
  required String exerciseCategory,
  required List<String> goals,
  required List<String> tags,
  required String filter,
}) {
  final String selected = filter.trim().isEmpty ? 'All' : filter.trim();
  if (selected == 'All') return true;
  if (selected == 'Stretching / Mobility') {
    if (bodyPartLabel == 'Stretching / Mobility') return true;
    if (exerciseCategory.trim().toLowerCase() == 'stretching') return true;
    if (goals.any((String g) => g.trim().toLowerCase() == 'mobility')) {
      return true;
    }
    return tags.any((String t) {
      final String lower = t.trim().toLowerCase();
      return lower == 'stretching' || lower == 'mobility';
    });
  }
  return bodyPartLabel == selected;
}

/// Builds the lower-cased search index of an exercise.
///
/// Mirrors the `_searchIndex` built inside `matchesDiscoverSearch`.
String buildSearchIndex({
  required String id,
  required String name,
  required String description,
  required String bodyPart,
  required String bodyPartLabel,
  required String exerciseCategory,
  required String difficulty,
  required String equipment,
  required String equipmentLabel,
  required bool isBodyweight,
  required bool isUnilateral,
  required List<String> primaryMuscles,
  required List<String> secondaryMuscles,
  required List<String> goals,
  required List<String> tags,
}) {
  final List<String> parts = <String>[
    id,
    name,
    description,
    bodyPart,
    bodyPartLabel,
    formatExerciseIdentifier(bodyPart),
    exerciseCategory,
    difficulty,
    equipment,
    equipmentLabel,
    isBodyweight ? 'bodyweight' : '',
    isUnilateral ? 'unilateral' : '',
    primaryMuscles.join(' '),
    primaryMuscles.map(formatExerciseIdentifier).join(' '),
    secondaryMuscles.join(' '),
    secondaryMuscles.map(formatExerciseIdentifier).join(' '),
    goals.join(' '),
    tags.join(' '),
    tags.map(formatExerciseIdentifier).join(' '),
  ];
  return parts.join(' ').toLowerCase();
}

/// Whether a search query matches an exercise.
///
/// Every whitespace separated token of the query must appear in the index —
/// exactly like `matchesDiscoverSearch`.
bool matchesSearchIndex(String searchIndex, String? rawQuery) {
  final String query = (rawQuery ?? '').trim().toLowerCase();
  if (query.isEmpty) return true;
  final List<String> tokens = query
      .split(RegExp(r'\s+'))
      .where((String token) => token.isNotEmpty)
      .toList(growable: false);
  for (final String token in tokens) {
    if (!searchIndex.contains(token)) return false;
  }
  return true;
}
