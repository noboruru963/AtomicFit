import '../models/app_models.dart';

// --------------------------------------------------------------- progression

/// Highest number of reps an exercise climbs to before the load goes up.
const int kProgressionMaxReps = 12;

/// Rep count the exercise drops back to after a load increase.
const int kProgressionResetReps = 8;

/// How much load is added when an exercise tops out at [kProgressionMaxReps].
const double kProgressionWeightStepKg = 5;

/// Double progression.
///
/// The reps climb by one per earned session until they reach
/// [kProgressionMaxReps]; the next step adds [kProgressionWeightStepKg] and
/// resets the reps to [kProgressionResetReps].
ProgramExercise progressExercise(ProgramExercise exercise) {
  if (exercise.reps < kProgressionMaxReps) {
    return exercise.copyWith(reps: exercise.reps + 1);
  }
  return exercise.copyWith(
    weightKg: exercise.weightKg + kProgressionWeightStepKg,
    reps: kProgressionResetReps,
  );
}

/// Whether the session earned a progression step for [exercise].
///
/// Every planned set has to be logged with at least the planned number of
/// reps; an exercise that was skipped or logged short stays where it is.
bool earnedProgression(ProgramExercise exercise, List<LoggedSet> sets) {
  final int completed = sets
      .where((LoggedSet set) =>
          set.exerciseName == exercise.name && set.reps >= exercise.reps)
      .length;
  return completed >= exercise.sets;
}

// ---------------------------------------------------------------------- quiz

/// The deterministic quiz rule table.
///
/// Answers map to a load factor; nothing here is random or learned. The rows
/// are evaluated in order:
///
/// 1. an explicit "No, reduced intensity" always eases off, using the approved
///    energy bands (Low 20%, Normal 15%, High 10%);
/// 2. asking to progress, or training at high energy *and* high motivation
///    *and* a long session, applies +5% progressive overload;
/// 3. anything else leaves the program untouched.
///
/// Row 2 is what keeps an all-high answer set from ever cutting the load.
QuizAdjustment computeQuizAdjustment(Map<String, String> answers) {
  final String energy = answers['q2'] ?? 'Normal';
  final String motivation = answers['q3'] ?? 'Normal';
  final String session = answers['q5'] ?? '30-60 min';
  final String push = answers['q10'] ?? 'No, same program as last';
  final String frequencyDays = answers['q4'] ?? '3-4';

  if (push == 'No, reduced intensity') {
    final double factor = switch (energy) {
      'Low' => 0.80,
      'High' => 0.90,
      _ => 0.85,
    };
    final int percent = ((1 - factor) * 100).round();
    return QuizAdjustment(
      factor: factor,
      pctText: '-$percent%',
      intensityLabel: 'Reduced (-$percent% load)',
      sessionLength: '25 min (-10 min)',
      frequency: '$frequencyDays days/week',
    );
  }

  final bool allHigh =
      energy == 'High' && motivation == 'High' && session == '>60 min';
  if (push == 'Yes, progress the weight' || allHigh) {
    return QuizAdjustment(
      factor: 1.05,
      pctText: '+5%',
      intensityLabel: 'Progressive Overload (+5%)',
      sessionLength: '40 min (+5 min)',
      frequency: '$frequencyDays days/week',
    );
  }

  return QuizAdjustment(
    factor: 1,
    pctText: '0%',
    intensityLabel: 'No change',
    sessionLength: 'As before',
    frequency: '$frequencyDays days/week',
  );
}
