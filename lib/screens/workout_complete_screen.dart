import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderWorkoutCompleteScreen()` (`index.html` lines 3439-3481).
///
/// The screen also carries the one place where a workout gets its personal
/// note: the note is written straight onto the session that was just stored,
/// so it survives a restart and shows up in History.
class WorkoutCompleteScreen extends StatefulWidget {
  const WorkoutCompleteScreen({super.key});

  @override
  State<WorkoutCompleteScreen> createState() => _WorkoutCompleteScreenState();
}

class _WorkoutCompleteScreenState extends State<WorkoutCompleteScreen> {
  final TextEditingController _note = TextEditingController();
  String _sessionId = '';
  String _savedNote = '';
  bool _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    _seeded = true;
    final AppState state = AfAppScope.of(context);
    _sessionId = state.lastCompletedWorkout?.sessionId ?? '';
    _savedNote =
        _sessionId.isEmpty ? '' : (state.sessionById(_sessionId)?.note ?? '');
    _note.text = _savedNote;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  /// Whether the box holds something the session does not have yet.
  bool get _dirty => _note.text.trim() != _savedNote;

  void _saveNote() {
    if (_sessionId.isEmpty || !_dirty) return;
    final AppState state = AfAppScope.of(context);
    state.setSessionNote(_sessionId, _note.text);
    setState(() {
      _savedNote = state.sessionById(_sessionId)?.note ?? '';
    });
  }

  /// Saves a note the user typed but did not confirm, then leaves the screen.
  /// Typing a note should never be lost to a tap on "Go home".
  void _leave(String route) {
    if (_sessionId.isNotEmpty && _dirty) {
      AfAppScope.of(context).setSessionNote(_sessionId, _note.text);
    }
    Navigator.of(context).pushReplacementNamed(route);
  }

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
                onPressed: () => _leave(AfScreen.home),
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
            if (_sessionId.isNotEmpty) ...<Widget>[
              const SizedBox(height: 12),
              AfSubtle(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      AfStrings.completeNoteLabel,
                      style: AfText.strong(t, size: 12),
                    ),
                    const SizedBox(height: 8),
                    AfTextField(
                      controller: _note,
                      hint: AfStrings.completeNoteHint,
                      minLines: 3,
                      maxLines: 6,
                      maxLength: AppState.maxSessionNoteLength,
                      onChanged: (_) => setState(() {}),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: AfButton(
                        label: AfStrings.completeNoteSave,
                        variant: AfButtonVariant.secondary,
                        size: AfButtonSize.compact,
                        onPressed: _dirty ? _saveNote : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            AfButton(
              label: AfStrings.completeGoHome,
              expand: true,
              fontSize: 14,
              onPressed: () => _leave(AfScreen.home),
            ),
            const SizedBox(height: 8),
            AfButton(
              label: AfStrings.completeViewHistory,
              variant: AfButtonVariant.secondary,
              expand: true,
              size: AfButtonSize.compact,
              onPressed: () => _leave(AfScreen.history),
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
