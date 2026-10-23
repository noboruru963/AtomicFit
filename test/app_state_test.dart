import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/data/store.dart';
import 'package:atomfit/models/app_models.dart';
import 'package:atomfit/state/app_state.dart';

class _MemoryStore implements AtomFitStore {
  Map<String, dynamic>? data;

  @override
  Future<Map<String, dynamic>?> read() async => data;

  @override
  Future<void> write(Map<String, dynamic> document) async {
    data = document;
  }
}

Future<AppState> _freshState() async {
  final AppState state = AppState(store: _MemoryStore());
  await state.load();
  return state;
}

void main() {
  test('seeds the prototype data on first launch', () async {
    final AppState state = await _freshState();
    expect(state.catalogue, hasLength(13));
    expect(state.programs, hasLength(7));
    expect(state.history, hasLength(4));
    expect(state.scheduledWorkouts, isEmpty);
    expect(state.getActiveProgram()?.name, 'Push Day');
  });

  test('persists and restores across launches', () async {
    final _MemoryStore store = _MemoryStore();
    final AppState first = AppState(store: store);
    await first.load();
    first.setThemeExplicit(true);
    first.setActiveProgram('p_pull');
    first.scheduleWorkout(
      dayOfMonth: 25,
      plannedTime: '17:30',
      programId: 'p_pull',
    );
    await first.persist();

    final AppState second = AppState(store: store);
    await second.load();
    expect(second.isDarkMode, isTrue);
    expect(second.getActiveProgram()?.id, 'p_pull');
    expect(second.catalogue, hasLength(13));
    expect(second.scheduledWorkouts, hasLength(1));
    expect(second.scheduledWorkouts.first.dayOfMonth, 25);
    expect(second.scheduledWorkouts.first.plannedTime, '17:30');
    expect(second.scheduledWorkouts.first.programName, 'Pull Day');
  });

  test(
      'scheduling, editing, and removing a workout does not affect completed workout count',
      () async {
    final AppState state = await _freshState();
    final int completedBefore = state.history.length;

    final ScheduledWorkout? created = state.scheduleWorkout(
      dayOfMonth: 26,
      plannedTime: '08:30',
      programId: 'p_leg',
    );
    expect(created, isNotNull);
    expect(created!.dayOfMonth, 26);
    expect(created.plannedTime, '08:30');
    expect(created.programName, 'Leg Day');
    expect(state.history.length, completedBefore);
    expect(state.scheduledWorkoutForDay(26)?.id, created.id);

    final ScheduledWorkout? edited = state.scheduleWorkout(
      dayOfMonth: 26,
      plannedTime: '18:00',
      programId: 'p_upper',
      existingId: created.id,
    );
    expect(edited, isNotNull);
    expect(edited!.id, created.id);
    expect(edited.plannedTime, '18:00');
    expect(edited.programName, 'Upper Day');
    expect(state.scheduledWorkouts, hasLength(1));
    expect(state.history.length, completedBefore);

    final bool removed = state.removeScheduledWorkout(created.id);
    expect(removed, isTrue);
    expect(state.scheduledWorkoutForDay(26), isNull);
    expect(state.history.length, completedBefore);
  });

  test('logs a set through the single write path', () async {
    final AppState state = await _freshState();
    state.updateWeightInput('20');
    state.updateRepsInput(12);
    expect(state.logCurrentSet(), isNull);
    expect(state.activeWorkout.sets, hasLength(1));
    expect(state.activeWorkout.sets.first.weightKg, 20);
    expect(state.activeWorkout.sets.first.reps, 12);
    expect(state.activeWorkout.sets.first.inputMethod, 'manual');
  });

  test('rejects an invalid weight without saving a set', () async {
    final AppState state = await _freshState();
    state.updateWeightInput('abc');
    expect(state.logCurrentSet(), isNotNull);
    expect(state.activeWorkout.sets, isEmpty);
  });

  test('finishing a workout stores a session with real totals', () async {
    final AppState state = await _freshState();
    state.updateWeightInput('22.5');
    state.updateRepsInput(10);
    state.logCurrentSet();
    state.updateWeightInput('16');
    state.updateRepsInput(8);
    state.logCurrentSet();

    final WorkoutSession? session = state.finishActiveWorkout();
    expect(session, isNotNull);
    expect(session!.setsCount, 2);
    expect(session.reps, 18);
    expect(session.volume, 353);
    expect(state.history.first.id, session.id);
    expect(state.activeWorkout.sets, isEmpty);
  });

  test('quiz rule table follows the prototype', () async {
    final AppState state = await _freshState();

    state.selectQuizOption('q2', 'Low');
    state.selectQuizOption('q10', 'No, reduced intensity');
    expect(state.computedQuizAdjustment().pctText, '-15%');
    expect(state.computedQuizAdjustment().factor, 0.85);

    state.selectQuizOption('q10', 'Yes, progress the weight');
    expect(state.computedQuizAdjustment().pctText, '+5%');
    expect(state.computedQuizAdjustment().factor, 1.05);

    state.selectQuizOption('q2', 'Normal');
    state.selectQuizOption('q10', 'No, same program as last');
    expect(state.computedQuizAdjustment().pctText, '-10%');
  });

  test('accepting the quiz adjusts the program weights', () async {
    final AppState state = await _freshState();
    final double before = state.getActiveProgram()!.exercises.first.weightKg;
    state.selectQuizOption('q2', 'Low');
    state.selectQuizOption('q10', 'No, reduced intensity');
    state.acceptAdjustedProgram();

    final double after = state.getActiveProgram()!.exercises.first.weightKg;
    expect(after, lessThan(before));
    expect(state.isProgramAdjusted, isTrue);
    expect(state.showQuizBannerOnHome, isFalse);
  });

  test('stitching combines two micro sessions and unstitch restores them',
      () async {
    final AppState state = await _freshState();
    // The seeded history holds a single micro session, so a second one is
    // created the way the app does it: finish a micro program.
    state.startProgramWorkout('p4', 'micro');
    state.updateWeightInput('12');
    state.updateRepsInput(10);
    state.logCurrentSet();
    state.finishActiveWorkout();

    final int before = state.history.length;
    final WorkoutSession? stitched = state.stitchMicroSessions();
    expect(stitched, isNotNull);
    expect(stitched!.children, hasLength(2));
    expect(stitched.type, 'stitched');
    expect(state.history.length, before - 1);

    state.unstitchSession(stitched.id);
    expect(state.history.length, before);
  });

  test('switching the input channel is persisted on the draft', () async {
    final AppState state = await _freshState();
    state.switchInputMethod('voice');
    expect(state.activeWorkout.inputMethod, 'voice');
  });
}
