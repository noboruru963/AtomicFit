import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Rest-timer feedback that is not a notification: the supplied bell chime and
/// the haptics (ported from the prototype's `bell.mp3` and
/// `navigator.vibrate`).
///
/// OS notifications live in `AfNotifications`
/// (`lib/services/notifications.dart`).
class RestAlerts {
  RestAlerts._();

  static final RestAlerts instance = RestAlerts._();

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
  /// heard. Two heavy impacts read as a double tap on most phones, so the
  /// pattern adds a third pulse with a visible gap.
  Future<void> vibrate() async {
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
