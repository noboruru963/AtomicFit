import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderDiscoverScreen()` (`index.html` lines 3874-3941).
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _customName = TextEditingController();
  final TextEditingController _customWeight = TextEditingController(text: '15');
  final TextEditingController _customReps = TextEditingController(text: '10');
  final TextEditingController _search = TextEditingController();
  String _customCategory = 'Custom';
  String? _error;

  static const List<String> _categories = <String>[
    'All',
    'Chest',
    'Shoulders',
    'Back',
    'Core',
    'Arms',
    'Legs',
    'Custom',
  ];

  @override
  void dispose() {
    _customName.dispose();
    _customWeight.dispose();
    _customReps.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final String query = state.catalogueSearch.trim().toLowerCase();

    final List<Exercise> items = state.catalogue.where((Exercise exercise) {
      final bool categoryMatch = state.catalogueFilter == 'All' ||
          exercise.category == state.catalogueFilter;
      final bool searchMatch = query.isEmpty ||
          exercise.name.toLowerCase().contains(query) ||
          exercise.description.toLowerCase().contains(query);
      return categoryMatch && searchMatch;
    }).toList();

    void submitCustom() {
      final String name = _customName.text.trim();
      if (name.isEmpty) {
        setState(() => _error = AfStrings.discoverNameRequired);
        state.showToast(
          AfStrings.discoverNameRequiredToast,
          kind: ToastKind.danger,
        );
        return;
      }
      setState(() => _error = null);
      state.addExerciseToWorkoutAndProgram(
        name: name,
        sets: 3,
        reps: int.tryParse(_customReps.text) ?? 10,
        weightKg: double.tryParse(_customWeight.text) ?? 15,
        category: _customCategory,
      );
      _customName.clear();
      state.showToast(
        AfStrings.fill(AfStrings.discoverCustomAddedToast, <String, Object?>{
          'name': name,
        }),
      );
    }

    return AfScaffold(
      screenId: AfScreen.discover,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // --------------------------------------------- custom exercise entry
          AfCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(
                      AfStrings.discoverCustomTitle,
                      style: AfText.strong(t, size: 14),
                    ),
                    const Spacer(),
                    const AfBadge(
                      label: AfStrings.discoverManualEntry,
                      fontSize: 10,
                    ),
                  ],
                ),
                if (_error != null) ...<Widget>[
                  const SizedBox(height: 10),
                  AfErrorBanner(message: _error!),
                ],
                const SizedBox(height: 10),
                AfTextField(
                  controller: _customName,
                  style: AfText.muted(t, size: 12),
                  hint: AfStrings.discoverCustomNamePlaceholder,
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _customCategory,
                        isExpanded: true,
                        style: AfText.muted(t, size: 12),
                        items: <DropdownMenuItem<String>>[
                          for (final String category in _categories.skip(1))
                            DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            ),
                        ],
                        onChanged: (String? value) {
                          if (value == null) return;
                          setState(() => _customCategory = value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AfTextField(
                        controller: _customWeight,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: AfText.muted(t, size: 12),
                        hint: AfStrings.discoverWeightPlaceholder,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AfTextField(
                        controller: _customReps,
                        keyboardType: TextInputType.number,
                        style: AfText.muted(t, size: 12),
                        hint: AfStrings.discoverRepsPlaceholder,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AfButton(
                  label: AfStrings.discoverAddCustom,
                  size: AfButtonSize.medium,
                  expand: true,
                  onPressed: submitCustom,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ------------------------------------------------ search and filters
          AfTextField(
            controller: _search,
            style: AfText.muted(t, size: 12),
            hint: AfStrings.discoverSearchPlaceholder,
            onChanged: state.setCatalogueSearch,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              for (final String category in _categories)
                AfButton(
                  label: category,
                  variant: state.catalogueFilter == category
                      ? AfButtonVariant.primary
                      : AfButtonVariant.secondary,
                  size: AfButtonSize.compact,
                  onPressed: () => state.setCatalogueFilter(category),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // ---------------------------------------------------------- catalogue
          if (items.isEmpty)
            AfCard(
              padding: const EdgeInsets.all(24),
              child: Text(
                AfStrings.discoverEmpty,
                textAlign: TextAlign.center,
                style: AfText.muted(t),
              ),
            )
          else
            for (final Exercise exercise in items) ...<Widget>[
              AfCard(
                padding: const EdgeInsets.all(14),
                child: Row(
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
                                exercise.name,
                                style: AfText.strong(t, size: 14),
                              ),
                              AfBadge(
                                label: exercise.category,
                                fontSize: 10,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            exercise.description,
                            style: AfText.muted(t),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AfStrings.fill(
                                AfStrings.discoverTarget, <String, Object?>{
                              'kg': _trim(exercise.defaultKg),
                              'reps': exercise.defaultReps,
                            }),
                            style: TextStyle(
                              color: t.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AfButton(
                      label: AfStrings.discoverAdd,
                      variant: AfButtonVariant.tint,
                      size: AfButtonSize.compact,
                      onPressed: () {
                        state.addExerciseToWorkoutAndProgram(
                          name: exercise.name,
                          sets: exercise.defaultSets,
                          reps: exercise.defaultReps,
                          weightKg: exercise.defaultKg,
                          category: exercise.category,
                        );
                        state.showToast(
                          AfStrings.fill(
                            AfStrings.discoverAddedToast,
                            <String, Object?>{'name': exercise.name},
                          ),
                        );
                        Navigator.of(context).pushNamed(AfScreen.activeWorkout);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
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
