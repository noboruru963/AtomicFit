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
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  '${i + 1}. ${program.exercises[i].name}',
                                  style: TextStyle(
                                    color: t.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ),
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
          Row(
            children: <Widget>[
              Expanded(
                child: AfButton(
                  label: AfStrings.programsStart,
                  size: AfButtonSize.medium,
                  onPressed: () {
                    state.startProgramWorkout(
                      program.id,
                      program.type == 'Micro' ? 'micro' : 'full',
                    );
                    Navigator.of(context).pushNamed(AfScreen.activeWorkout);
                  },
                ),
              ),
              if (!program.active) ...<Widget>[
                const SizedBox(width: 8),
                AfButton(
                  label: AfStrings.programsSetCurrent,
                  variant: AfButtonVariant.secondary,
                  size: AfButtonSize.medium,
                  onPressed: () => state.setActiveProgram(program.id),
                ),
              ],
              const SizedBox(width: 8),
              AfButton(
                label: AfStrings.programsDelete,
                variant: AfButtonVariant.danger,
                size: AfButtonSize.medium,
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

/// The "Create Custom Program" modal (`index.html` lines 2242-2488).
Future<void> _openProgramEditor(
  BuildContext context,
  AppState state,
) async {
  final TextEditingController name = TextEditingController();
  final TextEditingController sets = TextEditingController(text: '3');
  final TextEditingController reps = TextEditingController(text: '10');
  final TextEditingController weight = TextEditingController(text: '15');
  final TextEditingController search = TextEditingController();

  String type = 'Custom';
  String category = 'All';
  bool pickerOpen = false;
  final List<ProgramExercise> selected = <ProgramExercise>[];

  await AfDialog.show<void>(
    context,
    title: AfStrings.programsCreateTitle,
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
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        AfStrings.programsTypeLabel,
                        style: AfText.muted(t, weight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        initialValue: type,
                        isExpanded: true,
                        style: Theme.of(context).textTheme.bodyMedium,
                        items: const <DropdownMenuItem<String>>[
                          DropdownMenuItem<String>(
                            value: 'Custom',
                            child: Text('Custom'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'Micro',
                            child: Text('Micro'),
                          ),
                        ],
                        onChanged: (String? value) {
                          if (value == null) return;
                          setModalState(() => type = value);
                        },
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
                        AfStrings.programsSetsLabel,
                        style: AfText.muted(t, weight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      AfTextField(
                        controller: sets,
                        keyboardType: TextInputType.number,
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
                        AfStrings.programsRepsLabel,
                        style: AfText.muted(t, weight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      AfTextField(
                        controller: reps,
                        keyboardType: TextInputType.number,
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
                        AfStrings.programsWeightLabel,
                        style: AfText.muted(t, weight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      AfTextField(
                        controller: weight,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                              } else {
                                selected.add(
                                  ProgramExercise(
                                    name: exercise.name,
                                    sets: exercise.defaultSets,
                                    reps: exercise.defaultReps,
                                    weightKg: exercise.defaultKg,
                                    exerciseId: exercise.id,
                                  ),
                                );
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
        label: AfStrings.programsSave,
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
          state.createProgram(
            name: name.text.trim(),
            type: type,
            sets: int.tryParse(sets.text) ?? 3,
            reps: int.tryParse(reps.text) ?? 10,
            weightKg: double.tryParse(weight.text) ?? 15,
            exercises: selected,
          );
          Navigator.of(context).pop();
        },
      ),
    ],
  );

  name.dispose();
  sets.dispose();
  reps.dispose();
  weight.dispose();
  search.dispose();
}

String _trim(double value) {
  final String text = value.toStringAsFixed(1);
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}
