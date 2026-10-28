import 'package:atomfit/services/speech_source.dart';

/// A recognizer the tests drive by hand: [say] plays the part of the phone.
class FakeSpeechSource implements SpeechSource {
  FakeSpeechSource({this.status = SpeechStartStatus.listening});

  /// What [start] reports back (listening, permissionDenied, …).
  SpeechStartStatus status;

  int starts = 0;
  int stops = 0;
  int cancels = 0;
  bool listening = false;

  SpeechWordsCallback? _onWords;

  @override
  Future<SpeechStartStatus> start({
    required SpeechWordsCallback onWords,
    String? localeId,
  }) async {
    starts++;
    _onWords = onWords;
    listening = status == SpeechStartStatus.listening;
    return status;
  }

  /// Sends words to the screen as the real recognizer would.
  void say(String words, {bool isFinal = true}) =>
      _onWords?.call(words, isFinal);

  @override
  Future<void> stop() async {
    stops++;
    listening = false;
  }

  @override
  Future<void> cancel() async {
    cancels++;
    listening = false;
  }
}
