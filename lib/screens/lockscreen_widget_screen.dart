import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// The lock-screen quick-log panel.
///
/// It shows the current exercise, ±1 rep, Add set, Next exercise and, right
/// after a set is saved, the rest countdown. It is the same set of actions the
/// OS lock screen offers on supported devices; this screen is the in-app
/// version so the flow can be demonstrated without leaving the app.
class LockScreenWidgetScreen extends StatelessWidget {
  const LockScreenWidgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final ActiveWorkout workout = state.activeWorkout;
    final bool hasWorkout = workout.exercises.isNotEmpty;

    return Scaffold(
      backgroundColor: t.bgPage,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        AfStrings.lockWidgetLabel,
                        style: AfText.muted(
                          t,
                          size: 11,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: AfStrings.close,
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: Icon(Icons.close, color: t.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _clock(DateTime.now()),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: t.textPrimary,
                      fontSize: 54,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                      height: 1.05,
                    ),
                  ),
                  Text(
                    _date(DateTime.now()),
                    textAlign: TextAlign.center,
                    style: AfText.muted(t, size: 12),
                  ),
                  const SizedBox(height: 22),
                  if (!hasWorkout)
                    _EmptyPanel(t: t)
                  else
                    _WidgetPanel(state: state, workout: workout),
                  const SizedBox(height: 14),
                  Text(
                    AfStrings.lockWidgetPreviewNote,
                    textAlign: TextAlign.center,
                    style: AfText.muted(t, size: 10),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _clock(DateTime now) =>
      '${now.hour.toString().padLeft(2, '0')}:'
      '${now.minute.toString().padLeft(2, '0')}';

  static String _date(DateTime now) {
    const List<String> days = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel({required this.t});

  final AfTokens t;

  @override
  Widget build(BuildContext context) {
    return AfCard(
      padding: const EdgeInsets.all(20),
      child: Text(
        AfStrings.lockWidgetEmpty,
        textAlign: TextAlign.center,
        style: AfText.muted(t, size: 13),
      ),
    );
  }
}

/// The widget itself: exercise, reps, the four actions and the rest countdown.
class _WidgetPanel extends StatelessWidget {
  const _WidgetPanel({required this.state, required this.workout});

  final AppState state;
  final ActiveWorkout workout;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final int exerciseIndex = workout.exercises.indexWhere(
      (ProgramExercise e) =>
          e.name.toLowerCase() == workout.currentExercise.toLowerCase(),
    );
    final int total = workout.exercises.length;
    final int setNo = state.loggedCountFor(workout.currentExercise) + 1;
    final bool restVisible = state.isTimerRunning || state.restCompleted;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: t.borderLine),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: t.borderLine.withValues(alpha: 0.5),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              const AfBadge(label: AfStrings.lockWidgetBrand, fontSize: 10),
              const Spacer(),
              Text(
                AfStrings.fill(AfStrings.lockWidgetSet, <String, Object?>{
                  'n': setNo,
                  'total': total,
                }),
                style: AfText.muted(t, size: 11, weight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            workout.currentExercise.isEmpty
                ? AfStrings.lockWidgetEmpty
                : workout.currentExercise,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AfText.strong(t, size: 20),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '${workout.repsInput}',
                style: TextStyle(
                  color: t.accent,
                  fontSize: 42,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  AfStrings.lockWidgetReps,
                  style: AfText.muted(t, size: 12),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${workout.weightInput} kg',
                  style: AfText.strong(t, size: 15),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              Expanded(
                child: AfButton(
                  label: '−1',
                  variant: AfButtonVariant.tint,
                  size: AfButtonSize.medium,
                  expand: true,
                  fontSize: 16,
                  onPressed: () => state.incrementRepCounter(-1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AfButton(
                  label: '+1',
                  variant: AfButtonVariant.tint,
                  size: AfButtonSize.medium,
                  expand: true,
                  fontSize: 16,
                  onPressed: () => state.incrementRepCounter(1),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: AfButton(
                  label: AfStrings.lockWidgetAddSet,
                  size: AfButtonSize.medium,
                  expand: true,
                  onPressed: () => _addSet(context, state),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AfButton(
            label: AfStrings.lockWidgetNext,
            variant: AfButtonVariant.secondary,
            size: AfButtonSize.medium,
            expand: true,
            icon: Icon(
              Icons.skip_next,
              size: 16,
              color: t.textPrimary,
            ),
            onPressed:
                exerciseIndex < 0 ? null : () => state.stepActiveExercise(1),
          ),
          if (restVisible) ...<Widget>[
            const SizedBox(height: 12),
            _RestStrip(state: state),
          ],
        ],
      ),
    );
  }

  /// Saves the set through the one write path, then starts the rest countdown
  /// inside the widget (the lock screen never opens the timer screen).
  void _addSet(BuildContext context, AppState state) {
    final String? error = state.logCurrentSet(inputMethod: 'lockscreen');
    if (error != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    state.startRestTimerCountdown();
  }
}

class _RestStrip extends StatelessWidget {
  const _RestStrip({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final bool done = state.restCompleted;
    final int remaining = state.restSecondsRemaining;
    final int total = state.restTotalSeconds;
    final double progress =
        done || total <= 0 ? 1 : (1 - (remaining / total)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: done ? t.successTint : t.bgSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: done ? t.success : t.borderLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                done ? AfStrings.lockWidgetRestOver : AfStrings.lockWidgetRest,
                style: TextStyle(
                  color: done ? t.success : t.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                done ? '00:00' : _mmss(remaining),
                style: TextStyle(
                  color: done ? t.success : t.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: t.borderLine,
              valueColor: AlwaysStoppedAnimation<Color>(
                done ? t.success : t.accent,
              ),
            ),
          ),
          if (!done) ...<Widget>[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: AfButton(
                label: AfStrings.lockWidgetSkip,
                variant: AfButtonVariant.secondary,
                size: AfButtonSize.compact,
                onPressed: state.skipRestTimer,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _mmss(int seconds) =>
      '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
      '${(seconds % 60).toString().padLeft(2, '0')}';
}
