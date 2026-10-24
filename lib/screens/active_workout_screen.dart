import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderActiveWorkoutScreen()` (`index.html` lines 2522-2656).
class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _reps = TextEditingController();
  final TextEditingController _voice = TextEditingController();
  String? _weightError;
  String? _voiceError;
  bool _syncing = false;

  @override
  void dispose() {
    _weight.dispose();
    _reps.dispose();
    _voice.dispose();
    super.dispose();
  }

  void _syncInputs(AppState state) {
    if (_syncing) return;
    _syncing = true;
    _weight.text = state.activeWorkout.weightInput;
    _reps.text = state.activeWorkout.repsInput.toString();
    _voice.text = state.activeWorkout.voiceSimText;
    _syncing = false;
  }

  /// Runs the voice log through the fixed instruction table and reacts to the
  /// outcome: rep changes stay on this screen, a finished set opens the timer,
  /// and an unrecognised line shows the retry hint without touching the set.
  void _runVoiceCommand(AppState state) {
    final VoiceCommandResult result = state.applyVoiceCommand(_voice.text);
    final bool saved = result.outcome == VoiceOutcome.saved;
    switch (result.outcome) {
      case VoiceOutcome.adjusted:
      case VoiceOutcome.saved:
        _clearVoice(state);
        setState(() {
          _voiceError = null;
          if (saved) _weightError = null;
        });
        if (saved) {
          Navigator.of(context).pushNamed(AfScreen.timer);
        }
      case VoiceOutcome.unknown:
        setState(() => _voiceError = AfStrings.workoutVoiceUnknown);
      case VoiceOutcome.rejected:
        setState(() {
          _voiceError = null;
          _weightError = result.error;
        });
    }
  }

  /// Empties the voice box after a command, in the widget and in the draft.
  void _clearVoice(AppState state) {
    _voice.clear();
    state.activeWorkout = state.activeWorkout.copyWith(voiceSimText: '');
  }

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final ActiveWorkout workout = state.activeWorkout;
    final ProgramExercise? target = state.currentTarget;
    final int logged = state.loggedCountFor(workout.currentExercise);

    if (!_syncing &&
        (_weight.text != workout.weightInput ||
            _reps.text != workout.repsInput.toString())) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _syncInputs(state);
      });
    }

    return AfScaffold(
      screenId: AfScreen.activeWorkout,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ------------------------------------------------ current exercise
          AfCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Navigation arrows first, spread across the top.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _StepButton(
                      label: '<',
                      tooltip: AfStrings.previousExercise,
                      enabled: workout.exercises.length > 1 &&
                          workout.exercises.indexWhere(
                                (ProgramExercise e) =>
                                    e.name == workout.currentExercise,
                              ) >
                              0,
                      onTap: () => state.stepActiveExercise(-1),
                    ),
                    _StepButton(
                      label: '>',
                      tooltip: AfStrings.nextExercise,
                      enabled: workout.exercises.length > 1 &&
                          workout.exercises.indexWhere(
                                (ProgramExercise e) =>
                                    e.name == workout.currentExercise,
                              ) <
                              workout.exercises.length - 1,
                      onTap: () => state.stepActiveExercise(1),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Center(
                  child: AfSectionHead(AfStrings.workoutCurrentExercise),
                ),
                const SizedBox(height: 6),
                Center(
                  child: workout.exercises.isEmpty
                      ? Text(
                          workout.currentExercise.isEmpty
                              ? AfStrings.workoutNoneSelected
                              : workout.currentExercise,
                          style: Theme.of(context).textTheme.titleMedium,
                        )
                      : ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: DropdownButtonFormField<String>(
                            initialValue: workout.exercises.any(
                                    (ProgramExercise e) =>
                                        e.name == workout.currentExercise)
                                ? workout.currentExercise
                                : workout.exercises.first.name,
                            isExpanded: true,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                            items: <DropdownMenuItem<String>>[
                              for (final ProgramExercise exercise
                                  in workout.exercises)
                                DropdownMenuItem<String>(
                                  value: exercise.name,
                                  child: Text(
                                    exercise.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                            onChanged: (String? value) {
                              if (value == null) return;
                              state.changeActiveExercise(value);
                              setState(() => _weightError = null);
                            },
                          ),
                        ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: workout.currentExercise.isNotEmpty && target != null
                      ? Text.rich(
                          TextSpan(
                            children: <InlineSpan>[
                              TextSpan(
                                text: AfStrings.fill(
                                  AfStrings.workoutTarget,
                                  <String, Object?>{
                                    'sets': target.sets,
                                    'reps': target.reps,
                                    'kg': _trim(target.weightKg),
                                  },
                                ),
                                style: AfText.muted(t),
                              ),
                              const TextSpan(text: ' '),
                              TextSpan(
                                text: '· ',
                                style: AfText.muted(t),
                              ),
                              TextSpan(
                                text: AfStrings.fill(
                                  AfStrings.workoutLogged,
                                  <String, Object?>{
                                    'done': logged,
                                    'total': target.sets,
                                  },
                                ),
                                style: AfText.muted(t),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          AfStrings.workoutNoExerciseHint,
                          style: AfText.muted(t),
                          textAlign: TextAlign.center,
                        ),
                ),
                const SizedBox(height: 14),
                if (workout.inputMethod == 'sensor')
                  _ChannelHelper(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '⌚ ${AfStrings.workoutAutoCount} '
                            '${state.sensorSimActive ? AfStrings.workoutCounting : AfStrings.workoutReady}',
                            style: AfText.muted(t, size: 12),
                          ),
                        ),
                        AfButton(
                          label: state.sensorSimActive
                              ? AfStrings.workoutStopSensor
                              : AfStrings.workoutStartAutoCount,
                          variant: state.sensorSimActive
                              ? AfButtonVariant.danger
                              : AfButtonVariant.tint,
                          size: AfButtonSize.compact,
                          onPressed: state.toggleSensorSimulation,
                        ),
                      ],
                    ),
                  )
                else if (workout.inputMethod == 'voice')
                  _ChannelHelper(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: AfTextField(
                                controller: _voice,
                                style: AfText.muted(t, size: 12),
                                hint: AfStrings.workoutVoicePlaceholder,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _runVoiceCommand(state),
                                onChanged: (String value) =>
                                    state.activeWorkout =
                                        state.activeWorkout.copyWith(
                                  voiceSimText: value,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            AfButton(
                              label: AfStrings.workoutVoiceRun,
                              variant: AfButtonVariant.tint,
                              size: AfButtonSize.compact,
                              onPressed: () => _runVoiceCommand(state),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AfStrings.workoutVoiceHint,
                          style: AfText.muted(t, size: 11),
                        ),
                        if (_voiceError != null) ...<Widget>[
                          const SizedBox(height: 8),
                          AfErrorBanner(
                            message: _voiceError!,
                            padding: const EdgeInsets.all(10),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            for (final String example
                                in AfStrings.voiceCommandExamples)
                              AfButton(
                                label: example,
                                variant: AfButtonVariant.secondary,
                                size: AfButtonSize.compact,
                                onPressed: () {
                                  _voice.text = example;
                                  _runVoiceCommand(state);
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  )
                else if (workout.inputMethod == 'lockscreen')
                  _ChannelHelper(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            '${AfStrings.workoutLockscreen} '
                            '${workout.weightInput} kg × ${workout.repsInput} reps',
                            style: AfText.muted(t, size: 12),
                          ),
                        ),
                        AfButton(
                          label: AfStrings.workoutAddSet,
                          variant: AfButtonVariant.tint,
                          size: AfButtonSize.compact,
                          onPressed: () {
                            final String? error = state.logCurrentSet();
                            if (error != null) {
                              setState(() => _weightError = error);
                              return;
                            }
                            setState(() => _weightError = null);
                            Navigator.of(context).pushNamed(AfScreen.timer);
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 4),
                if (_weightError != null) ...<Widget>[
                  AfErrorBanner(
                    message: _weightError!,
                    padding: const EdgeInsets.all(10),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AfStrings.workoutWeightLabel,
                            style: AfText.muted(t, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          AfTextField(
                            controller: _weight,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textAlign: TextAlign.center,
                            emphasised: true,
                            onChanged: state.updateWeightInput,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AfStrings.workoutRepsLabel,
                            style: AfText.muted(t, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          AfTextField(
                            controller: _reps,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            emphasised: true,
                            onChanged: (String value) => state.updateRepsInput(
                              int.tryParse(value) ?? 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AfWorkoutButton(
                        label: AfStrings.workoutMinusOneRep,
                        onPressed: () => state.incrementRepCounter(-1),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AfWorkoutButton(
                        label: AfStrings.workoutPlusOneRep,
                        onPressed: () => state.incrementRepCounter(1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AfWorkoutButton(
                  label: AfStrings.workoutAddSet,
                  onPressed: () {
                    final String? error = state.logCurrentSet();
                    if (error != null) {
                      setState(() => _weightError = error);
                      return;
                    }
                    setState(() => _weightError = null);
                    Navigator.of(context).pushNamed(AfScreen.timer);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // --------------------------------------------------- logged sets
          AfCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: AfSectionHead(
                    AfStrings.fill(
                        AfStrings.workoutLoggedSets, <String, Object?>{
                      'count': workout.sets.length,
                    }),
                  ),
                ),
                const SizedBox(height: 2),
                Center(
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: 'Total Vol: ',
                          style: AfText.muted(t, size: 12),
                        ),
                        TextSpan(
                          text: '${state.activeVolume} kg',
                          style: AfText.strong(t, size: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (workout.sets.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      AfStrings.workoutNoSets,
                      textAlign: TextAlign.center,
                      style: AfText.muted(t),
                    ),
                  )
                else
                  for (int i = 0; i < workout.sets.length; i++) ...<Widget>[
                    _LoggedSetRow(
                      index: i,
                      set: workout.sets[i],
                      onRemove: () => state.removeLoggedSet(workout.sets[i].id),
                    ),
                    const SizedBox(height: 6),
                  ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: t.borderLine)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 10),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 320),
                          child: AfButton(
                            label: AfStrings.workoutFinish,
                            size: AfButtonSize.large,
                            expand: true,
                            onPressed: () {
                              if (state.finishActiveWorkout() == null) return;
                              Navigator.of(context).pushReplacementNamed(
                                  AfScreen.workoutComplete);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChannelHelper extends StatelessWidget {
  const _ChannelHelper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AfSubtle(padding: const EdgeInsets.all(10), child: child),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.label,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: AfButton(
          label: label,
          variant: AfButtonVariant.secondary,
          size: AfButtonSize.compact,
          onPressed: enabled ? onTap : null,
        ),
      ),
    );
  }
}

class _LoggedSetRow extends StatelessWidget {
  const _LoggedSetRow({
    required this.index,
    required this.set,
    required this.onRemove,
  });

  final int index;
  final LoggedSet set;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    return AfSubtle(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: <Widget>[
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: t.accentTint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: t.accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: set.exerciseName,
                    style: AfText.strong(t, size: 12),
                  ),
                  if (set.exerciseSetNo > 0)
                    TextSpan(
                      text:
                          ' (${AfStrings.fill(AfStrings.workoutSetNumber, <String, Object?>{
                            'number': set.exerciseSetNo
                          })})',
                      style: AfText.muted(t, size: 11),
                    ),
                  TextSpan(
                    text:
                        '  ${AfStrings.fill(AfStrings.workoutSetSummary, <String, Object?>{
                          'kg': _trim(set.weightKg),
                          'reps': set.reps
                        })}',
                    style: AfText.muted(t, size: 12),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          AfBadge(
            label: set.inputMethod,
            fontSize: 10,
            uppercase: true,
          ),
          const SizedBox(width: 4),
          Tooltip(
            message: AfStrings.removeSet,
            child: GestureDetector(
              onTap: onRemove,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Text(
                  '✕',
                  style: TextStyle(
                    color: t.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _trim(double value) {
  final String text = value.toStringAsFixed(1);
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}
