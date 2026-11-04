import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/models/app_models.dart';
import 'package:atomfit/state/history_text.dart';

/// Builds one logged set; only the fields the formatter reads matter here.
LoggedSet _set(String exercise, double weightKg, int reps) => LoggedSet(
      id: 'set_${exercise}_${weightKg}_$reps',
      userId: 'u_alex_01',
      exerciseName: exercise,
      setNo: 1,
      exerciseSetNo: 1,
      weightKg: weightKg,
      reps: reps,
      restS: 120,
      inputMethod: 'manual',
      loggedAtUtc: '2026-11-04T10:00:00.000Z',
      createdAtUtc: '2026-11-04T10:00:00.000Z',
      updatedAtUtc: '2026-11-04T10:00:00.000Z',
    );

WorkoutSession _session(List<LoggedSet> sets, {String type = 'full'}) =>
    WorkoutSession(
      id: 's1',
      userId: 'u_alex_01',
      name: 'Empty workout',
      type: type,
      dateLabel: 'Nov 4, 10:00',
      dayOfMonth: 4,
      startedAtUtc: '2026-11-04T10:00:00.000Z',
      durationMin: 30,
      reps: sets.fold<int>(0, (int sum, LoggedSet s) => sum + s.reps),
      volume: 0,
      setsCount: sets.length,
      methods: const <String>['manual'],
      setsDetail: sets,
      createdAtUtc: '2026-11-04T10:00:00.000Z',
      updatedAtUtc: '2026-11-04T10:00:00.000Z',
    );

void main() {
  group('formatWeightKg', () {
    test('drops a trailing .0', () {
      expect(formatWeightKg(50), '50');
      expect(formatWeightKg(50.0), '50');
    });

    test('keeps one decimal', () {
      expect(formatWeightKg(22.5), '22.5');
      expect(formatWeightKg(22.46), '22.5');
      expect(formatWeightKg(22.44), '22.4');
    });

    test('treats 0 and invalid values as bodyweight', () {
      expect(formatWeightKg(0), '0');
      expect(formatWeightKg(-5), '0');
      expect(formatWeightKg(double.nan), '0');
      expect(formatWeightKg(double.infinity), '0');
    });
  });

  group('sessionToClipboardText', () {
    test('prints one numbered line per exercise with comma-separated reps', () {
      final String text = sessionToClipboardText(
        _session(<LoggedSet>[
          _set('Dumbbell Bench Press', 50, 7),
          _set('Dumbbell Bench Press', 50, 4),
          _set('Pull-up', 63, 12),
          _set('Pull-up', 63, 8),
        ]),
      );

      expect(
        text,
        '#1 Dumbbell Bench Press (50 kg) : 7, 4\n'
        '#2 Pull-up (63 kg) : 12, 8',
      );
    });

    test('leaves out the load for bodyweight sets', () {
      final String text = sessionToClipboardText(
        _session(<LoggedSet>[
          _set('Push-up', 0, 15),
          _set('Push-up', 0, 12),
        ]),
      );

      expect(text, '#1 Push-up : 15, 12');
    });

    test('splits a drop set into a second numbered line', () {
      final String text = sessionToClipboardText(
        _session(<LoggedSet>[
          _set('Dumbbell Bench Press', 50, 8),
          _set('Dumbbell Bench Press', 50, 7),
          _set('Dumbbell Bench Press', 40, 9),
          _set('Pull-up', 63, 12),
        ]),
      );

      expect(
        text,
        '#1 Dumbbell Bench Press (50 kg) : 8, 7\n'
        '#2 Dumbbell Bench Press (40 kg) : 9\n'
        '#3 Pull-up (63 kg) : 12',
      );
    });

    test('keeps one exercise together even when sets are interleaved', () {
      final String text = sessionToClipboardText(
        _session(<LoggedSet>[
          _set('Squat', 80, 5),
          _set('Pull-up', 0, 10),
          _set('Squat', 80, 5),
        ]),
      );

      expect(text, '#1 Squat (80 kg) : 5, 5\n#2 Pull-up : 10');
    });

    test('a return to the same weight after a drop starts a new line', () {
      final String text = sessionToClipboardText(
        _session(<LoggedSet>[
          _set('Squat', 80, 5),
          _set('Squat', 60, 8),
          _set('Squat', 80, 3),
        ]),
      );

      expect(
        text,
        '#1 Squat (80 kg) : 5\n'
        '#2 Squat (60 kg) : 8\n'
        '#3 Squat (80 kg) : 3',
      );
    });

    test('writes decimals with one place', () {
      final String text = sessionToClipboardText(
        _session(<LoggedSet>[_set('Lateral raise', 7.5, 12)]),
      );

      expect(text, '#1 Lateral raise (7.5 kg) : 12');
    });

    test('formats a micro session like any other session', () {
      final String text = sessionToClipboardText(
        _session(
          <LoggedSet>[_set('Squat', 80, 5)],
          type: 'micro',
        ),
      );

      expect(text, '#1 Squat (80 kg) : 5');
    });

    test('formats a stitched parent from its combined sets', () {
      final String text = sessionToClipboardText(
        _session(
          <LoggedSet>[
            _set('Squat', 80, 5),
            _set('Pull-up', 0, 9),
          ],
          type: 'stitched',
        ),
      );

      expect(text, '#1 Squat (80 kg) : 5\n#2 Pull-up : 9');
    });

    test('returns an empty string when there is nothing to copy', () {
      expect(sessionToClipboardText(_session(const <LoggedSet>[])), '');
    });

    test('ignores sets without an exercise name', () {
      final String text = sessionToClipboardText(
        _session(<LoggedSet>[
          _set('  ', 50, 5),
          _set('Squat', 80, 5),
        ]),
      );

      expect(text, '#1 Squat (80 kg) : 5');
    });
  });
}
