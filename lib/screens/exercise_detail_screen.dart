import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../data/db/catalogue.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderExerciseDetailScreen()` (`index.html` lines 4606-4740).
///
/// Shows the illustrations, the target muscles, the step-by-step
/// instructions and the form tips of one catalogue exercise.
class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final Exercise? exercise = state.selectedExercise;

    if (exercise == null) {
      return AfScaffold(
        screenId: AfScreen.discoverDetail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AfButton(
              label: AfStrings.detailBackToDiscover,
              variant: AfButtonVariant.secondary,
              size: AfButtonSize.compact,
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 16),
            AfCard(
              padding: const EdgeInsets.all(24),
              child: Text(
                AfStrings.discoverEmptyTitle,
                textAlign: TextAlign.center,
                style: AfText.muted(t),
              ),
            ),
          ],
        ),
      );
    }

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
    final String category = formatExerciseIdentifier(
      exercise.exerciseCategory.isEmpty
          ? exercise.category
          : exercise.exerciseCategory,
    );
    final List<String> primaryMuscles = exercise.primaryMuscles
        .map(formatExerciseIdentifier)
        .where((String m) => m.isNotEmpty)
        .toList(growable: false);
    final List<String> secondaryMuscles = exercise.secondaryMuscles
        .map(formatExerciseIdentifier)
        .where((String m) => m.isNotEmpty)
        .toList(growable: false);
    final List<String> goals = exercise.goals
        .map(formatExerciseIdentifier)
        .where((String g) => g.isNotEmpty)
        .toList(growable: false);
    final List<ExerciseIllustration> illustrations =
        exerciseIllustrations(exercise.images);
    final String description = exercise.descriptionEn.isEmpty
        ? exercise.description
        : exercise.descriptionEn;

    return AfScaffold(
      screenId: AfScreen.discoverDetail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: AfButton(
                  label: AfStrings.detailBackToDiscover,
                  variant: AfButtonVariant.secondary,
                  size: AfButtonSize.compact,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AfButton(
                  label: AfStrings.discoverAddToWorkout,
                  size: AfButtonSize.compact,
                  onPressed: () {
                    state.addExerciseToWorkoutAndProgram(
                      name: name,
                      sets: exercise.defaultSets,
                      reps: exercise.defaultReps,
                      weightKg: exercise.defaultKg,
                      category: bodyPart,
                    );
                    state.showToast(
                      AfStrings.fill(
                        AfStrings.discoverAddedToast,
                        <String, Object?>{'name': name},
                      ),
                    );
                    Navigator.of(context).pushNamed(AfScreen.activeWorkout);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ------------------------------------------------------ hero card
          AfCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: <Widget>[
                    AfBadge(label: bodyPart, fontSize: 12),
                    AfBadge(
                      label: difficulty.isEmpty ? 'Beginner' : difficulty,
                      fontSize: 12,
                      tone: difficulty == 'Advanced'
                          ? AfBadgeTone.amber
                          : (difficulty == 'Beginner'
                              ? AfBadgeTone.green
                              : AfBadgeTone.blue),
                    ),
                    AfBadge(label: equipment, fontSize: 12),
                    if (category.isNotEmpty)
                      AfBadge(label: category, fontSize: 12),
                    if (exercise.isUnilateral)
                      const AfBadge(
                        label: AfStrings.detailUnilateral,
                        fontSize: 12,
                      ),
                    if (exercise.met != null)
                      AfBadge(
                        label: AfStrings.fill(
                          AfStrings.detailMet,
                          <String, Object?>{'value': exercise.met},
                        ),
                        fontSize: 12,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(name, style: AfText.strong(t, size: 18)),
                const SizedBox(height: 12),
                if (illustrations.isEmpty)
                  Column(
                    children: <Widget>[
                      Icon(
                        Icons.fitness_center,
                        size: 40,
                        color: t.accent.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AfStrings.detailIllustrationPlaceholder,
                        style: AfText.muted(t, size: 12),
                      ),
                    ],
                  )
                else
                  Row(
                    children: <Widget>[
                      for (final ExerciseIllustration illustration
                          in illustrations) ...<Widget>[
                        Expanded(
                          child: _Illustration(
                            illustration: illustration,
                            name: name,
                          ),
                        ),
                        if (illustration != illustrations.last)
                          const SizedBox(width: 10),
                      ],
                    ],
                  ),
                const SizedBox(height: 14),
                Text(
                  AfStrings.detailDescription.toUpperCase(),
                  style: AfText.muted(t, size: 11),
                ),
                const SizedBox(height: 4),
                Text(description, style: AfText.muted(t, size: 12)),
                if (goals.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    '${AfStrings.detailGoals} ${goals.join(' · ')}',
                    style: AfText.muted(t, size: 11),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ---------------------------------------------------- target muscles
          AfCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AfStrings.detailTargetMuscles,
                  style: AfText.strong(t, size: 14),
                ),
                const SizedBox(height: 10),
                Text(
                  AfStrings.detailPrimaryMuscles,
                  style: TextStyle(
                    color: t.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                if (primaryMuscles.isEmpty)
                  AfBadge(label: bodyPart, fontSize: 12)
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      for (final String muscle in primaryMuscles)
                        AfBadge(label: muscle, fontSize: 12),
                    ],
                  ),
                const SizedBox(height: 10),
                Text(
                  AfStrings.detailSecondaryMuscles,
                  style: AfText.muted(t, size: 12),
                ),
                const SizedBox(height: 6),
                if (secondaryMuscles.isEmpty)
                  Text(AfStrings.detailNone, style: AfText.muted(t, size: 12))
                else
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: <Widget>[
                      for (final String muscle in secondaryMuscles)
                        AfBadge(label: muscle, fontSize: 12),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ----------------------------------------------------- instructions
          AfCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AfStrings.detailDescription,
                  style: AfText.strong(t, size: 14),
                ),
                const SizedBox(height: 10),
                if (exercise.instructions.isEmpty)
                  Text(
                    AfStrings.detailNoInstructions,
                    style: AfText.muted(t, size: 12),
                  )
                else
                  for (int index = 0;
                      index < exercise.instructions.length;
                      index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: 24,
                            height: 24,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: t.accentTint,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: t.accentTintText,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              exercise.instructions[index],
                              style: AfText.muted(t, size: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),

          // --------------------------------------------------------- form tips
          if (exercise.tips.isNotEmpty) ...<Widget>[
            const SizedBox(height: 12),
            AfCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AfStrings.detailFormTips,
                    style: AfText.strong(t, size: 14),
                  ),
                  const SizedBox(height: 10),
                  for (final String tip in exercise.tips)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '✓',
                            style: TextStyle(
                              color: t.success,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(tip, style: AfText.muted(t, size: 12)),
                          ),
                        ],
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

/// One illustration of an exercise (start / peak position).
class _Illustration extends StatelessWidget {
  const _Illustration({required this.illustration, required this.name});

  final ExerciseIllustration illustration;
  final String name;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final String url = toRepDbRemoteUrl(illustration.relPath);

    return Column(
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 150,
            color: const Color(0xFF0F172A),
            child: url.isEmpty
                ? Center(
                    child: Icon(
                      Icons.fitness_center,
                      color: t.accent.withValues(alpha: 0.7),
                    ),
                  )
                : Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (
                      BuildContext context,
                      Object error,
                      StackTrace? stackTrace,
                    ) =>
                        Center(
                      child: Icon(
                        Icons.fitness_center,
                        color: t.accent.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          illustration.label,
          style: AfText.muted(t, size: 11),
        ),
      ],
    );
  }
}
