import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderQuizAdjustedScreen()` (`index.html` lines 1936-1975).
class QuizAdjustedProgramScreen extends StatelessWidget {
  const QuizAdjustedProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final QuizAdjustment adjustment = state.computedQuizAdjustment();
    final Program? active = state.getActiveProgram();

    return AfScaffold(
      screenId: AfScreen.quizAdjusted,
      child: AfCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                const AfBadge(
                  label: AfStrings.quizPlanReady,
                  tone: AfBadgeTone.green,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    active?.name ?? '',
                    style: AfText.muted(t),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AfStrings.quizAdjustedTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              adjustment.isUnchanged
                  ? AfStrings.quizAdjustedBodyUnchanged
                  : AfStrings.quizAdjustedBody,
              style: AfText.muted(t).copyWith(height: 1.625),
            ),
            const SizedBox(height: 16),
            for (final ProgramExercise exercise
                in active?.exercises ?? const <ProgramExercise>[]) ...<Widget>[
              AfSubtle(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            exercise.name,
                            style: AfText.strong(t, size: 14),
                          ),
                          Text(
                            AfStrings.fill(
                              AfStrings.quizAdjustedSets,
                              <String, Object?>{
                                'sets': exercise.sets,
                                'reps': exercise.reps,
                              },
                            ),
                            style: AfText.muted(t),
                          ),
                        ],
                      ),
                    ),
                    if (adjustment.isUnchanged)
                      Text(
                        '${_trim(exercise.weightKg)} kg',
                        style: AfText.strong(t, size: 14),
                      )
                    else
                      Row(
                        children: <Widget>[
                          Text(
                            '${_trim(exercise.weightKg)} kg',
                            style: AfText.muted(t).copyWith(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_trim(exercise.weightKg * adjustment.factor)} kg '
                            '(${adjustment.pctText})',
                            style: TextStyle(
                              color: t.success,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 2),
            AfButton(
              label: adjustment.isUnchanged
                  ? AfStrings.quizAcceptUnchanged
                  : AfStrings.quizAccept,
              expand: true,
              fontSize: 14,
              onPressed: () {
                state.acceptAdjustedProgram();
                Navigator.of(context)
                    .pushReplacementNamed(AfScreen.activeWorkout);
              },
            ),
            const SizedBox(height: 10),
            AfButton(
              label: AfStrings.quizKeepOld,
              variant: AfButtonVariant.secondary,
              expand: true,
              size: AfButtonSize.compact,
              onPressed: () {
                state.keepOldProgram();
                Navigator.of(context).pushReplacementNamed(AfScreen.home);
              },
            ),
          ],
        ),
      ),
    );
  }

  static String _trim(double value) {
    final String text = value.toStringAsFixed(1);
    return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
  }
}
