import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/data/db/catalogue_loader.dart';
import 'package:atomfit/models/app_models.dart';

void main() {
  // The catalogue asset ships with the app; the test reads it from disk so it
  // does not need the Flutter asset bundle.
  final File asset = File('assets/data/exercise_catalogue.json');

  test('the bundled catalogue holds the RepDB dataset', () {
    expect(asset.existsSync(), isTrue,
        reason: 'assets/data/exercise_catalogue.json is missing');
    final String raw = asset.readAsStringSync();
    final List<Exercise> catalogue = CatalogueLoader.parse(raw);

    expect(catalogue, hasLength(650));
    expect(
      catalogue.map((Exercise e) => e.id).toSet(),
      hasLength(650),
      reason: 'every exercise needs a unique id',
    );
  });

  test('records carry the full RepDB field set', () {
    final List<Exercise> catalogue = CatalogueLoader.parse(
      asset.readAsStringSync(),
    );
    final Exercise sample = catalogue.firstWhere(
      (Exercise e) => e.id == 'archer-pull-ups',
    );

    expect(sample.name, isNotEmpty);
    expect(sample.description, isNotEmpty);
    expect(sample.bodyPart, 'back');
    expect(sample.bodyPartLabel, 'Back');
    expect(sample.primaryMuscles, isNotEmpty);
    expect(sample.secondaryMuscles, isNotEmpty);
    expect(sample.instructions, isNotEmpty);
    expect(sample.tips, isNotEmpty);
    expect(sample.images['start'], isNotNull);
    expect(sample.difficulty, isNotEmpty);
    expect(sample.equipment, isNotEmpty);
    expect(sample.searchIndex, isNotEmpty);
  });

  test('the body part labels use the prototype vocabulary', () {
    final List<Exercise> catalogue = CatalogueLoader.parse(
      asset.readAsStringSync(),
    );
    const Set<String> allowed = <String>{
      'Chest',
      'Back',
      'Shoulders',
      'Upper Arms',
      'Forearms',
      'Core / Waist',
      'Hips / Glutes',
      'Upper Legs',
      'Lower Legs / Calves',
      'Cardio / Full Body',
      'Stretching / Mobility',
      'Other',
    };
    for (final Exercise exercise in catalogue) {
      expect(
        allowed,
        contains(exercise.bodyPartLabel),
        reason: '${exercise.id} has an unknown body part label',
      );
    }
  });

  test('a record without an id is skipped', () {
    final List<Exercise> catalogue = CatalogueLoader.parse(
      '[{"name":"No id"},{"id":"ok","name":"Fine"}]',
    );
    expect(catalogue, hasLength(1));
    expect(catalogue.first.id, 'ok');
  });
}
