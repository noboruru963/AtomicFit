import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/data/db/catalogue.dart';

void main() {
  group('formatExerciseIdentifier', () {
    test('title-cases snake case identifiers', () {
      expect(formatExerciseIdentifier('pull_up_bar'), 'Pull Up Bar');
      expect(formatExerciseIdentifier('latissimus_dorsi'), 'Latissimus Dorsi');
      expect(formatExerciseIdentifier('dumbbell'), 'Dumbbell');
    });

    test('keeps the special abbreviations upper-case', () {
      expect(formatExerciseIdentifier('it_band'), 'IT Band');
      expect(formatExerciseIdentifier('ez_bar'), 'EZ Bar');
      expect(formatExerciseIdentifier('db_bench'), 'DB Bench');
    });

    test('returns an empty string for empty input', () {
      expect(formatExerciseIdentifier(null), '');
      expect(formatExerciseIdentifier('   '), '');
    });
  });

  group('normalizeExerciseBodyPart', () {
    test('maps the raw body parts onto the display labels', () {
      expect(normalizeExerciseBodyPart('chest'), 'Chest');
      expect(normalizeExerciseBodyPart('back'), 'Back');
      expect(normalizeExerciseBodyPart('shoulders'), 'Shoulders');
      expect(normalizeExerciseBodyPart('upper_arms'), 'Upper Arms');
      expect(normalizeExerciseBodyPart('forearms'), 'Forearms');
      expect(normalizeExerciseBodyPart('core'), 'Core / Waist');
      expect(normalizeExerciseBodyPart('lower_legs'), 'Lower Legs / Calves');
      expect(normalizeExerciseBodyPart('full_body'), 'Cardio / Full Body');
      expect(normalizeExerciseBodyPart('mobility'), 'Stretching / Mobility');
      expect(normalizeExerciseBodyPart('nonsense'), 'Other');
    });

    test('routes hip-dominant upper legs into Hips / Glutes', () {
      expect(
        normalizeExerciseBodyPart(
          'upper_legs',
          primaryMuscles: <String>['gluteus_maximus'],
        ),
        'Hips / Glutes',
      );
      expect(
        normalizeExerciseBodyPart(
          'upper_legs',
          primaryMuscles: <String>['quadriceps_femoris'],
        ),
        'Upper Legs',
      );
    });
  });

  group('body part filters', () {
    test('"All" matches everything', () {
      expect(
        matchesBodyPartFilter(
          bodyPartLabel: 'Chest',
          exerciseCategory: 'strength',
          goals: const <String>[],
          tags: const <String>[],
          filter: 'All',
        ),
        isTrue,
      );
    });

    test('matches the selected body part', () {
      expect(
        matchesBodyPartFilter(
          bodyPartLabel: 'Back',
          exerciseCategory: 'strength',
          goals: const <String>[],
          tags: const <String>[],
          filter: 'Back',
        ),
        isTrue,
      );
      expect(
        matchesBodyPartFilter(
          bodyPartLabel: 'Back',
          exerciseCategory: 'strength',
          goals: const <String>[],
          tags: const <String>[],
          filter: 'Chest',
        ),
        isFalse,
      );
    });

    test('Stretching / Mobility also matches by category, goal or tag', () {
      expect(
        matchesBodyPartFilter(
          bodyPartLabel: 'Back',
          exerciseCategory: 'stretching',
          goals: const <String>[],
          tags: const <String>[],
          filter: 'Stretching / Mobility',
        ),
        isTrue,
      );
      expect(
        matchesBodyPartFilter(
          bodyPartLabel: 'Back',
          exerciseCategory: 'strength',
          goals: const <String>['mobility'],
          tags: const <String>[],
          filter: 'Stretching / Mobility',
        ),
        isTrue,
      );
      expect(
        matchesBodyPartFilter(
          bodyPartLabel: 'Back',
          exerciseCategory: 'strength',
          goals: const <String>[],
          tags: const <String>['shoulder_safe'],
          filter: 'Stretching / Mobility',
        ),
        isFalse,
      );
    });
  });

  group('search', () {
    String index() => buildSearchIndex(
          id: 'archer-pull-ups',
          name: 'Archer Pull Ups',
          description: 'A wide-grip pull up.',
          bodyPart: 'back',
          bodyPartLabel: 'Back',
          exerciseCategory: 'strength',
          difficulty: 'advanced',
          equipment: 'pull_up_bar',
          equipmentLabel: 'Pull Up Bar',
          isBodyweight: true,
          isUnilateral: false,
          primaryMuscles: <String>['latissimus_dorsi'],
          secondaryMuscles: <String>['biceps_brachii'],
          goals: <String>['strength'],
          tags: const <String>['knee_safe'],
        );

    test('every token has to match', () {
      expect(matchesSearchIndex(index(), 'archer'), isTrue);
      expect(matchesSearchIndex(index(), 'archer pull'), isTrue);
      expect(matchesSearchIndex(index(), 'archer squat'), isFalse);
    });

    test('an empty query matches everything', () {
      expect(matchesSearchIndex(index(), ''), isTrue);
      expect(matchesSearchIndex(index(), '   '), isTrue);
    });

    test('muscles and equipment are searchable', () {
      expect(matchesSearchIndex(index(), 'latissimus'), isTrue);
      expect(matchesSearchIndex(index(), 'pull up bar'), isTrue);
    });
  });

  group('illustrations', () {
    test('prefers the start position for the thumbnail', () {
      expect(
        exerciseThumbnailPath(<String, dynamic>{
          'start': 'images/flat/a-start.webp',
          'peak': 'images/flat/a-peak.webp',
        }),
        'images/flat/a-start.webp',
      );
      expect(
        exerciseThumbnailPath(
            <String, dynamic>{'peak': 'images/flat/a-peak.webp'}),
        'images/flat/a-peak.webp',
      );
      expect(exerciseThumbnailPath(null), '');
    });

    test('labels the start and peak positions', () {
      final List<ExerciseIllustration> illustrations = exerciseIllustrations(
        <String, dynamic>{
          'start': 'images/flat/a-start.webp',
          'peak': 'images/flat/a-peak.webp',
        },
      );
      expect(illustrations, hasLength(2));
      expect(illustrations.first.label, 'Start position');
      expect(illustrations.last.label, 'Peak position');
    });

    test('falls back to the main image', () {
      final List<ExerciseIllustration> illustrations = exerciseIllustrations(
        <String, dynamic>{'main': 'images/flat/a-main.webp'},
      );
      expect(illustrations, hasLength(1));
      expect(illustrations.first.label, 'Exercise position');
    });
  });

  group('remote urls', () {
    test('resolves dataset paths against the host', () {
      expect(
        toRepDbRemoteUrl('images/flat/a.webp'),
        'https://exercise-dataset.com/images/flat/a.webp',
      );
    });

    test('passes absolute urls through', () {
      expect(
        toRepDbRemoteUrl('https://example.com/a.webp'),
        'https://example.com/a.webp',
      );
    });

    test('returns an empty string for an empty path', () {
      expect(toRepDbRemoteUrl(''), '');
      expect(toRepDbRemoteUrl(null), '');
    });
  });
}
