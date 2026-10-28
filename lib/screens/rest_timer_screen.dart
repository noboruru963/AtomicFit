import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderTimerScreen()` (`index.html` lines 2666-2731).
class RestTimerScreen extends StatefulWidget {
  const RestTimerScreen({super.key});

  @override
  State<RestTimerScreen> createState() => _RestTimerScreenState();
}

class _RestTimerScreenState extends State<RestTimerScreen> {
  final TextEditingController _minutes = TextEditingController();
  final TextEditingController _seconds = TextEditingController();
  bool _handledFinish = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final AppState state = AfAppScope.of(context);
      state.onRestTimerFinished = _onFinished;
      _handledFinish = false;
      // This screen is always pushed right after a set is logged, so the
      // countdown starts by itself (there is no Start button).
      if (!state.restRunning &&
          !state.restCompleted &&
          state.activeWorkout.restSeconds > 0) {
        state.startRestTimerCountdown();
      }
      _syncInputs(state);
    });
  }

  @override
  void dispose() {
    _minutes.dispose();
    _seconds.dispose();
    super.dispose();
  }

  void _syncInputs(AppState state) {
    final int total = state.activeWorkout.restTotalSeconds;
    _minutes.text = (total ~/ 60).toString().padLeft(2, '0');
    _seconds.text = (total % 60).toString().padLeft(2, '0');
  }

  Future<void> _onFinished() async {
    if (_handledFinish) return;
    _handledFinish = true;
    // The bell, the haptics and the rest-over notification are all driven by
    // the AppState ticker, so they also fire while this screen is not on top.
    final AppState state = AfAppScope.of(context);
    state.showToast(AfStrings.timerCompleteToast);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AfScreen.activeWorkout);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final int total = state.activeWorkout.restTotalSeconds;
    final int remaining = state.restSecondsRemaining;
    final double progress = total <= 0 ? 0 : remaining / total;

    void applyDuration() {
      final int minutes = int.tryParse(_minutes.text) ?? -1;
      final int seconds = int.tryParse(_seconds.text) ?? -1;
      if (minutes < 0 || seconds < 0) {
        state.showToast(AfStrings.timerErrorNotWhole, kind: ToastKind.danger);
        return;
      }
      final String? error = state.setTimerDuration(minutes, seconds);
      if (error != null) {
        state.showToast(error, kind: ToastKind.danger);
        return;
      }
      _syncInputs(state);
    }

    return AfScaffold(
      screenId: AfScreen.timer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AfCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Text(
                    AfStrings.timerTitle.toUpperCase(),
                    style: AfText.sectionHead(t).copyWith(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    _formatClock(remaining),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: t.accent,
                      fontFeatures: const <FontFeature>[
                        FontFeature.tabularFigures(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AfSubtle(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              AfStrings.timerMinutes,
                              style: AfText.muted(t, size: 11),
                            ),
                            const SizedBox(height: 4),
                            AfTextField(
                              controller: _minutes,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: AfText.strong(t, size: 14),
                              onChanged: (_) => applyDuration(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              AfStrings.timerSeconds,
                              style: AfText.muted(t, size: 11),
                            ),
                            const SizedBox(height: 4),
                            AfTextField(
                              controller: _seconds,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: AfText.strong(t, size: 14),
                              onChanged: (_) => applyDuration(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AfButton(
                        label: AfStrings.timerMinus15,
                        variant: AfButtonVariant.secondary,
                        size: AfButtonSize.compact,
                        onPressed: () {
                          state.adjustRestSeconds(-15);
                          _syncInputs(state);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AfButton(
                        label: AfStrings.timerPlus15,
                        variant: AfButtonVariant.secondary,
                        size: AfButtonSize.compact,
                        onPressed: () {
                          state.adjustRestSeconds(15);
                          _syncInputs(state);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AfProgress(value: progress, height: 10),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: 'Target Duration: ',
                        style: AfText.muted(t),
                      ),
                      TextSpan(
                        text: _formatClock(total),
                        style: AfText.strong(t, size: 12),
                      ),
                      TextSpan(
                        text: ' · Exercise: ',
                        style: AfText.muted(t),
                      ),
                      TextSpan(
                        text: state.activeWorkout.currentExercise.isEmpty
                            ? AfStrings.timerGeneralRest
                            : state.activeWorkout.currentExercise,
                        style: AfText.strong(t, size: 12),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AfButton(
                        label: state.restRunning
                            ? AfStrings.timerPause
                            : AfStrings.timerResume,
                        size: AfButtonSize.compact,
                        onPressed: () {
                          if (state.restRunning) {
                            state.pauseRestTimer();
                          } else {
                            _handledFinish = false;
                            state.startRestTimerCountdown();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AfButton(
                        label: AfStrings.timerReset,
                        variant: AfButtonVariant.secondary,
                        size: AfButtonSize.compact,
                        onPressed: () {
                          state.resetRestTimer();
                          _syncInputs(state);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 16),
          AfButton(
            label: AfStrings.timerBackToWorkout,
            size: AfButtonSize.large,
            fontSize: 16,
            expand: true,
            onPressed: () => Navigator.of(context)
                .pushReplacementNamed(AfScreen.activeWorkout),
          ),
        ],
      ),
    );
  }
}

String _formatClock(int totalSeconds) {
  final int minutes = (totalSeconds ~/ 60).clamp(0, 999);
  final int seconds = (totalSeconds % 60).clamp(0, 59);
  return '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}
