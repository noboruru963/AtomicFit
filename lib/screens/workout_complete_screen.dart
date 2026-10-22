import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderWorkoutCompleteScreen()` (`index.html` lines 3439-3481).
class WorkoutCompleteScreen extends StatelessWidget {
  const WorkoutCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final WorkoutSummary? summary = state.lastCompletedWorkout;

    if (summary == null) {
      return AfScaffold(
        screenId: AfScreen.workoutComplete,
        child: AfCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: <Widget>[
              Text(
                AfStrings.completeTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              AfButton(
                label: AfStrings.completeGoHome,
                expand: true,
                onPressed: () =>
                    Navigator.of(context).pushReplacementNamed(AfScreen.home),
              ),
            ],
          ),
        ),
      );
    }

    return AfScaffold(
      screenId: AfScreen.workoutComplete,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: AfCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: t.successTint,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '✓',
                  style: TextStyle(
                    color: t.success,
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: AfBadge(
                label:
                    AfStrings.fill(AfStrings.completeBadge, <String, Object?>{
                  'type': summary.type,
                }),
                tone: AfBadgeTone.green,
                uppercase: true,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                AfStrings.completeTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                AfStrings.fill(AfStrings.completeSubtitle, <String, Object?>{
                  'name': summary.name,
                }),
                style: AfText.muted(t),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: AfStatTile(
                    label: AfStrings.completeTotalTime,
                    value: _formatDuration(summary.durationSec),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AfStatTile(
                    label: AfStrings.completeTotalSets,
                    value: '${summary.totalSets}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: AfStatTile(
                    label: AfStrings.completeTotalVolume,
                    value: '${summary.totalVolume} kg',
                    valueColor: t.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AfStatTile(
                    label: AfStrings.completeTotalReps,
                    value: '${summary.totalReps}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AfSubtle(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Text(
                    AfStrings.completeChannelsUsed,
                    style: AfText.muted(t),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      summary.methods.join(', ').toUpperCase(),
                      textAlign: TextAlign.right,
                      style: AfText.strong(t, size: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            AfButton(
              label: AfStrings.completeGoHome,
              expand: true,
              fontSize: 14,
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed(AfScreen.home),
            ),
            const SizedBox(height: 8),
            AfButton(
              label: AfStrings.completeViewHistory,
              variant: AfButtonVariant.secondary,
              expand: true,
              size: AfButtonSize.compact,
              onPressed: () =>
                  Navigator.of(context).pushReplacementNamed(AfScreen.history),
            ),
          ],
        ),
      ),
    );
  }
}

/// Formats a duration as `mm:ss`, like the prototype's `formatMMSS`.
String _formatDuration(int totalSeconds) {
  final int minutes = (totalSeconds ~/ 60).clamp(0, 999);
  final int seconds = (totalSeconds % 60).clamp(0, 59);
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}
