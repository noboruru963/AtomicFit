import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// The seam [AppState] uses to keep the rest-timer notification in step with
/// the countdown.
///
/// The app wires [AfNotifications] in `main.dart`; tests leave it unset, which
/// makes every call a no-op.
abstract class RestTimerNotifier {
  /// Shows, or refreshes, the ongoing notification for a running countdown.
  void showProgress({required String exercise, required DateTime endTime});

  /// Replaces the ongoing notification with the "rest over" alert.
  void showFinished({required String exercise});

  /// Removes the ongoing notification and its pending alert.
  void cancelProgress();
}

/// The seam [AppState] uses to keep reminders for planned workouts in the
/// operating system's alarm list.
abstract class WorkoutReminderScheduler {
  /// Schedules, or replaces, the reminder for one planned workout.
  Future<void> scheduleWorkoutReminder({
    required String scheduleId,
    required String programName,
    required DateTime when,
  });

  /// Cancels the reminder for a planned workout.
  Future<void> cancelWorkoutReminder(String scheduleId);
}

/// Local notifications: the live rest countdown, the rest-over alert and the
/// reminders for workouts scheduled from the Home calendar.
///
/// Everything here is local to the device — nothing is sent anywhere.
class AfNotifications implements RestTimerNotifier, WorkoutReminderScheduler {
  AfNotifications._();

  static final AfNotifications instance = AfNotifications._();

  static const int _restProgressId = 1002;
  static const int _restFinishedId = 1001;
  static const int _reminderBaseId = 2000;

  static const String _restProgressChannel = 'rest_timer_progress';
  // Android channels are immutable once created, so the vibration pattern
  // needs a new id to reach installs that already have the old channel.
  static const String _restFinishedChannel = 'rest_timer_v2';
  static const String _reminderChannel = 'workout_reminder';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  /// Whether the plugin initialised, i.e. whether notifications can be shown.
  bool get isReady => _ready;

  /// Prepares the plugin, the time zone database and the notification
  /// channels. Safe to call more than once.
  Future<void> init() async {
    if (_ready) return;
    try {
      await _configureTimeZone();
      const InitializationSettings settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      );
      await _plugin.initialize(settings);
      _ready = true;
    } catch (error) {
      debugPrint('AfNotifications: unavailable ($error)');
    }
  }

  /// Asks for the notification permission the first time something needs it,
  /// rather than at launch, so the prompt arrives with context.
  Future<void> _ensurePermission() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? android = _android;
      if (android == null) return;
      await android.requestNotificationsPermission();
    } catch (error) {
      debugPrint('AfNotifications: permission request failed ($error)');
    }
  }

  /// Uses the device's IANA zone so scheduled reminders land on the right
  /// wall-clock time, including after a time-zone change.
  Future<void> _configureTimeZone() async {
    tz_data.initializeTimeZones();
    try {
      final TimezoneInfo info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (error) {
      debugPrint('AfNotifications: local time zone unavailable ($error)');
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  /// Exact alarms when Android allows them, otherwise the closest inexact
  /// mode, so a denied permission degrades instead of failing.
  Future<AndroidScheduleMode> _scheduleMode() async {
    try {
      final bool exact =
          await _android?.canScheduleExactNotifications() ?? false;
      return exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.inexactAllowWhileIdle;
    } catch (error) {
      return AndroidScheduleMode.inexactAllowWhileIdle;
    }
  }

  // ------------------------------------------------------------- rest timer

  @override
  void showProgress({required String exercise, required DateTime endTime}) {
    unawaited(_showProgress(exercise, endTime));
  }

  Future<void> _showProgress(String exercise, DateTime endTime) async {
    if (!_ready) return;
    try {
      await _ensurePermission();
      await _plugin.show(
        _restProgressId,
        'Rest timer',
        '$exercise · tap to go back to your workout',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _restProgressChannel,
            'Rest timer (running)',
            channelDescription:
                'Live rest countdown while the app is in the background.',
            importance: Importance.low,
            priority: Priority.low,
            ongoing: true,
            autoCancel: false,
            onlyAlertOnce: true,
            silent: true,
            showWhen: true,
            // A countdown driven by the OS: no per-second work in Dart and it
            // keeps ticking when the app is backgrounded or killed.
            when: endTime.millisecondsSinceEpoch,
            usesChronometer: true,
            chronometerCountDown: true,
            category: AndroidNotificationCategory.stopwatch,
          ),
        ),
      );
      await _scheduleRestFinished(exercise, endTime);
    } catch (error) {
      debugPrint('AfNotifications: rest notification failed ($error)');
    }
  }

  /// Backstop for when Android kills the app before the countdown ends: the
  /// alert still fires at the right time.
  Future<void> _scheduleRestFinished(String exercise, DateTime endTime) async {
    if (!endTime.isAfter(DateTime.now())) return;
    await _plugin.zonedSchedule(
      _restFinishedId,
      'Rest over',
      'Time for your next set of $exercise.',
      tz.TZDateTime.from(endTime, tz.local),
      _finishedDetails(),
      androidScheduleMode: await _scheduleMode(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  @override
  void showFinished({required String exercise}) {
    unawaited(_showFinished(exercise));
  }

  Future<void> _showFinished(String exercise) async {
    if (!_ready) return;
    final bool background =
        WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed;
    try {
      // The scheduled backstop is no longer needed: either this call shows the
      // alert, or the screen is on top and shows the toast instead.
      await _plugin.cancel(_restProgressId);
      await _plugin.cancel(_restFinishedId);
      if (!background) return;
      await _ensurePermission();
      await _plugin.show(
        _restFinishedId,
        'Rest over',
        'Time for your next set of $exercise.',
        _finishedDetails(),
      );
    } catch (error) {
      debugPrint('AfNotifications: rest alert failed ($error)');
    }
  }

  NotificationDetails _finishedDetails() => NotificationDetails(
        android: AndroidNotificationDetails(
          _restFinishedChannel,
          'Rest timer',
          channelDescription: 'Alerts when a rest period finishes.',
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          // Background rest has to be felt too: a short vibration pattern on
          // the channel, independent of whether the in-app haptics fired.
          enableVibration: true,
          vibrationPattern: Int64List.fromList(<int>[0, 400, 200, 400]),
        ),
      );

  @override
  void cancelProgress() {
    unawaited(_cancelProgress());
  }

  Future<void> _cancelProgress() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(_restProgressId);
      await _plugin.cancel(_restFinishedId);
    } catch (error) {
      debugPrint('AfNotifications: cancel failed ($error)');
    }
  }

  // ------------------------------------------------------- workout reminder

  /// Schedules (or reschedules) the reminder for one planned workout.
  @override
  Future<void> scheduleWorkoutReminder({
    required String scheduleId,
    required String programName,
    required DateTime when,
  }) async {
    if (!_ready || !when.isAfter(DateTime.now())) return;
    try {
      await _ensurePermission();
      await _plugin.zonedSchedule(
        _reminderId(scheduleId),
        'Time to train',
        '$programName is scheduled for now. Log it. Keep going.',
        tz.TZDateTime.from(when, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _reminderChannel,
            'Workout reminders',
            channelDescription: 'Reminders for the workouts you scheduled.',
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
          ),
        ),
        androidScheduleMode: await _scheduleMode(),
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'workout:$scheduleId',
      );
    } catch (error) {
      debugPrint('AfNotifications: reminder failed ($error)');
    }
  }

  /// Cancels the reminder for a planned workout.
  @override
  Future<void> cancelWorkoutReminder(String scheduleId) async {
    if (!_ready) return;
    try {
      await _plugin.cancel(_reminderId(scheduleId));
    } catch (error) {
      debugPrint('AfNotifications: reminder cancel failed ($error)');
    }
  }

  /// A stable notification id for a scheduled workout.
  int _reminderId(String scheduleId) =>
      _reminderBaseId + (scheduleId.hashCode & 0x7fffffff);
}
