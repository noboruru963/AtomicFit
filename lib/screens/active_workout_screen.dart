import 'dart:async';

import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../models/app_models.dart';
import '../services/speech_source.dart';
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

  /// Whether the microphone is open right now (drives the Speak/Stop button).
  bool _listening = false;

  /// Whether the auto-count demo block is unfolded. The channel selector is
  /// gone, so this is the only door to that demo.
  bool _showAutoCount = false;

  /// The source an open session belongs to, so leaving the screen can cancel it.
  SpeechSource? _activeSpeech;

  /// Identifies the current listen session. The recognizer can send more than
  /// one final result (and another one when it is stopped), so bumping this
  /// after a command makes every later callback of that session a no-op.
  /// Without it "finished set" saves the set twice.
  int _speechSession = 0;

  @override
  void dispose() {
    _activeSpeech?.cancel();
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

  /// Opens or closes the microphone.
  ///
  /// Partial results land in the box so the user sees the words live; the
  /// final result runs the command, which means "finished set" works hands-free.
  /// When access is refused or the device has no recognizer, the box stays
  /// typeable and the reason is shown above the chips.
  Future<void> _toggleSpeech(AppState state) async {
    if (_listening) {
      setState(() => _listening = false);
      await state.speech.stop();
      return;
    }
    if (!state.micExplained) {
      final bool allowed = await _explainMicrophone();
      if (!allowed || !mounted) return;
      state.micExplained = true;
    }

    final SpeechSource source = state.speech;
    _activeSpeech = source;
    final int session = ++_speechSession;
    final SpeechStartStatus status = await source.start(
      onWords: (String words, bool isFinal) {
        // Ignore late results from an earlier session and everything that
        // arrives after the command of this session already ran.
        if (!mounted || session != _speechSession) return;
        final String text = words.trim();
        setState(() {
          _voice.text = text;
          _voice.selection = TextSelection.collapsed(offset: text.length);
          if (isFinal) _listening = false;
        });
        state.activeWorkout = state.activeWorkout.copyWith(voiceSimText: text);
        if (!isFinal) return;
        // Close the session before acting so a second final result from the
        // same utterance cannot run the command again (one save, one timer).
        _speechSession++;
        unawaited(source.cancel());
        if (text.isEmpty) {
          setState(() => _voiceError = AfStrings.workoutMicEmpty);
          return;
        }
        _runVoiceCommand(state);
      },
    );
    if (!mounted) return;
    setState(() {
      _listening = status == SpeechStartStatus.listening;
      _voiceError = switch (status) {
        SpeechStartStatus.listening => null,
        SpeechStartStatus.permissionDenied => AfStrings.workoutMicDenied,
        SpeechStartStatus.unavailable => AfStrings.workoutMicUnavailable,
        SpeechStartStatus.failed => AfStrings.workoutMicFailed,
      };
    });
  }

  /// Explains what the microphone is for before Android shows its own prompt.
  Future<bool> _explainMicrophone() async {
    final bool? answer = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text(AfStrings.workoutMicExplainTitle),
        content: const Text(AfStrings.workoutMicExplainBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AfStrings.workoutMicExplainCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AfStrings.workoutMicExplainContinue),
          ),
        ],
      ),
    );
    return answer ?? false;
  }

  /// Confirms and then removes every set in one exercise/weight group.
  Future<void> _confirmRemoveGroup(
    AppState state,
    _LoggedSetGroup group,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text(AfStrings.workoutRemoveGroupTitle),
        content: Text(
          AfStrings.fill(
            AfStrings.workoutRemoveGroupBody,
            <String, Object?>{
              'count': group.sets.length,
              'exercise': group.exerciseName,
            },
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AfStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AfStrings.remove),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    state.removeLoggedSets(group.sets.map((LoggedSet set) => set.id));
  }

  /// Opens the selected exercise's guide. The dropdown carries an exercise id
  /// when it came from the catalogue; otherwise the name is matched against
  /// the loaded catalogue, so seeded programs work too.
  void _openExerciseInfo(AppState state) {
    final ProgramExercise? target = state.currentTarget;
    if (target == null) return;
    String? id = target.exerciseId;
    if (id == null || id.isEmpty) {
      final String name = target.name.toLowerCase();
      for (final Exercise exercise in state.catalogue) {
        if (exercise.name.toLowerCase() == name) {
          id = exercise.id;
          break;
        }
      }
    }
    if (id == null || id.isEmpty) {
      state.showToast(AfStrings.discoverEmpty, kind: ToastKind.info);
      return;
    }
    state.openExerciseDetail(id);
    Navigator.of(context).pushNamed(AfScreen.discoverDetail);
  }

  /// Shows the lock-screen concept. The buttons live here in the prototype;
  /// on a real device the same actions sit on the lock screen.
  Future<void> _showLockscreenConcept(AppState state) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text(AfStrings.workoutLockscreenConceptTitle),
        content: const Text(AfStrings.workoutLockscreenConceptBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text(AfStrings.close),
          ),
        ],
      ),
    );
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
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Flexible(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 290),
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
                            IconButton(
                              tooltip: AfStrings.workoutOpenExerciseInfo,
                              onPressed: () => _openExerciseInfo(state),
                              icon: const Icon(Icons.info_outline, size: 20),
                            ),
                          ],
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
                // Voice logging is always available: it is the quickest way to
                // log and needs no channel switch.
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
                              onChanged: (String value) => state.activeWorkout =
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
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _VoiceMicButton(
                          listening: _listening,
                          onPressed: () => _toggleSpeech(state),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _listening
                            ? AfStrings.workoutVoiceListening
                            : AfStrings.workoutVoiceHint,
                        style: AfText.muted(t, size: 11),
                      ),
                      if (workout.voiceHistory.isNotEmpty) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          AfStrings.workoutRecentCommands,
                          style: AfText.muted(
                            t,
                            size: 11,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            for (final String previous in workout.voiceHistory)
                              AfButton(
                                label: previous,
                                variant: AfButtonVariant.secondary,
                                size: AfButtonSize.compact,
                                onPressed: () {
                                  _voice.text = previous;
                                  _runVoiceCommand(state);
                                },
                              ),
                          ],
                        ),
                      ],
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
                ),
                const SizedBox(height: 8),
                // The demo-only channels stay reachable from here, so removing
                // the Settings selector loses no demo step.
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    AfButton(
                      label: _showAutoCount
                          ? AfStrings.workoutAutoCountHide
                          : AfStrings.workoutAutoCountDemo,
                      variant: AfButtonVariant.secondary,
                      size: AfButtonSize.compact,
                      onPressed: () =>
                          setState(() => _showAutoCount = !_showAutoCount),
                    ),
                    AfButton(
                      label: AfStrings.workoutLockscreenConcept,
                      variant: AfButtonVariant.secondary,
                      size: AfButtonSize.compact,
                      onPressed: () => _showLockscreenConcept(state),
                    ),
                  ],
                ),
                if (_showAutoCount) ...<Widget>[
                  const SizedBox(height: 8),
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
                  ),
                ],
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
                        emphasised: true,
                        onPressed: () => state.incrementRepCounter(-1),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AfWorkoutButton(
                        label: AfStrings.workoutPlusOneRep,
                        emphasised: true,
                        onPressed: () => state.incrementRepCounter(1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AfWorkoutButton(
                  label: AfStrings.workoutAddSet,
                  emphasised: true,
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
                  for (final _LoggedSetGroup group
                      in _groupLoggedSets(workout.sets)) ...<Widget>[
                    _LoggedSetGroupRow(
                      group: group,
                      onRemoveSet: (String setId) =>
                          state.removeLoggedSet(setId),
                      onRemoveGroup: () => _confirmRemoveGroup(state, group),
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

/// The microphone button: a 48 dp pill that opens and closes the recognizer.
class _VoiceMicButton extends StatelessWidget {
  const _VoiceMicButton({required this.listening, required this.onPressed});

  final bool listening;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final Color background = listening ? t.dangerTint : t.accentTint;
    final Color foreground = listening ? t.danger : t.accentTintText;
    final String tooltip = listening
        ? AfStrings.workoutVoiceStopTooltip
        : AfStrings.workoutVoiceSpeakTooltip;

    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: background,
          borderRadius: BorderRadius.circular(t.radiusPill),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(t.radiusPill),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: Text(
                listening
                    ? AfStrings.workoutVoiceStop
                    : AfStrings.workoutVoiceSpeak,
                style: TextStyle(
                  color: foreground,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
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

class _LoggedSetGroup {
  _LoggedSetGroup({required this.exerciseName, required this.weightKg});

  final String exerciseName;
  final double weightKg;
  final List<LoggedSet> sets = <LoggedSet>[];

  /// `6 , 5 , 5` — the reps of every set in the order they were logged.
  String get repsLabel => sets.map((LoggedSet set) => set.reps).join(' , ');
}

/// Groups the draft's sets by exercise and weight, keeping the order in which
/// each group first appears. Two sets at different weights stay separate, so
/// `[Db press (30 kg) : 6 , 5 , 5]` never mixes loads.
List<_LoggedSetGroup> _groupLoggedSets(List<LoggedSet> sets) {
  final List<_LoggedSetGroup> groups = <_LoggedSetGroup>[];
  for (final LoggedSet set in sets) {
    final double weight = double.parse(set.weightKg.toStringAsFixed(1));
    _LoggedSetGroup? group;
    for (final _LoggedSetGroup candidate in groups) {
      if (candidate.exerciseName == set.exerciseName &&
          candidate.weightKg == weight) {
        group = candidate;
        break;
      }
    }
    if (group == null) {
      group = _LoggedSetGroup(exerciseName: set.exerciseName, weightKg: weight);
      groups.add(group);
    }
    group.sets.add(set);
  }
  return groups;
}

/// One `[Exercise (weight kg) : reps…]` line.
///
/// A tap unfolds the individual sets, each with its own ✕. The ✕ on the group
/// removes the whole group after a confirmation.
class _LoggedSetGroupRow extends StatefulWidget {
  const _LoggedSetGroupRow({
    required this.group,
    required this.onRemoveSet,
    required this.onRemoveGroup,
  });

  final _LoggedSetGroup group;
  final ValueChanged<String> onRemoveSet;
  final VoidCallback onRemoveGroup;

  @override
  State<_LoggedSetGroupRow> createState() => _LoggedSetGroupRowState();
}

class _LoggedSetGroupRowState extends State<_LoggedSetGroupRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final _LoggedSetGroup group = widget.group;
    return AfSubtle(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: <Widget>[
                Text(
                  _expanded ? '▾' : '▸',
                  style: AfText.muted(t, size: 12),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: '[',
                          style: AfText.muted(t, size: 12),
                        ),
                        TextSpan(
                          text:
                              '${group.exerciseName} (${_trim(group.weightKg)} kg)',
                          style: AfText.strong(t, size: 12),
                        ),
                        TextSpan(
                          text: ' : ${group.repsLabel}',
                          style: AfText.muted(t, size: 12),
                        ),
                        TextSpan(
                          text: ']',
                          style: AfText.muted(t, size: 12),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Tooltip(
                  message: AfStrings.workoutRemoveGroup,
                  child: GestureDetector(
                    onTap: widget.onRemoveGroup,
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
          ),
          if (_expanded) ...<Widget>[
            const SizedBox(height: 8),
            for (int i = 0; i < group.sets.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: <Widget>[
                    const SizedBox(width: 18),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: t.accentTint,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: t.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AfStrings.fill(
                          AfStrings.workoutSetSummary,
                          <String, Object?>{
                            'kg': _trim(group.sets[i].weightKg),
                            'reps': group.sets[i].reps,
                          },
                        ),
                        style: AfText.muted(t, size: 12),
                      ),
                    ),
                    AfBadge(
                      label: group.sets[i].inputMethod,
                      fontSize: 10,
                      uppercase: true,
                    ),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: AfStrings.removeSet,
                      child: GestureDetector(
                        onTap: () => widget.onRemoveSet(group.sets[i].id),
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
              ),
          ],
        ],
      ),
    );
  }
}

String _trim(double value) {
  final String text = value.toStringAsFixed(1);
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}
