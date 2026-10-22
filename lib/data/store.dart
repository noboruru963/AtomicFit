import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Persistence seam.
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

/// Local implementation: a single JSON blob in shared preferences, mirroring
/// the web prototype's `localStorage['atomfit_app_v23']`.
class LocalBlobStore implements AtomFitStore {
  LocalBlobStore({this.key = 'atomfit_app_v23'});

  final String key;

  @override
  Future<Map<String, dynamic>?> read() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
    } on FormatException {
      // A corrupt blob is treated as "no data" — the app re-seeds on launch.
      return null;
    }
    return null;
  }

  @override
  Future<void> write(Map<String, dynamic> document) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(document));
  }
}
