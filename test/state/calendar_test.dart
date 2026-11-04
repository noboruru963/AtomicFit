import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/models/app_models.dart';
import 'package:atomfit/state/calendar.dart';

/// Builds a session that started at [at] (a local time).
WorkoutSession _session({
  required String id,
  required DateTime at,
  String name = 'Workout',
}) =>
    WorkoutSession(
      id: id,
      userId: 'u_alex_01',
      name: name,
      type: 'full',
      dateLabel: 'label',
      dayOfMonth: at.day,
      startedAtUtc: at.toUtc().toIso8601String(),
      durationMin: 30,
      reps: 10,
      volume: 500,
      setsCount: 1,
      methods: const <String>['manual'],
      setsDetail: const <LoggedSet>[],
      createdAtUtc: at.toUtc().toIso8601String(),
      updatedAtUtc: at.toUtc().toIso8601String(),
    );

void main() {
  const WorkoutSession broken = WorkoutSession(
    id: 'broken',
    userId: 'u_alex_01',
    name: 'Broken',
    type: 'full',
    dateLabel: '',
    dayOfMonth: 26,
    startedAtUtc: '',
    durationMin: 0,
    reps: 0,
    volume: 0,
    setsCount: 0,
    methods: <String>[],
    setsDetail: <LoggedSet>[],
    createdAtUtc: '',
    updatedAtUtc: '',
  );

  group('sessionLocalDay', () {
    test('returns the local calendar day of the stored UTC timestamp', () {
      final DateTime at = DateTime(2026, 10, 26, 23, 30);
      expect(
        sessionLocalDay(_session(id: 'a', at: at)),
        DateTime(2026, 10, 26),
      );
    });

    test('keeps a workout after local midnight on its local day', () {
      final DateTime at = DateTime(2026, 11, 1, 0, 30);
      expect(
        sessionLocalDay(_session(id: 'a', at: at)),
        DateTime(2026, 11, 1),
      );
    });

    test('returns null for an unreadable timestamp', () {
      expect(sessionLocalDay(broken), isNull);
    });
  });

  group('sessionIsOn', () {
    test('matches the same year, month and day', () {
      final WorkoutSession session =
          _session(id: 'a', at: DateTime(2026, 10, 26, 18));
      expect(sessionIsOn(session, DateTime(2026, 10, 26)), isTrue);
    });

    test('does not match the same day number in another month', () {
      final WorkoutSession session =
          _session(id: 'a', at: DateTime(2026, 10, 26, 18));
      expect(sessionIsOn(session, DateTime(2026, 11, 26)), isFalse);
    });

    test('does not match the same day and month in another year', () {
      final WorkoutSession session =
          _session(id: 'a', at: DateTime(2025, 10, 26, 18));
      expect(sessionIsOn(session, DateTime(2026, 10, 26)), isFalse);
    });

    test('never places a session with an unreadable timestamp', () {
      expect(sessionIsOn(broken, DateTime(2026, 11, 26)), isFalse);
    });
  });

  group('sessionsInMonth', () {
    test('keeps only the sessions of the requested month', () {
      final List<WorkoutSession> sessions = <WorkoutSession>[
        _session(id: 'oct', at: DateTime(2026, 10, 26, 18)),
        _session(id: 'nov1', at: DateTime(2026, 11, 1, 8)),
        _session(id: 'nov2', at: DateTime(2026, 11, 30, 20)),
        _session(id: 'dec', at: DateTime(2026, 12, 1, 8)),
      ];

      expect(
        sessionsInMonth(sessions, DateTime(2026, 11))
            .map((WorkoutSession s) => s.id)
            .toList(),
        <String>['nov1', 'nov2'],
      );
    });

    test('handles the December to January boundary', () {
      final List<WorkoutSession> sessions = <WorkoutSession>[
        _session(id: 'dec', at: DateTime(2026, 12, 31, 23)),
        _session(id: 'jan', at: DateTime(2027, 1, 1, 0, 30)),
      ];

      expect(workoutsInMonth(sessions, DateTime(2026, 12)), 1);
      expect(workoutsInMonth(sessions, DateTime(2027, 1)), 1);
    });

    test('counts nothing for a month without workouts', () {
      final List<WorkoutSession> sessions = <WorkoutSession>[
        _session(id: 'oct', at: DateTime(2026, 10, 26, 18)),
      ];
      expect(workoutsInMonth(sessions, DateTime(2026, 11)), 0);
    });
  });
}
