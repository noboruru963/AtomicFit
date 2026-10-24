import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/models/app_models.dart';
import 'package:atomfit/state/rules.dart';

LoggedSet _set({
  required String exercise,
  required int reps,
  double weightKg = 10,
}) {
  return LoggedSet.fromJson(<String, dynamic>{
    'id': 'set_$exercise$reps',
    'exerciseName': exercise,
    'weightKg': weightKg,
    'reps': reps,
  });
}

void main() {
  group('quiz rule table', () {
    test('an explicit ease-off uses the energy band', () {
      final QuizAdjustment low = computeQuizAdjustment(<String, String>{
        'q2': 'Low',
        'q10': 'No, reduced intensity',
      });
      expect(low.factor, 0.80);
      expect(low.pctText, '-20%');

      final QuizAdjustment normal = computeQuizAdjustment(<String, String>{
        'q2': 'Normal',
        'q10': 'No, reduced intensity',
      });
      expect(normal.factor, 0.85);
      expect(normal.pctText, '-15%');

      final QuizAdjustment high = computeQuizAdjustment(<String, String>{
        'q2': 'High',
        'q10': 'No, reduced intensity',
      });
      expect(high.factor, 0.90);
      expect(high.pctText, '-10%');
    });

    test('asking to progress adds five percent', () {
      final QuizAdjustment adjustment = computeQuizAdjustment(<String, String>{
        'q2': 'Low',
        'q10': 'Yes, progress the weight',
      });
      expect(adjustment.factor, 1.05);
      expect(adjustment.pctText, '+5%');
      expect(adjustment.isUnchanged, isFalse);
    });

    test('all-high answers overload instead of deloading', () {
      final QuizAdjustment adjustment = computeQuizAdjustment(<String, String>{
        'q2': 'High',
        'q3': 'High',
        'q4': '3-4',
        'q5': '>60 min',
        'q10': 'No, same program as last',
      });
      expect(adjustment.factor, 1.05);
      expect(adjustment.factor, greaterThan(1));
    });

    test('a mixed, unchanged answer set leaves the load alone', () {
      final QuizAdjustment adjustment = computeQuizAdjustment(<String, String>{
        'q2': 'Normal',
        'q3': 'Normal',
        'q5': '30-60 min',
        'q10': 'No, same program as last',
      });
      expect(adjustment.factor, 1);
      expect(adjustment.isUnchanged, isTrue);
      expect(adjustment.pctText, '0%');
    });

    test('every reduction stays within the approved 10-20% band', () {
      for (final String energy in <String>['Low', 'Normal', 'High']) {
        final QuizAdjustment adjustment =
            computeQuizAdjustment(<String, String>{
          'q2': energy,
          'q10': 'No, reduced intensity',
        });
        expect(adjustment.factor, inInclusiveRange(0.80, 0.90));
      }
    });
  });

  group('double progression', () {
    const ProgramExercise base = ProgramExercise(
      name: 'Chest press',
      sets: 3,
      reps: 8,
      weightKg: 10,
    );

    test('reps go up by one below twelve', () {
      final ProgramExercise next = progressExercise(base);
      expect(next.reps, 9);
      expect(next.weightKg, 10);
      expect(next.sets, 3);
      expect(next.name, 'Chest press');
    });

    test('twelve reps trade for five kilos and a reset to eight', () {
      final ProgramExercise next = progressExercise(
        base.copyWith(reps: kProgressionMaxReps),
      );
      expect(next.weightKg, 15);
      expect(next.reps, kProgressionResetReps);
      expect(kProgressionResetReps, 8);
    });

    test('one step per call, never more', () {
      ProgramExercise exercise = base;
      for (int i = 8; i < 12; i++) {
        exercise = progressExercise(exercise);
        expect(exercise.reps, i + 1);
        expect(exercise.weightKg, 10);
      }
      exercise = progressExercise(exercise);
      expect(exercise.reps, 8);
      expect(exercise.weightKg, 15);
    });

    test('every planned set at target reps earns a step', () {
      final List<LoggedSet> sets = <LoggedSet>[
        _set(exercise: 'Chest press', reps: 8),
        _set(exercise: 'Chest press', reps: 10),
        _set(exercise: 'Chest press', reps: 8),
      ];
      expect(earnedProgression(base, sets), isTrue);
    });

    test('a short set or a skipped set does not', () {
      final List<LoggedSet> short = <LoggedSet>[
        _set(exercise: 'Chest press', reps: 8),
        _set(exercise: 'Chest press', reps: 7),
        _set(exercise: 'Chest press', reps: 8),
      ];
      expect(earnedProgression(base, short), isFalse);

      final List<LoggedSet> skipped = <LoggedSet>[
        _set(exercise: 'Chest press', reps: 8),
      ];
      expect(earnedProgression(base, skipped), isFalse);
    });

    test('sets of another exercise do not count', () {
      final List<LoggedSet> sets = <LoggedSet>[
        _set(exercise: 'Lat pulldown', reps: 12),
        _set(exercise: 'Lat pulldown', reps: 12),
        _set(exercise: 'Lat pulldown', reps: 12),
      ];
      expect(earnedProgression(base, sets), isFalse);
    });
  });
}
