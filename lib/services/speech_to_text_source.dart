import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'speech_source.dart';

/// The real microphone: the Android speech recognizer through the
/// `speech_to_text` plugin.
///
/// Audio is captured and transcribed by the phone's own recognizer and is used
/// only to fill the voice box; nothing is recorded to disk by this app.
class SpeechToTextSource implements SpeechSource {
  SpeechToTextSource({SpeechToText? engine})
      : _engine = engine ?? SpeechToText();

  final SpeechToText _engine;

  /// The commands are English, so the recognizer is pinned to English instead
  /// of following the phone's locale.
  static const String commandLocale = 'en_US';

  bool _initialized = false;
  String? _lastError;

  @override
  Future<SpeechStartStatus> start({
    required SpeechWordsCallback onWords,
    String? localeId,
  }) async {
    if (!_initialized) {
      final bool ready = await _engine.initialize(
        onError: (SpeechRecognitionError error) {
          _lastError = error.errorMsg;
        },
      );
      if (!ready) {
        return _permissionProblem()
            ? SpeechStartStatus.permissionDenied
            : SpeechStartStatus.unavailable;
      }
      _initialized = true;
    }

    try {
      await _engine.listen(
        onResult: (SpeechRecognitionResult result) =>
            onWords(result.recognizedWords, result.finalResult),
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
          localeId: localeId ?? commandLocale,
          listenFor: const Duration(seconds: 15),
          pauseFor: const Duration(seconds: 3),
        ),
      );
      return SpeechStartStatus.listening;
    } on Object {
      return SpeechStartStatus.failed;
    }
  }

  @override
  Future<void> stop() => _engine.stop();

  @override
  Future<void> cancel() => _engine.cancel();

  /// The plugin reports a refused permission as `error_permission`.
  bool _permissionProblem() {
    final String error = _lastError ?? '';
    return error.contains('permission') || error.contains('permission_denied');
  }
}
