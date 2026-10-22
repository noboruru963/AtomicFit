import '../../models/app_models.dart';
import 'catalogue_loader.dart';
import 'exercise_repository.dart';

/// Prepares a freshly created database.
///
/// Imports the RepDB exercise catalogue once (650 records) so the Discover
/// screen has something to search.
class DatabaseBootstrap {
  const DatabaseBootstrap._();

  /// Imports the catalogue when the `exercises` table is still empty.
  ///
  /// Returns the number of imported records (0 when the catalogue was
  /// already present).
  static Future<int> ensureCatalogue(ExerciseRepository repository) async {
    final int existing = await repository.countCatalogue();
    if (existing > 0) return 0;

    final List<Exercise> catalogue = await CatalogueLoader.loadFromAsset();
    if (catalogue.isEmpty) return 0;
    await repository.upsertAll(catalogue);
    return catalogue.length;
  }
}
