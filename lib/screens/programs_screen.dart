import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderProgramsScreen()` (`index.html` lines 2002-2067) including
/// the program editor and delete confirmation modals.
class ProgramsScreen extends StatelessWidget {
  const ProgramsScreen({super.key});

  static const List<String> _filters = <String>[
    'All',
    'Push Pull Leg',
    'Upper Lower',
    'Micro',
    'Custom',
  ];

  List<Program> _filtered(AppState state) {
    return state.programs.where((Program program) {
      if (state.programsFilter == 'All') return true;
      if (state.programsFilter == 'Push Pull Leg' ||
          state.programsFilter == 'Upper Lower') {
        return program.splitGroup == state.programsFilter;
      }
      return program.type.toLowerCase() == state.programsFilter.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final List<Program> programs = _filtered(state);

    return AfScaffold(
      screenId: AfScreen.programs,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  AfStrings.programsIntro,
                  style: AfText.muted(t),
                ),
              ),
              const SizedBox(width: 8),
              AfButton(
                label: AfStrings.programsNew,
                variant: AfButtonVariant.tint,
                size: AfButtonSize.compact,
                onPressed: () => _openProgramEditor(context, state),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              for (final String filter in _filters)
                AfButton(
                  label: filter,
                  variant: state.programsFilter == filter
                      ? AfButtonVariant.primary
                      : AfButtonVariant.secondary,
                  size: AfButtonSize.compact,
                  onPressed: () => state.setProgramsFilter(filter),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (programs.isEmpty)
            AfCard(
              padding: const EdgeInsets.all(24),
              child: Text(
                AfStrings.programsEmpty,
                textAlign: TextAlign.center,
                style: AfText.muted(t),
              ),
            )
          else
            for (final Program program in programs) ...<Widget>[
              _ProgramCard(program: program),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({required this.program});

  final Program program;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);

    return AfCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          program.name,
                          style: AfText.strong(t, size: 16),
                        ),
                        AfBadge(
                          label: program.splitGroup.isEmpty
                              ? program.type
                              : program.splitGroup,
                          fontSize: 10,
                        ),
                        if (program.active)
                          const AfBadge(
                            label: AfStrings.badgeCurrent,
                            tone: AfBadgeTone.green,
                            fontSize: 10,
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AfStrings.fill(AfStrings.programsMeta, <String, Object?>{
                        'duration': program.duration,
                        'frequency': program.frequency,
                        'count': program.exercises.length,
                      }),
                      style: AfText.muted(t),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AfSubtle(
            padding: const EdgeInsets.all(12),
            child: program.exercises.isEmpty
                ? Text(
                    AfStrings.programsNoExercises,
                    style: AfText.muted(t),
                  )
                : Column(
                    children: <Widget>[
                      for (int i = 0; i < program.exercises.length; i++)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: i == program.exercises.length - 1
                                    ? Colors.transparent
                                    : t.borderLine,
                              ),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '${i + 1}. ${program.exercises[i].name}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: t.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              // Keeps long exercise names from touching the
                              // sets column.
                              const SizedBox(width: 10),
                              Text(
                                AfStrings.fill(
                                  AfStrings.programsExerciseRow,
                                  <String, Object?>{
                                    'sets': program.exercises[i].sets,
                                    'reps': program.exercises[i].reps,
                                    'kg': _trim(program.exercises[i].weightKg),
                                  },
                                ),
                                style: AfText.muted(t),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
          AfButton(
            label: AfStrings.programsStart,
            size: AfButtonSize.medium,
            expand: true,
            onPressed: () {
              state.startProgramWorkout(
                program.id,
                program.type == 'Micro' ? 'micro' : 'full',
              );
              Navigator.of(context).pushNamed(AfScreen.activeWorkout);
            },
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              AfButton(
                label: AfStrings.programsEdit,
                variant: AfButtonVariant.secondary,
                size: AfButtonSize.compact,
                onPressed: () =>
                    _openProgramEditor(context, state, existing: program),
              ),
              if (!program.active)
                AfButton(
                  label: AfStrings.programsSetCurrent,
                  variant: AfButtonVariant.secondary,
                  size: AfButtonSize.compact,
                  onPressed: () => state.setActiveProgram(program.id),
                ),
              AfButton(
                label: AfStrings.programsDelete,
                variant: AfButtonVariant.danger,
                size: AfButtonSize.compact,
                onPressed: () => _confirmDelete(context, state, program),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    AppState state,
    Program program,
  ) async {
    final AfTokens t = context.af;
    await AfDialog.show<void>(
      context,
      title: AfStrings.fill(AfStrings.programsDeleteTitle, <String, Object?>{
        'name': program.name,
      }),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            AfStrings.fill(AfStrings.programsDeleteBody, <String, Object?>{
              'name': program.name,
            }),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (program.active) ...<Widget>[
            const SizedBox(height: 12),
            AfSubtle(
              padding: const EdgeInsets.all(10),
              child: Container(
                padding: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: t.warning, width: 3),
                  ),
                ),
                child: Text(
                  AfStrings.programsDeleteActiveWarning,
                  style: TextStyle(
                    color: t.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: <Widget>[
        AfButton(
          label: AfStrings.cancel,
          variant: AfButtonVariant.secondary,
          size: AfButtonSize.compact,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AfButton(
          label: AfStrings.programsDelete,
          variant: AfButtonVariant.danger,
          size: AfButtonSize.compact,
          onPressed: () {
            Navigator.of(context).pop();
            state.deleteProgram(program.id);
          },
        ),
      ],
    );
  }
}

/// The program editor, used to create a program and to edit an existing one
/// (`index.html` lines 2242-2488).
///
/// The program itself only asks for a name: sets, reps and weight belong to
/// each exercise row, because one global value cannot describe a real program.
Future<void> _openProgramEditor(
  BuildContext context,
  AppState state, {
  Program? existing,
}) async {
  final bool editing = existing != null;
  final TextEditingController name =
      TextEditingController(text: existing?.name ?? '');
  final TextEditingController search = TextEditingController();

  final List<ProgramExercise> selected = <ProgramExercise>[
    ...?existing?.exercises,
  ];
  // Every input set ever created, so a removed exercise still has its
  // controllers disposed when the editor closes.
  final List<_ExerciseInputs> createdInputs = <_ExerciseInputs>[];
  _ExerciseInputs inputsFor(ProgramExercise exercise) {
    final _ExerciseInputs entry = _ExerciseInputs(exercise);
    createdInputs.add(entry);
    return entry;
  }

  final Map<String, _ExerciseInputs> inputs = <String, _ExerciseInputs>{
    for (final ProgramExercise exercise in selected)
      exercise.name: inputsFor(exercise),
  };

  String category = 'All';
  bool pickerOpen = false;

  await AfDialog.show<void>(
    context,
    title:
        editing ? AfStrings.programsEditTitle : AfStrings.programsCreateTitle,
    scrollable: true,
    body: StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        final AfTokens t = context.af;
        final List<Exercise> matches = state.catalogue.where((Exercise ex) {
          final bool categoryMatch =
              category == 'All' || ex.category == category;
          final String query = search.text.trim().toLowerCase();
          final bool searchMatch = query.isEmpty ||
              ex.name.toLowerCase().contains(query) ||
              ex.description.toLowerCase().contains(query);
          return categoryMatch && searchMatch;
        }).toList();

        Widget numberField(
          String label,
          TextEditingController controller, {
          bool decimal = false,
        }) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(label, style: AfText.muted(t, size: 11)),
              const SizedBox(height: 3),
              AfTextField(
                controller: controller,
                keyboardType: decimal
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.number,
                style: AfText.strong(t, size: 13),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              AfStrings.programsNameLabel,
              style: AfText.muted(t, weight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            AfTextField(
              controller: name,
              hint: AfStrings.programsNamePlaceholder,
            ),
            const SizedBox(height: 14),
            Row(
              children: <Widget>[
                Text(
                  AfStrings.fill(
                      AfStrings.programsSelectedExercises, <String, Object?>{
                    'count': selected.length,
                  }),
                  style: AfText.strong(t, size: 12),
                ),
                const Spacer(),
                AfButton(
                  label: pickerOpen
                      ? AfStrings.programsDoneSelecting
                      : AfStrings.programsAddExercise,
                  variant: AfButtonVariant.tint,
                  size: AfButtonSize.compact,
                  onPressed: () =>
                      setModalState(() => pickerOpen = !pickerOpen),
                ),
              ],
            ),
            if (selected.isNotEmpty) ...<Widget>[
              const SizedBox(height: 4),
              Text(
                AfStrings.programsPerExercise,
                style: AfText.muted(t, size: 11),
              ),
              const SizedBox(height: 8),
              for (final ProgramExercise exercise in selected)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: AfSubtle(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                exercise.name,
                                style: AfText.strong(t, size: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Tooltip(
                              message: AfStrings.programsRemoveExercise,
                              child: GestureDetector(
                                onTap: () => setModalState(() {
                                  selected.removeWhere(
                                    (ProgramExercise e) =>
                                        e.name == exercise.name,
                                  );
                                  inputs.remove(exercise.name);
                                }),
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
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              child: numberField(
                                AfStrings.programsSetsLabel,
                                inputs[exercise.name]!.sets,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: numberField(
                                AfStrings.programsRepsLabel,
                                inputs[exercise.name]!.reps,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: numberField(
                                AfStrings.programsWeightLabel,
                                inputs[exercise.name]!.weight,
                                decimal: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            if (pickerOpen) ...<Widget>[
              const SizedBox(height: 8),
              AfTextField(
                controller: search,
                onChanged: (_) => setModalState(() {}),
                hint: AfStrings.discoverSearchPlaceholder,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: <Widget>[
                  for (final String cat in const <String>[
                    'All',
                    'Chest',
                    'Shoulders',
                    'Back',
                    'Core',
                    'Arms',
                    'Legs',
                    'Custom',
                  ])
                    AfButton(
                      label: cat,
                      variant: category == cat
                          ? AfButtonVariant.primary
                          : AfButtonVariant.secondary,
                      size: AfButtonSize.compact,
                      onPressed: () => setModalState(() => category = cat),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 176),
                child: SingleChildScrollView(
                  child: Column(
                    children: <Widget>[
                      for (final Exercise exercise in matches)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            exercise.name,
                            style: AfText.strong(t, size: 13),
                          ),
                          subtitle: Text(
                            exercise.category,
                            style: AfText.muted(t, size: 11),
                          ),
                          trailing: selected.any(
                            (ProgramExercise e) => e.name == exercise.name,
                          )
                              ? const Icon(Icons.check, size: 18)
                              : const Icon(Icons.add, size: 18),
                          onTap: () {
                            setModalState(() {
                              if (selected.any(
                                (ProgramExercise e) => e.name == exercise.name,
                              )) {
                                selected.removeWhere(
                                  (ProgramExercise e) =>
                                      e.name == exercise.name,
                                );
                                inputs.remove(exercise.name);
                              } else {
                                final ProgramExercise added = ProgramExercise(
                                  name: exercise.name,
                                  sets: exercise.defaultSets,
                                  reps: exercise.defaultReps,
                                  weightKg: exercise.defaultKg,
                                  exerciseId: exercise.id,
                                );
                                selected.add(added);
                                inputs[exercise.name] = inputsFor(added);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    ),
    actions: <Widget>[
      AfButton(
        label: AfStrings.cancel,
        variant: AfButtonVariant.secondary,
        size: AfButtonSize.compact,
        onPressed: () => Navigator.of(context).pop(),
      ),
      AfButton(
        label: editing ? AfStrings.programsSaveChanges : AfStrings.programsSave,
        size: AfButtonSize.compact,
        onPressed: () {
          if (name.text.trim().isEmpty) {
            state.showToast(
              AfStrings.programsNameRequired,
              kind: ToastKind.danger,
            );
            return;
          }
          if (selected.isEmpty) {
            state.showToast(
              AfStrings.programsExerciseRequired,
              kind: ToastKind.danger,
            );
            return;
          }
          final List<ProgramExercise> exercises = <ProgramExercise>[
            for (final ProgramExercise exercise in selected)
              inputs[exercise.name]!.apply(exercise),
          ];
          if (editing) {
            state.updateProgram(
              id: existing.id,
              name: name.text.trim(),
              exercises: exercises,
            );
          } else {
            final Program created = state.createProgram(
              name: name.text.trim(),
              exercises: exercises,
            );
            state.showToast(
              AfStrings.fill(AfStrings.programsCreatedToast, <String, Object?>{
                'name': created.name,
              }),
              kind: ToastKind.success,
            );
          }
          Navigator.of(context).pop();
        },
      ),
    ],
  );

  for (final _ExerciseInputs input in createdInputs) {
    input.dispose();
  }
  name.dispose();
  search.dispose();
}

/// The three number boxes that belong to one selected exercise.
class _ExerciseInputs {
  _ExerciseInputs(ProgramExercise exercise)
      : sets = TextEditingController(text: '${exercise.sets}'),
        reps = TextEditingController(text: '${exercise.reps}'),
        weight = TextEditingController(text: _trim(exercise.weightKg));

  final TextEditingController sets;
  final TextEditingController reps;
  final TextEditingController weight;

  /// Reads the boxes back into an exercise, keeping the stored value when a box
  /// is empty or unreadable.
  ProgramExercise apply(ProgramExercise exercise) {
    final int? enteredSets = int.tryParse(sets.text.trim());
    final int? enteredReps = int.tryParse(reps.text.trim());
    final double? enteredWeight = double.tryParse(weight.text.trim());
    return exercise.copyWith(
      sets: enteredSets == null ? exercise.sets : enteredSets.clamp(1, 20),
      reps: enteredReps == null ? exercise.reps : enteredReps.clamp(1, 999),
      weightKg: enteredWeight == null
          ? exercise.weightKg
          : enteredWeight.clamp(0, 999.9),
    );
  }

  void dispose() {
    sets.dispose();
    reps.dispose();
    weight.dispose();
  }
}

String _trim(double value) {
  final String text = value.toStringAsFixed(1);
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}
