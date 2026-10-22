/// The persistence seam.
///
/// The UI and the app state only ever talk to this interface, so the local
/// implementation below can later be swapped for a cloud implementation
/// without touching a single screen. See `lib/data/README.md`.
abstract class AtomFitStore {
  /// Reads the persisted document, or `null` when nothing has been stored yet.
  Future<Map<String, dynamic>?> read();

  /// Writes the whole document.
  Future<void> write(Map<String, dynamic> document);
}
