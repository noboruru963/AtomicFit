/// How the voice log gets its words.
///
/// The app uses the phone's microphone through `SpeechToTextSource`; tests
/// inject a fake so the whole voice flow runs without hardware. Nothing here
/// knows about the plugin, which keeps the screens and the state testable.
library;

/// What happened when the microphone was asked to listen.
enum SpeechStartStatus {
  /// The recognizer is running; words will arrive through the callback.
  listening,

  /// Microphone access was refused (the OS prompt was denied).
  permissionDenied,

  /// This device has no speech recognizer at all.
  unavailable,

  /// The recognizer exists but did not start this time.
  failed,
}

/// Receives recognised text.
///
/// [isFinal] is true for the last result of a listen session, so the caller can
/// run the command once instead of on every partial update.
typedef SpeechWordsCallback = void Function(String words, bool isFinal);

/// A source of recognised speech.
abstract class SpeechSource {
  /// Starts a listen session and forwards the words to [onWords].
  ///
  /// [localeId] pins the recognition language (the commands are English-only),
  /// so a phone set to another locale still understands them.
  Future<SpeechStartStatus> start({
    required SpeechWordsCallback onWords,
    String? localeId,
  });

  /// Ends the session and lets the recognizer send its final result.
  Future<void> stop();

  /// Ends the session without a final result (used when leaving the screen).
  Future<void> cancel();
}

/// A source for platforms without a recognizer, and the default in tests.
class UnavailableSpeechSource implements SpeechSource {
  const UnavailableSpeechSource();

  @override
  Future<SpeechStartStatus> start({
    required SpeechWordsCallback onWords,
    String? localeId,
  }) async =>
      SpeechStartStatus.unavailable;

  @override
  Future<void> stop() async {}

  @override
  Future<void> cancel() async {}
}
