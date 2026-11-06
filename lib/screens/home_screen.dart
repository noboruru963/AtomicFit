import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/shell.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';
import '../state/calendar.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderHomeScreen()` (`index.html` lines 1615-1726).
///
/// The dashboard: welcome card, month calendar built from `state.history`,
/// monthly count, the planned-workout card and the entries into a workout.
/// It only reads state — every action navigates or calls an `AppState` method.
///
/// Gotcha: the grid uses the device clock directly (`DateTime.now()`), so a
/// test that seeds sessions must build them relative to today.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final Program? active = state.getActiveProgram();
    final DateTime now = DateTime.now();
    final int draftSets = state.activeWorkout.sets.length;
    final bool sameProgram =
        active != null && state.activeWorkout.programId == active.id;

    return AfScaffold(
      screenId: AfScreen.home,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ------------------------------------------------ current program
          AfCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            AfStrings.fill(
                                AfStrings.homeWelcome, <String, Object?>{
                              'name': state.user.username,
                            }),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 2),
                          Text.rich(
                            TextSpan(
                              children: <InlineSpan>[
                                TextSpan(
                                  text: '${AfStrings.homeCurrentProgram} ',
                                  style: AfText.muted(t),
                                ),
                                TextSpan(
                                  text: active?.name ?? '',
                                  style: AfText.strong(t, size: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (state.isProgramAdjusted)
                      const AfBadge(
                        label: AfStrings.badgeAdjusted,
                        tone: AfBadgeTone.green,
                        fontSize: 10,
                      )
                    else
                      AfBadge(
                        label: active?.splitGroup ?? active?.type ?? '',
                        fontSize: 10,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                AfButton(
                  label: draftSets > 0 && sameProgram
                      ? AfStrings.fill(
                          AfStrings.homeContinueProgram,
                          <String, Object?>{
                            'program': active.name,
                            'sets': draftSets,
                          },
                        )
                      : AfStrings.fill(
                          AfStrings.homeStartProgram,
                          <String, Object?>{
                            'program': active?.name ?? '',
                          },
                        ),
                  size: AfButtonSize.medium,
                  expand: true,
                  onPressed: () {
                    if (active == null) return;
                    state.startProgramWorkout(active.id, 'full');
                    Navigator.of(context).pushNamed(AfScreen.activeWorkout);
                  },
                ),
              ],
            ),
          ),

          // ------------------------------------------------------- quiz banner
          if (state.showQuizBannerOnHome) ...<Widget>[
            AfCard(
              padding: const EdgeInsets.all(14),
              borderLeftColor: t.accent,
              borderLeftWidth: 4,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          AfStrings.homeQuizTitle,
                          style: TextStyle(
                            color: t.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            height: 1.333,
                          ),
                        ),
                        Text(
                          AfStrings.homeQuizSubtitle,
                          style: AfText.muted(t, size: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AfButton(
                    label: AfStrings.homeQuizButton,
                    size: AfButtonSize.compact,
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AfScreen.quizPrompt),
                  ),
                  const SizedBox(width: 6),
                  AfButton(
                    label: AfStrings.homeDismiss,
                    variant: AfButtonVariant.secondary,
                    size: AfButtonSize.compact,
                    onPressed: state.dismissQuizBanner,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // --------------------------------------------------------- calendar
          AfCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            _monthTitle(now),
                            style: AfText.strong(t, size: 14),
                          ),
                          Text.rich(
                            TextSpan(
                              children: <InlineSpan>[
                                TextSpan(
                                  text: '${AfStrings.homeWorkoutsLogged} ',
                                  style: AfText.muted(t),
                                ),
                                TextSpan(
                                  text: workoutsInMonth(
                                    state.history,
                                    now,
                                  ).toString(),
                                  style: TextStyle(
                                    color: t.accent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pushNamed(AfScreen.history),
                      child: Text(
                        AfStrings.homeHistoryLink,
                        style: TextStyle(
                          color: t.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    for (final String day in const <String>[
                      'M',
                      'T',
                      'W',
                      'T',
                      'F',
                      'S',
                      'S',
                    ])
                      Expanded(
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: t.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                _CalendarGrid(
                  month: now,
                  sessions: state.history,
                  scheduled: state.scheduledWorkouts,
                  onDayTap: (int day) => _inspectDay(context, state, day, now),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // -------------------------------------------------------- up next
          _UpNextCard(state: state),
          const SizedBox(height: 16),

          // ----------------------------------------------------- my programs
          Row(
            children: <Widget>[
              Flexible(
                child: Text(
                  AfStrings.homeMyPrograms,
                  style: AfText.strong(t, size: 14),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(AfScreen.programs),
                child: Text(
                  AfStrings.fill(AfStrings.homeManageAll, <String, Object?>{
                    'count': state.programs.length,
                  }),
                  style: TextStyle(
                    color: t.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final Program program in state.programs.take(4)) ...<Widget>[
            AfCard(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                program.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AfText.strong(t, size: 14),
                              ),
                            ),
                            if (program.active) ...<Widget>[
                              const SizedBox(width: 8),
                              const AfBadge(
                                label: AfStrings.badgeCurrent,
                                tone: AfBadgeTone.green,
                                fontSize: 10,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          program.exercises
                              .map((ProgramExercise e) => e.name)
                              .join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AfText.muted(t),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!program.active)
                    AfButton(
                      label: AfStrings.homeSelect,
                      variant: AfButtonVariant.secondary,
                      size: AfButtonSize.compact,
                      onPressed: () => state.setActiveProgram(program.id),
                    ),
                  if (!program.active) const SizedBox(width: 6),
                  AfButton(
                    label: AfStrings.homeStart,
                    variant: AfButtonVariant.tint,
                    size: AfButtonSize.compact,
                    onPressed: () {
                      state.startProgramWorkout(
                        program.id,
                        program.type == 'Micro' ? 'micro' : 'full',
                      );
                      Navigator.of(context).pushNamed(AfScreen.activeWorkout);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  static String _monthTitle(DateTime date) {
    const List<String> months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  static Future<void> _inspectDay(
    BuildContext context,
    AppState state,
    int day,
    DateTime now,
  ) async {
    final DateTime date = DateTime(now.year, now.month, day);
    final List<WorkoutSession> matches = state.history
        .where((WorkoutSession s) => sessionIsOn(s, date))
        .toList();
    if (matches.isNotEmpty) {
      await _showSessionDetails(context, matches.first);
      return;
    }

    final ScheduledWorkout? planned = state.scheduledOn(date);
    if (planned != null) {
      await _showPlannedDetails(context, state, planned);
      return;
    }

    // Nothing logged and nothing planned. Past days are rest days; today and
    // the days ahead can be planned.
    final DateTime today = DateTime.now();
    if (date.isBefore(DateTime(today.year, today.month, today.day))) {
      state.showToast(
        AfStrings.fill(AfStrings.calendarRestDayToast, <String, Object?>{
          'month': _monthTitle(now).split(' ').first,
          'day': day,
        }),
        kind: ToastKind.info,
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.af.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (BuildContext context) =>
          _ScheduleSheet(state: state, date: date),
    );
  }

  /// Read-only summary of a workout that was logged on its own day.
  ///
  /// The date in the title comes from the session itself, never from the month
  /// the calendar is showing, so an older workout can never be labelled with
  /// the current month.
  static Future<void> _showSessionDetails(
    BuildContext context,
    WorkoutSession session,
  ) async {
    final AfTokens t = context.af;
    final DateTime? loggedOn = sessionLocalDay(session);
    final String month =
        loggedOn == null ? '' : _monthTitle(loggedOn).split(' ').first;
    final int day = loggedOn?.day ?? session.dayOfMonth;
    await AfDialog.show<void>(
      context,
      title: AfStrings.fill(AfStrings.calendarDayTitle, <String, Object?>{
        'month': month,
        'day': day,
        'name': session.name,
      }),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              AfBadge(label: session.type, uppercase: true),
              const SizedBox(width: 8),
              Text(session.dateLabel, style: AfText.muted(t)),
            ],
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text:
                      '${AfStrings.fill(AfStrings.calendarTotalReps, <String, Object?>{
                        'reps': session.reps
                      })} · ',
                  style: AfText.muted(t),
                ),
                TextSpan(
                  text: AfStrings.fill(
                      AfStrings.calendarTotalVolume, <String, Object?>{
                    'volume': session.volume,
                  }),
                  style: AfText.muted(t),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: <Widget>[
        AfButton(
          label: AfStrings.close,
          variant: AfButtonVariant.secondary,
          size: AfButtonSize.compact,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AfButton(
          label: AfStrings.openInHistory,
          size: AfButtonSize.compact,
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(AfScreen.history);
          },
        ),
      ],
    );
  }

  /// Details of a planned workout, with Start and Remove.
  static Future<void> _showPlannedDetails(
    BuildContext context,
    AppState state,
    ScheduledWorkout planned,
  ) async {
    final AfTokens t = context.af;
    await AfDialog.show<void>(
      context,
      title: '${_monthTitle(DateTime(planned.year, planned.month))} '
          '${planned.day}',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const AfBadge(label: 'Scheduled', tone: AfBadgeTone.blue),
              const SizedBox(width: 8),
              Text(_clock(planned.hour, planned.minute),
                  style: AfText.muted(t)),
            ],
          ),
          const SizedBox(height: 8),
          Text(planned.programName, style: AfText.strong(t, size: 14)),
        ],
      ),
      actions: <Widget>[
        AfButton(
          label: AfStrings.scheduleRemove,
          variant: AfButtonVariant.secondary,
          size: AfButtonSize.compact,
          onPressed: () {
            Navigator.of(context).pop();
            state.cancelScheduledWorkout(planned.id);
            state.showToast(AfStrings.scheduleRemovedToast,
                kind: ToastKind.info);
          },
        ),
        AfButton(
          label: AfStrings.homeStart,
          size: AfButtonSize.compact,
          onPressed: () {
            Navigator.of(context).pop();
            state.startProgramWorkout(planned.programId, 'full');
            Navigator.of(context).pushNamed(AfScreen.activeWorkout);
          },
        ),
      ],
    );
  }

  /// `HH:mm` for the given hour and minute.
  static String _clock(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.sessions,
    required this.scheduled,
    required this.onDayTap,
  });

  final DateTime month;
  final List<WorkoutSession> sessions;
  final List<ScheduledWorkout> scheduled;
  final void Function(int day) onDayTap;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Monday-first offset.
    final int leading = DateTime(month.year, month.month, 1).weekday - 1;
    final DateTime today = DateTime.now();
    final bool sameMonth =
        today.year == month.year && today.month == month.month;

    final List<Widget> cells = <Widget>[];
    for (int i = 0; i < leading; i++) {
      cells.add(const SizedBox(height: 32));
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final DateTime date = DateTime(month.year, month.month, day);
      // A session belongs to its own local day, so last month's workouts never
      // mark the same day number in this month.
      final WorkoutSession? session = sessions
          .where((WorkoutSession s) => sessionIsOn(s, date))
          .firstOrNull;
      final bool planned = scheduled.any((ScheduledWorkout s) => s.isOn(date));
      final bool isToday = sameMonth && day == today.day;

      Color background = t.bgSubtle;
      Color foreground = t.textMuted;
      Border? border;

      if (session != null) {
        background = t.accent;
        foreground = Colors.white;
      } else if (planned) {
        background = t.accentTint;
        foreground = t.accentTintText;
        border = Border.all(color: t.accent, width: 1);
      }

      if (isToday) {
        // White reads on the blue "workout logged" fill; on the light empty
        // cell a white ring would be invisible, so accent is used there.
        border = Border.all(
          color: session != null ? Colors.white : t.accent,
          width: 2,
        );
        if (session == null) {
          background = Colors.transparent;
          foreground = t.accent;
        }
      }

      cells.add(
        Semantics(
          label: isToday ? AfStrings.calendarToday : null,
          child: GestureDetector(
            onTap: () => onDayTap(day),
            child: Container(
              key: ValueKey<String>('cal-day-$day'),
              height: 32,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(8),
                border: border,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    '$day',
                    style: TextStyle(
                      color: foreground,
                      fontSize: 11,
                      fontWeight: session != null || isToday || planned
                          ? FontWeight.w700
                          : FontWeight.w400,
                      height: 1.1,
                    ),
                  ),
                  if (session != null)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    )
                  else if (planned)
                    Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: t.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: <Widget>[
        for (int row = 0; row < (cells.length / 7).ceil(); row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: <Widget>[
                for (int column = 0; column < 7; column++)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: row * 7 + column < cells.length
                          ? cells[row * 7 + column]
                          : const SizedBox(height: 32),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final Iterator<T> it = iterator;
    return it.moveNext() ? it.current : null;
  }
}

/// The next workout the user planned, with Start and Cancel.
class _UpNextCard extends StatelessWidget {
  const _UpNextCard({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final ScheduledWorkout? next = state.nextScheduledWorkout;

    return AfCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.event_available_outlined, size: 16, color: t.accent),
              const SizedBox(width: 6),
              Text(AfStrings.homeUpNext, style: AfText.strong(t, size: 14)),
            ],
          ),
          const SizedBox(height: 8),
          if (next == null)
            Text(
              AfStrings.homeUpNextEmpty,
              style: AfText.muted(t).copyWith(height: 1.5),
            )
          else ...<Widget>[
            Text(
              next.programName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AfText.strong(t, size: 15),
            ),
            const SizedBox(height: 2),
            Text(
              '${HomeScreen._monthTitle(
                DateTime(next.year, next.month),
              ).split(' ').first} ${next.day} · '
              '${HomeScreen._clock(next.hour, next.minute)}',
              style: AfText.muted(t),
            ),
            const SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: AfButton(
                    label: AfStrings.homeUpNextStart,
                    size: AfButtonSize.compact,
                    onPressed: () {
                      state.startProgramWorkout(next.programId, 'full');
                      Navigator.of(context).pushNamed(AfScreen.activeWorkout);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                AfButton(
                  label: AfStrings.homeUpNextCancel,
                  variant: AfButtonVariant.secondary,
                  size: AfButtonSize.compact,
                  onPressed: () {
                    state.cancelScheduledWorkout(next.id);
                    state.showToast(
                      AfStrings.scheduleRemovedToast,
                      kind: ToastKind.info,
                    );
                  },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Bottom sheet that plans a workout on an empty calendar day.
///
/// The date comes from the tapped day; the user picks the hour, the minute and
/// the program.
class _ScheduleSheet extends StatefulWidget {
  const _ScheduleSheet({required this.state, required this.date});

  final AppState state;
  final DateTime date;

  @override
  State<_ScheduleSheet> createState() => _ScheduleSheetState();
}

class _ScheduleSheetState extends State<_ScheduleSheet> {
  late int _hour;
  late int _minute;
  late String _programId;
  late final TextEditingController _hourCtrl;
  late final TextEditingController _minuteCtrl;

  /// Set when the typed time is out of range, so the sheet can explain why
  /// the Schedule button is disabled.
  String? _timeError;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    final bool isToday = widget.date.year == now.year &&
        widget.date.month == now.month &&
        widget.date.day == now.day;
    // Today: the next full hour. A later day: the usual evening slot.
    _hour = isToday ? (now.hour + 1).clamp(0, 23) : 18;
    _minute = isToday && now.hour >= 23 ? 55 : 0;
    _hourCtrl = TextEditingController(text: _two(_hour));
    _minuteCtrl = TextEditingController(text: _two(_minute));
    _programId = widget.state.programs.isEmpty
        ? ''
        : widget.state.getActiveProgram()?.id ?? widget.state.programs.first.id;
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  static String _two(int value) => value.toString().padLeft(2, '0');

  /// Reads the two number boxes and keeps the planned time in step with them.
  ///
  /// Out-of-range values never reach the schedule: the sheet shows the rule
  /// that was broken instead (0-23 hours, 0-59 minutes).
  void _onTimeChanged() {
    final int? hour = int.tryParse(_hourCtrl.text.trim());
    final int? minute = int.tryParse(_minuteCtrl.text.trim());
    String? error;
    if (hour == null || hour < 0 || hour > 23) {
      error = AfStrings.scheduleHourError;
    } else if (minute == null || minute < 0 || minute > 59) {
      error = AfStrings.scheduleMinuteError;
    }
    setState(() {
      _timeError = error;
      if (hour != null && hour >= 0 && hour <= 23) _hour = hour;
      if (minute != null && minute >= 0 && minute <= 59) _minute = minute;
    });
  }

  DateTime get _plannedTime => DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        _hour,
        _minute,
      );

  bool get _isPast =>
      _timeError == null && !_plannedTime.isAfter(DateTime.now());

  Program? get _program {
    for (final Program program in widget.state.programs) {
      if (program.id == _programId) return program;
    }
    return null;
  }

  void _submit() {
    final Program? program = _program;
    if (program == null || _timeError != null) return;
    widget.state.scheduleWorkout(
      date: widget.date,
      hour: _hour,
      minute: _minute,
      program: program,
    );
    final String when =
        '${HomeScreen._monthTitle(DateTime(widget.date.year, widget.date.month)).split(' ').first} '
        '${widget.date.day}, ${HomeScreen._clock(_hour, _minute)}';
    widget.state.showToast(
      AfStrings.fill(AfStrings.scheduleSavedToast, <String, Object?>{
        'when': when,
      }),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final bool hasPrograms = widget.state.programs.isNotEmpty;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: t.borderLine,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(AfStrings.scheduleTitle,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              AfStrings.scheduleBody,
              style: AfText.muted(t).copyWith(height: 1.5),
            ),
            const SizedBox(height: 14),
            AfSubtle(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: <Widget>[
                  Icon(Icons.event_outlined, size: 16, color: t.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${HomeScreen._monthTitle(
                        DateTime(widget.date.year, widget.date.month),
                      )} · ${widget.date.day}',
                      style: AfText.strong(t, size: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(AfStrings.scheduleHour,
                          style: AfText.muted(t, size: 11)),
                      const SizedBox(height: 4),
                      AfTextField(
                        controller: _hourCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        onChanged: (_) => _onTimeChanged(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(AfStrings.scheduleMinute,
                          style: AfText.muted(t, size: 11)),
                      const SizedBox(height: 4),
                      AfTextField(
                        controller: _minuteCtrl,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(2),
                        ],
                        onChanged: (_) => _onTimeChanged(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_timeError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _timeError!,
                  style: TextStyle(
                    color: t.danger,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(AfStrings.scheduleProgram, style: AfText.muted(t, size: 11)),
            const SizedBox(height: 4),
            if (!hasPrograms)
              Text(AfStrings.scheduleNoPrograms, style: AfText.muted(t))
            else
              AfDropdown(
                value: _program?.name ?? '',
                items: widget.state.programs
                    .map((Program p) => p.name)
                    .toList(growable: false),
                onChanged: (String value) {
                  for (final Program program in widget.state.programs) {
                    if (program.name == value) {
                      setState(() => _programId = program.id);
                      return;
                    }
                  }
                },
              ),
            if (hasPrograms && _isPast)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'That time has already passed. Pick a later hour.',
                  style: TextStyle(
                    color: t.danger,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(
                  child: AfButton(
                    label: AfStrings.scheduleCancel,
                    variant: AfButtonVariant.secondary,
                    size: AfButtonSize.medium,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AfButton(
                    label: AfStrings.scheduleSave,
                    size: AfButtonSize.medium,
                    onPressed: hasPrograms && _timeError == null && !_isPast
                        ? _submit
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
