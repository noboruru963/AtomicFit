import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/data/store.dart';
import 'package:atomfit/models/app_models.dart';
import 'package:atomfit/services/notifications.dart';
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
    expect(state.getActiveProgram()?.name, 'Push Day');
  });

  test('persists and restores across launches', () async {
    final _MemoryStore store = _MemoryStore();
    final AppState first = AppState(store: store);
    await first.load();
    first.setThemeExplicit(true);
    first.setActiveProgram('p_pull');
    await first.persist();

    final AppState second = AppState(store: store);
    await second.load();
    expect(second.isDarkMode, isTrue);
    expect(second.getActiveProgram()?.id, 'p_pull');
    expect(second.catalogue, hasLength(13));
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

  test('quiz rule table eases off only when asked or when energy is low',
      () async {
    final AppState state = await _freshState();

    // Row 1: an explicit request to ease off uses the energy band.
    state.selectQuizOption('q2', 'Low');
    state.selectQuizOption('q10', 'No, reduced intensity');
    expect(state.computedQuizAdjustment().pctText, '-20%');
    expect(state.computedQuizAdjustment().factor, 0.80);

    state.selectQuizOption('q2', 'Normal');
    expect(state.computedQuizAdjustment().pctText, '-15%');
    state.selectQuizOption('q2', 'High');
    expect(state.computedQuizAdjustment().pctText, '-10%');

    // Row 2: asking to progress always adds load.
    state.selectQuizOption('q10', 'Yes, progress the weight');
    expect(state.computedQuizAdjustment().pctText, '+5%');
    expect(state.computedQuizAdjustment().factor, 1.05);
  });

  test('an all-high answer set never reduces the load', () async {
    final AppState state = await _freshState();
    state.selectQuizOption('q2', 'High');
    state.selectQuizOption('q3', 'High');
    state.selectQuizOption('q4', '3-4');
    state.selectQuizOption('q5', '>60 min');
    state.selectQuizOption('q10', 'No, same program as last');

    final QuizAdjustment adjustment = state.computedQuizAdjustment();
    expect(adjustment.factor, greaterThanOrEqualTo(1));
    expect(adjustment.pctText, '+5%');
    expect(adjustment.isUnchanged, isFalse);
  });

  test('the quiz leaves the load alone when nothing points to a change',
      () async {
    final AppState state = await _freshState();
    state.selectQuizOption('q2', 'Normal');
    state.selectQuizOption('q3', 'Normal');
    state.selectQuizOption('q5', '30-60 min');
    state.selectQuizOption('q10', 'No, same program as last');

    final QuizAdjustment adjustment = state.computedQuizAdjustment();
    expect(adjustment.isUnchanged, isTrue);
    expect(adjustment.factor, 1);
  });

  test('a completed session progresses reps before weight', () async {
    final AppState state = await _freshState();
    final Program program = state.programs.first;
    final ProgramExercise first = program.exercises.first;
    state.startProgramWorkout(program.id, 'full');
    for (int i = 0; i < first.sets; i++) {
      state.updateWeightInput(first.weightKg.toString());
      state.updateRepsInput(first.reps);
      state.logCurrentSet();
    }
    state.finishActiveWorkout();

    final ProgramExercise after = state.programs.first.exercises.firstWhere(
      (ProgramExercise e) => e.name == first.name,
    );
    expect(after.weightKg, first.weightKg);
    expect(after.reps, first.reps + 1);
  });

  test('a skipped exercise keeps its targets', () async {
    final AppState state = await _freshState();
    final Program program = state.programs.first;
    final ProgramExercise first = program.exercises.first;
    // Log fewer sets than planned, so the target was not reached.
    state.startProgramWorkout(program.id, 'full');
    state.updateWeightInput(first.weightKg.toString());
    state.updateRepsInput(first.reps);
    state.logCurrentSet();
    state.finishActiveWorkout();

    final ProgramExercise after = state.programs.first.exercises.firstWhere(
      (ProgramExercise e) => e.name == first.name,
    );
    expect(after.reps, first.reps);
    expect(after.weightKg, first.weightKg);
  });

  test('scheduling a workout keeps it and survives a restart', () async {
    final AppState state = await _freshState();
    final Program program = state.programs.first;
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));

    final ScheduledWorkout planned = state.scheduleWorkout(
      date: tomorrow,
      hour: 18,
      minute: 30,
      program: program,
    );
    expect(state.scheduledOn(tomorrow)?.id, planned.id);
    expect(state.nextScheduledWorkout?.programName, program.name);
    await state.pendingWrite;

    final AppState reloaded = AppState(store: state.store);
    await reloaded.load();
    expect(reloaded.scheduledOn(tomorrow)?.hour, 18);
    expect(reloaded.scheduledOn(tomorrow)?.minute, 30);

    reloaded.cancelScheduledWorkout(planned.id);
    expect(reloaded.scheduledOn(tomorrow), isNull);
  });

  test('past plans are dropped on the next launch', () async {
    final AppState state = await _freshState();
    final Program program = state.programs.first;
    final DateTime past = DateTime.now().subtract(const Duration(days: 1));
    state.scheduledWorkouts = <ScheduledWorkout>[
      ScheduledWorkout(
        id: 'sch_old',
        userId: 'u_alex_01',
        programId: program.id,
        programName: program.name,
        year: past.year,
        month: past.month,
        day: past.day,
        hour: 8,
        minute: 0,
        createdAtUtc: '2026-10-01T00:00:00.000Z',
        updatedAtUtc: '2026-10-01T00:00:00.000Z',
      ),
    ];
    await state.persist();
    await state.pendingWrite;

    final AppState reloaded = AppState(store: state.store);
    await reloaded.load();
    expect(reloaded.scheduledWorkouts, isEmpty);
    expect(reloaded.nextScheduledWorkout, isNull);
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

  test('the rest timer mirrors into the OS notification', () async {
    final AppState state = await _freshState();
    final _FakeRestNotifier notifier = _FakeRestNotifier();
    state.restTimerNotifications = notifier;
    state.settings = state.settings.copyWith(restNotifications: true);

    state.startRestTimerCountdown();
    expect(notifier.progressCalls, 1);
    expect(notifier.lastExercise, isNotEmpty);

    state.pauseRestTimer();
    expect(notifier.cancelCalls, 1);

    state.startRestTimerCountdown();
    state.skipRestTimer();
    expect(notifier.cancelCalls, greaterThanOrEqualTo(2));

    state.dispose();
  });

  test('the rest timer stays silent when notifications are off', () async {
    final AppState state = await _freshState();
    final _FakeRestNotifier notifier = _FakeRestNotifier();
    state.restTimerNotifications = notifier;
    state.settings = state.settings.copyWith(restNotifications: false);

    state.startRestTimerCountdown();
    expect(notifier.progressCalls, 0);
    expect(notifier.cancelCalls, 1);

    state.dispose();
  });

  test('a ±15s adjustment becomes the rest time for later sets', () async {
    final AppState state = await _freshState();
    expect(state.activeWorkout.restTotalSeconds, 120);

    state.adjustRestSeconds(-15);
    expect(state.activeWorkout.restTotalSeconds, 105);
    expect(state.activeWorkout.restSeconds, 105);

    state.updateWeightInput('20');
    state.updateRepsInput(10);
    expect(state.logCurrentSet(), isNull);
    expect(state.activeWorkout.sets.single.restS, 105);
    expect(state.activeWorkout.restSeconds, 105);
    expect(state.activeWorkout.restTotalSeconds, 105);

    state.dispose();
  });

  test('reset restores the target duration and pauses the countdown', () async {
    final AppState state = await _freshState();
    state.adjustRestSeconds(15);
    state.startRestTimerCountdown();
    expect(state.isTimerRunning, isTrue);

    state.resetRestTimer();
    expect(state.isTimerRunning, isFalse);
    expect(state.restSecondsRemaining, 135);
    expect(state.activeWorkout.restTotalSeconds, 135);

    state.dispose();
  });

  test('the adjusted rest duration never drops below 15 seconds', () async {
    final AppState state = await _freshState();
    for (int i = 0; i < 20; i++) {
      state.adjustRestSeconds(-15);
    }
    expect(state.activeWorkout.restTotalSeconds, 15);

    // Continuing with nothing left restarts the clamped target.
    state.startRestTimerCountdown();
    expect(state.restSecondsRemaining, greaterThan(0));
    expect(state.restSecondsRemaining, lessThanOrEqualTo(15));

    state.dispose();
  });
}

class _FakeRestNotifier implements RestTimerNotifier {
  int progressCalls = 0;
  int cancelCalls = 0;
  int finishCalls = 0;
  String lastExercise = '';

  @override
  void showProgress({required String exercise, required DateTime endTime}) {
    progressCalls += 1;
    lastExercise = exercise;
  }

  @override
  void showFinished({required String exercise}) {
    finishCalls += 1;
  }

  @override
  void cancelProgress() {
    cancelCalls += 1;
  }
}
