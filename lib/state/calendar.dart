import '../models/app_models.dart';

/// The local calendar day a finished workout belongs to.
///
/// A session stores its start as a UTC timestamp. Converting that timestamp
/// back to local time gives the day the user actually trained on, which is the
/// day the calendar must mark. Comparing only `dayOfMonth` (the old behaviour)
/// made an October 26th workout appear again on November 26th.
///
/// Returns `null` when the timestamp cannot be parsed; such a record is left
/// off the calendar rather than being placed on a day it may not belong to.
DateTime? sessionLocalDay(WorkoutSession session) {
  final DateTime? parsed = DateTime.tryParse(session.startedAtUtc);
  if (parsed == null) return null;
  final DateTime local = parsed.isUtc ? parsed.toLocal() : parsed;
  return DateTime(local.year, local.month, local.day);
}

/// Whether [session] was logged on the local calendar day [day].
bool sessionIsOn(WorkoutSession session, DateTime day) {
  final DateTime? local = sessionLocalDay(session);
  if (local == null) return false;
  return local.year == day.year &&
      local.month == day.month &&
      local.day == day.day;
}

/// The sessions whose local calendar day falls in [month]'s year and month.
List<WorkoutSession> sessionsInMonth(
  List<WorkoutSession> sessions,
  DateTime month,
) {
  return sessions.where((WorkoutSession session) {
    final DateTime? local = sessionLocalDay(session);
    return local != null &&
        local.year == month.year &&
        local.month == month.month;
  }).toList(growable: false);
}

/// How many workouts were logged in [month]'s year and month.
int workoutsInMonth(List<WorkoutSession> sessions, DateTime month) =>
    sessionsInMonth(sessions, month).length;
