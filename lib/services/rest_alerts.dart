import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Rest-timer feedback that is not a notification: the supplied bell chime and
/// the haptics (ported from the prototype's `bell.mp3` and
/// `navigator.vibrate`).
///
/// OS notifications live in `AfNotifications`
/// (`lib/services/notifications.dart`).
class RestAlerts {
  RestAlerts._();

  static final RestAlerts instance = RestAlerts._();

  /// Three buzzes with a gap between them, in milliseconds.
  ///
  /// Android reads the list as "wait, buzz, wait, buzz, …", so the leading 0
  /// starts the first pulse immediately.
  static const List<int> _buzzPattern = <int>[0, 220, 140, 220, 140, 220];

  final AudioPlayer _player = AudioPlayer();

  /// Loads the bell asset so the first chime plays without a delay.
  Future<void> warmUp() async {
    try {
      await _player.setSource(AssetSource('bell.mp3'));
    } catch (error) {
      debugPrint('RestAlerts: bell unavailable ($error)');
    }
  }

  /// Plays the completion bell. Never throws.
  Future<void> playBell() async {
    try {
      await _player.stop();
      await _player.setSource(AssetSource('bell.mp3'));
      await _player.resume();
    } catch (error) {
      debugPrint('RestAlerts: bell playback failed ($error)');
    }
  }

  /// A short three-pulse buzz, so the rest-over moment is felt and not only
  /// heard.
  ///
  /// This drives the Android vibrator directly rather than going through
  /// `HapticFeedback`: the window-level haptics are routed through the system's
  /// "touch vibration" feedback and are silent on many phones (and whenever the
  /// app is in the background). The fallback keeps the old behaviour for
  /// devices without a vibrator.
  Future<void> vibrate() async {
    try {
      if (await Vibration.hasVibrator()) {
        await Vibration.vibrate(pattern: _buzzPattern);
        return;
      }
    } catch (error) {
      debugPrint('RestAlerts: vibrator unavailable ($error)');
    }
    try {
      for (int pulse = 0; pulse < 3; pulse++) {
        await HapticFeedback.heavyImpact();
        if (pulse < 2) {
          await Future<void>.delayed(const Duration(milliseconds: 220));
        }
      }
    } catch (error) {
      debugPrint('RestAlerts: vibration failed ($error)');
    }
  }
}
