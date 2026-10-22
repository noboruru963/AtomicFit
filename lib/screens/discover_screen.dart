import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../data/db/catalogue.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderDiscoverScreen()` (`index.html` lines 4516-4554) with the
/// new search, body-part filters, result count and pagination.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _search = TextEditingController();

  /// The body-part options of the custom-exercise dialog.
  static const List<String> _customBodyParts = <String>[
    'chest',
    'back',
    'shoulders',
    'upper_arms',
    'lower_arms',
    'core',
    'hips',
    'upper_legs',
    'lower_legs',
    'full_body',
    'other',
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openCustomExercise() async {
    final TextEditingController name = TextEditingController();
    final TextEditingController weight = TextEditingController(text: '15');
    final TextEditingController reps = TextEditingController(text: '10');
    String bodyPart = 'other';
    String? error;
    StateSetter? setModalState;

    await AfDialog.show<void>(
      context,
      title: AfStrings.discoverCustomTitle,
      body: StatefulBuilder(
        builder: (BuildContext context, StateSetter setter) {
          setModalState = setter;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (error != null) ...<Widget>[
                AfErrorBanner(message: error!),
                const SizedBox(height: 10),
              ],
              Text(
                AfStrings.discoverCustomNamePlaceholder,
                style: AfText.muted(context.af, size: 12),
              ),
              const SizedBox(height: 6),
              AfTextField(controller: name),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: bodyPart,
                isExpanded: true,
                style: AfText.muted(context.af, size: 12),
                items: <DropdownMenuItem<String>>[
                  for (final String option in _customBodyParts)
                    DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ),
                ],
                onChanged: (String? value) {
                  if (value != null) bodyPart = value;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: AfTextField(
                      controller: weight,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AfTextField(
                      controller: reps,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
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
          label: AfStrings.discoverAddCustom,
          size: AfButtonSize.compact,
          onPressed: () {
            final String value = name.text.trim();
            if (value.isEmpty) {
              setModalState?.call(
                () => error = AfStrings.discoverCustomNameRequired,
              );
              return;
            }
            final AppState state = AfAppScope.of(context);
            state.addExerciseToWorkoutAndProgram(
              name: value,
              sets: 3,
              reps: int.tryParse(reps.text) ?? 10,
              weightKg: double.tryParse(weight.text) ?? 15,
              category: bodyPart,
            );
            state.showToast(
              AfStrings.fill(
                AfStrings.discoverCustomAddedToast,
                <String, Object?>{'name': value},
              ),
            );
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  void _addToWorkout(Exercise exercise) {
    final AppState state = AfAppScope.of(context);
    state.addExerciseToWorkoutAndProgram(
      name: exercise.nameEn.isEmpty ? exercise.name : exercise.nameEn,
      sets: exercise.defaultSets,
      reps: exercise.defaultReps,
      weightKg: exercise.defaultKg,
      category: exercise.bodyPartLabel.isEmpty
          ? exercise.category
          : exercise.bodyPartLabel,
    );
    state.showToast(
      AfStrings.fill(
        AfStrings.discoverAddedToast,
        <String, Object?>{'name': exercise.name},
      ),
    );
    Navigator.of(context).pushNamed(AfScreen.activeWorkout);
  }

  void _openDetail(Exercise exercise) {
    final AppState state = AfAppScope.of(context);
    state.openExerciseDetail(exercise.id);
    Navigator.of(context).pushNamed(AfScreen.discoverDetail);
  }

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final String filter = state.catalogueFilter;
    final String search = state.catalogueSearch;
    final int limit = state.discoverVisibleLimit;

    return AfScaffold(
      screenId: AfScreen.discover,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ------------------------------------------------- header and search
          AfCard(
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
                          Text(
                            AfStrings.discoverTitle,
                            style: AfText.strong(t, size: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AfStrings.fill(
                              AfStrings.discoverSubtitle,
                              <String, Object?>{
                                'count': state.catalogue.length,
                              },
                            ),
                            style: AfText.muted(t, size: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AfButton(
                      label: AfStrings.discoverCustom,
                      variant: AfButtonVariant.tint,
                      size: AfButtonSize.compact,
                      onPressed: _openCustomExercise,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AfTextField(
                        controller: _search,
                        style: AfText.muted(t, size: 12),
                        hint: AfStrings.discoverSearchPlaceholder,
                        onChanged: state.setCatalogueSearch,
                      ),
                    ),
                    if (search.isNotEmpty || filter != 'All') ...<Widget>[
                      const SizedBox(width: 8),
                      AfButton(
                        label: AfStrings.discoverClear,
                        variant: AfButtonVariant.secondary,
                        size: AfButtonSize.compact,
                        onPressed: state.resetCatalogueFilters,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    for (final String option in state.availableCatalogueFilters)
                      AfButton(
                        label: option,
                        variant: filter == option
                            ? AfButtonVariant.primary
                            : AfButtonVariant.secondary,
                        size: AfButtonSize.compact,
                        onPressed: () => state.setCatalogueFilter(option),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---------------------------------------------------------- results
          FutureBuilder<_CataloguePage>(
            future: _loadPage(state, limit),
            builder: (
              BuildContext context,
              AsyncSnapshot<_CataloguePage> snapshot,
            ) {
              final _CataloguePage page =
                  snapshot.data ?? const _CataloguePage(<Exercise>[], 0);
              final List<Exercise> items = page.items;
              final int total = page.total;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          total == 1
                              ? AfStrings.discoverResultCountOne
                              : AfStrings.fill(
                                  AfStrings.discoverResultCount,
                                  <String, Object?>{'count': total},
                                ),
                          style: AfText.muted(t, size: 12),
                        ),
                      ),
                      if (filter != 'All' || search.isNotEmpty)
                        GestureDetector(
                          onTap: state.resetCatalogueFilters,
                          child: Text(
                            AfStrings.fill(
                              AfStrings.discoverShowAll,
                              <String, Object?>{
                                'count': state.catalogue.length,
                              },
                            ),
                            style: TextStyle(
                              color: t.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (items.isEmpty)
                    AfCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: <Widget>[
                          Text(
                            AfStrings.discoverEmptyTitle,
                            textAlign: TextAlign.center,
                            style: AfText.strong(t, size: 14),
                          ),
                          const SizedBox(height: 12),
                          AfButton(
                            label: AfStrings.discoverResetFilters,
                            variant: AfButtonVariant.secondary,
                            size: AfButtonSize.compact,
                            onPressed: state.resetCatalogueFilters,
                          ),
                        ],
                      ),
                    )
                  else ...<Widget>[
                    for (final Exercise exercise in items) ...<Widget>[
                      _ExerciseCard(
                        exercise: exercise,
                        onOpen: () => _openDetail(exercise),
                        onAdd: () => _addToWorkout(exercise),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (total > items.length)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: AfButton(
                          label: AfStrings.fill(
                            AfStrings.discoverShowMore,
                            <String, Object?>{
                              'count': total - items.length,
                            },
                          ),
                          variant: AfButtonVariant.secondary,
                          size: AfButtonSize.medium,
                          expand: true,
                          onPressed: state.showMoreCatalogue,
                        ),
                      ),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 12),
          Center(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: '${AfStrings.discoverRepDbFooter} ',
                    style: AfText.muted(t, size: 12),
                  ),
                  TextSpan(
                    text: AfStrings.discoverRepDbLink,
                    style: TextStyle(
                      color: t.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The result page of the Discover screen: the visible exercises and the
/// total number of matches.
class _CataloguePage {
  const _CataloguePage(this.items, this.total);

  final List<Exercise> items;
  final int total;
}

/// Loads one page of Discover results.
Future<_CataloguePage> _loadPage(AppState state, int limit) async {
  final List<Exercise> items = await state.searchCatalogue(limit: limit);
  final int total = await state.countCatalogue();
  return _CataloguePage(items, total);
}

/// One exercise in the Discover list.
class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
    required this.exercise,
    required this.onOpen,
    required this.onAdd,
  });

  final Exercise exercise;
  final VoidCallback onOpen;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final String name =
        exercise.nameEn.isEmpty ? exercise.name : exercise.nameEn;
    final String bodyPart = exercise.bodyPartLabel.isEmpty
        ? normalizeExerciseBodyPart(
            exercise.bodyPart.isEmpty ? exercise.category : exercise.bodyPart,
            primaryMuscles: exercise.primaryMuscles,
          )
        : exercise.bodyPartLabel;
    final String difficulty = formatExerciseIdentifier(exercise.difficulty);
    final String equipment = exercise.equipment.trim().isNotEmpty &&
            exercise.equipment.trim().toLowerCase() != 'none'
        ? formatExerciseIdentifier(exercise.equipment)
        : (exercise.isBodyweight ? 'Bodyweight' : 'No equipment');
    final String target = exercise.primaryMuscles.isEmpty
        ? bodyPart
        : exercise.primaryMuscles
            .map(formatExerciseIdentifier)
            .where((String m) => m.isNotEmpty)
            .join(', ');
    final String description = exercise.descriptionEn.isEmpty
        ? exercise.description
        : exercise.descriptionEn;

    return AfCard(
      padding: const EdgeInsets.all(14),
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _Thumbnail(exercise: exercise),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(name, style: AfText.strong(t, size: 14)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: <Widget>[
                        AfBadge(label: bodyPart, fontSize: 10),
                        AfBadge(
                          label: difficulty.isEmpty ? 'Beginner' : difficulty,
                          fontSize: 10,
                          tone: difficulty == 'Advanced'
                              ? AfBadgeTone.amber
                              : (difficulty == 'Beginner'
                                  ? AfBadgeTone.green
                                  : AfBadgeTone.blue),
                        ),
                        Text(
                          equipment,
                          style: AfText.muted(t, size: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AfStrings.fill(
                        AfStrings.discoverTargetMuscles,
                        <String, Object?>{'muscles': target},
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: t.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AfText.muted(t, size: 12),
            ),
          ],
          const SizedBox(height: 10),
          Divider(height: 1, color: t.borderLine),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: AfButton(
                  label: AfStrings.discoverViewInstructions,
                  variant: AfButtonVariant.tint,
                  size: AfButtonSize.compact,
                  onPressed: onOpen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AfButton(
                  label: AfStrings.discoverAddToWorkout,
                  variant: AfButtonVariant.secondary,
                  size: AfButtonSize.compact,
                  onPressed: onAdd,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The exercise illustration, loaded from the dataset host.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final String url = toRepDbRemoteUrl(exerciseThumbnailPath(exercise.images));

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        height: 64,
        color: const Color(0xFF0F172A),
        child: url.isEmpty
            ? _placeholder(t)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (
                  BuildContext context,
                  Object error,
                  StackTrace? stackTrace,
                ) =>
                    _placeholder(t),
                loadingBuilder: (
                  BuildContext context,
                  Widget child,
                  ImageChunkEvent? progress,
                ) =>
                    progress == null ? child : _placeholder(t),
              ),
      ),
    );
  }

  Widget _placeholder(AfTokens t) => Center(
        child: Icon(
          Icons.fitness_center,
          size: 24,
          color: t.accent.withValues(alpha: 0.7),
        ),
      );
}
