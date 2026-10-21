import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Rest-timer alerts: the supplied bell chime, haptics and the optional
/// background notification (ported from the prototype's `bell.mp3`,
/// `navigator.vibrate` and `Notification` usage).
class RestAlerts {
  RestAlerts._();

  static final RestAlerts instance = RestAlerts._();

  final AudioPlayer _player = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _notificationsReady = false;

  /// Prepares the notification plugin. Safe to call more than once.
  Future<void> init() async {
    if (_notificationsReady) return;
    try {
      await _notifications.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        ),
      );
      final AndroidFlutterLocalNotificationsPlugin? android =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      _notificationsReady = true;
    } catch (error) {
      debugPrint('RestAlerts: notifications unavailable ($error)');
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

  Future<void> vibrate() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    } catch (error) {
      debugPrint('RestAlerts: vibration failed ($error)');
    }
  }

  /// Shows the background notification used when the app is not in the
  /// foreground when the rest period ends.
  Future<void> showRestNotification(String exerciseName) async {
    if (!_notificationsReady) return;
    try {
      await _notifications.show(
        1001,
        'AtomFit — Rest Period Ended',
        'Your rest timer for $exerciseName has finished. '
            'Ready for your next set!',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'rest_timer',
            'Rest Timer',
            channelDescription: 'Alerts when a rest period finishes.',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
      );
    } catch (error) {
      debugPrint('RestAlerts: notification failed ($error)');
    }
  }
}
