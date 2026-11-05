import '../models/app_models.dart';

/// Turns a finished workout into the plain text the user can paste anywhere.
///
/// The format is intentionally simple, one line per exercise (or per weight
/// block when the weight changes mid-exercise):
///
/// ```text
/// #1 Dumbbell Bench Press (50 kg) : 7, 4
/// #2 Pull-up (63 kg) : 12, 8
/// #3 Push-up : 15
/// ```
///
/// Rules:
/// * exercises are numbered in the order they first appear in the session;
/// * the reps of one exercise are listed in the order they were logged, joined
///   with `, `;
/// * a change of weight starts a new numbered line (drop sets), so the text
///   never claims a load that was not used;
/// * a weight of 0 kg (bodyweight) is left out instead of printing `(0 kg)`.
///
/// This is pure Dart on purpose: no Flutter, no clipboard, so the exact text
/// can be pinned by a unit test. The screen only copies what this returns.
String sessionToClipboardText(WorkoutSession session) {
  final List<_ExerciseBlock> blocks = <_ExerciseBlock>[];

  for (final LoggedSet set in session.setsDetail) {
    final String exercise = set.exerciseName.trim();
    if (exercise.isEmpty) continue;
    final String weight = formatWeightKg(set.weightKg);

    // Only the most recent block of the same exercise may be extended, so a
    // later return to the same weight starts a new line instead of silently
    // merging with a set from before the drop.
    _ExerciseBlock? last;
    for (final _ExerciseBlock block in blocks) {
      if (block.exercise == exercise) last = block;
    }

    if (last != null && last.weightText == weight) {
      last.reps.add(set.reps);
    } else {
      blocks.add(_ExerciseBlock(exercise, weight, <int>[set.reps]));
    }
  }

  final List<String> lines = <String>[];
  for (int i = 0; i < blocks.length; i++) {
    final _ExerciseBlock block = blocks[i];
    final String load =
        block.weightText == '0' ? '' : ' (${block.weightText} kg)';
    lines.add('#${i + 1} ${block.exercise}$load : ${block.reps.join(', ')}');
  }
  return lines.join('\n');
}

/// Formats a load the way the rest of the app does: one decimal at most, and
/// no trailing `.0` (`50`, `22.5`).
String formatWeightKg(double weightKg) {
  if (!weightKg.isFinite || weightKg <= 0) return '0';
  final double rounded = (weightKg * 10).roundToDouble() / 10;
  if (rounded == rounded.roundToDouble()) return rounded.toStringAsFixed(0);
  return rounded.toStringAsFixed(1);
}

/// One printed line: an exercise at one weight, with its reps in order.
class _ExerciseBlock {
  _ExerciseBlock(this.exercise, this.weightText, this.reps);

  final String exercise;
  final String weightText;
  final List<int> reps;
}
