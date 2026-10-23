import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderHomeScreen()` (`index.html` lines 2012-2148), updated with:
/// - Removal of the Empty Workout button on Home and full-width alignment of
///   the primary program action button.
/// - Interactive calendar workout scheduling (create, view, edit, and remove
///   scheduled workouts separately from completed sessions).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<String> _timeOptions = <String>[
    '06:00',
    '06:30',
    '07:00',
    '07:30',
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
  ];

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final Program? active = state.getActiveProgram();
    final DateTime now = state.currentDate;
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                Text(
                  active == null || active.exercises.isEmpty
                      ? AfStrings.homeNoExercises
                      : active.exercises
                          .map((ProgramExercise e) => e.name)
                          .join(' · '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AfText.muted(t),
                ),
                const SizedBox(height: 12),
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
                  size: AfButtonSize.regular,
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
          const SizedBox(height: 16),

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
                                  text:
                                      '${AfStrings.fill(AfStrings.homeWorkoutsLogged, <String, Object?>{
                                        'count': state.history.length
                                      })} ',
                                  style: AfText.muted(t),
                                ),
                                TextSpan(
                                  text: state.history.length.toString(),
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
                  scheduledWorkouts: state.scheduledWorkouts,
                  onDayTap: (int day) => _inspectDay(context, state, day, now),
                ),
              ],
            ),
          ),
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

  static String _monthName(DateTime date) {
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
    return months[date.month - 1];
  }

  static String _monthTitle(DateTime date) =>
      '${_monthName(date)} ${date.year}';

  static Future<void> _inspectDay(
    BuildContext context,
    AppState state,
    int day,
    DateTime now,
  ) async {
    final List<WorkoutSession> matches =
        state.history.where((WorkoutSession s) => s.dayOfMonth == day).toList();
    final ScheduledWorkout? scheduled = state.scheduledWorkoutForDay(
      day,
      month: now.month,
      year: now.year,
    );

    if (scheduled != null) {
      await _showScheduledDetailsDialog(
        context,
        state,
        day: day,
        now: now,
        scheduled: scheduled,
        completedSession: matches.firstOrNull,
      );
      return;
    }

    if (matches.isEmpty) {
      await _showScheduleFormDialog(
        context,
        state,
        day: day,
        now: now,
      );
      return;
    }

    final WorkoutSession session = matches.first;
    final AfTokens t = context.af;
    await AfDialog.show<void>(
      context,
      title: AfStrings.fill(AfStrings.calendarDayTitle, <String, Object?>{
        'month': _monthName(now),
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
          label: AfStrings.calendarScheduleAnother,
          variant: AfButtonVariant.tint,
          size: AfButtonSize.compact,
          onPressed: () {
            Navigator.of(context).pop();
            _showScheduleFormDialog(
              context,
              state,
              day: day,
              now: now,
            );
          },
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

  static Future<void> _showScheduledDetailsDialog(
    BuildContext context,
    AppState state, {
    required int day,
    required DateTime now,
    required ScheduledWorkout scheduled,
    WorkoutSession? completedSession,
  }) async {
    final AfTokens t = context.af;
    final String monthName = _monthName(now);
    final Program? program = state.getProgramById(scheduled.programId);
    final String exercisesLine = program == null || program.exercises.isEmpty
        ? ''
        : program.exercises.map((ProgramExercise e) => e.name).join(' · ');

    await AfDialog.show<void>(
      context,
      title: AfStrings.fill(
        AfStrings.calendarDayTitle,
        <String, Object?>{
          'month': monthName,
          'day': day,
          'name': scheduled.programName,
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              const AfBadge(
                label: AfStrings.calendarScheduledBadge,
                tone: AfBadgeTone.blue,
                uppercase: true,
              ),
              const SizedBox(width: 8),
              Text(
                '$monthName $day, ${scheduled.year}',
                style: AfText.muted(t),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AfSubtle(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  AfStrings.fill(
                    AfStrings.calendarPlannedProgramLine,
                    <String, Object?>{'program': scheduled.programName},
                  ),
                  style: AfText.strong(t, size: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  AfStrings.fill(
                    AfStrings.calendarPlannedTimeLine,
                    <String, Object?>{'time': scheduled.plannedTime},
                  ),
                  style: AfText.muted(t, size: 12, weight: FontWeight.w600),
                ),
                if (exercisesLine.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    exercisesLine,
                    style: AfText.muted(t, size: 11),
                  ),
                ],
              ],
            ),
          ),
          if (completedSession != null) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              '${AfStrings.fill(AfStrings.calendarTotalReps, <String, Object?>{
                    'reps': completedSession.reps
                  })} · ${AfStrings.fill(AfStrings.calendarTotalVolume, <String, Object?>{
                    'volume': completedSession.volume
                  })}',
              style: AfText.muted(t),
            ),
          ],
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
          label: AfStrings.calendarRemoveSchedule,
          variant: AfButtonVariant.danger,
          size: AfButtonSize.compact,
          onPressed: () {
            state.removeScheduledWorkout(scheduled.id);
            Navigator.of(context).pop();
            state.showToast(
              AfStrings.fill(
                AfStrings.calendarScheduleRemovedToast,
                <String, Object?>{
                  'month': monthName,
                  'day': day,
                },
              ),
              kind: ToastKind.info,
            );
          },
        ),
        AfButton(
          label: AfStrings.calendarEditSchedule,
          size: AfButtonSize.compact,
          onPressed: () {
            Navigator.of(context).pop();
            _showScheduleFormDialog(
              context,
              state,
              day: day,
              now: now,
              existing: scheduled,
            );
          },
        ),
      ],
    );
  }

  static Future<void> _showScheduleFormDialog(
    BuildContext context,
    AppState state, {
    required int day,
    required DateTime now,
    ScheduledWorkout? existing,
  }) async {
    final List<Program> programs = state.programs;
    final Program? defaultProgram = existing != null
        ? (state.getProgramById(existing.programId) ?? state.getActiveProgram())
        : state.getActiveProgram();
    String selectedProgramName = defaultProgram?.name ??
        (programs.isNotEmpty ? programs.first.name : 'Push Day');
    String selectedTime = existing?.plannedTime ?? '09:00';
    final List<String> timeItems = <String>[
      if (!_timeOptions.contains(selectedTime)) selectedTime,
      ..._timeOptions,
    ];
    final String monthName = _monthName(now);
    final String formattedDate = '$monthName $day, ${now.year}';

    await showDialog<void>(
      context: context,
      barrierColor: const Color(0x99020613),
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final AfTokens t = context.af;
            final List<String> programNames =
                programs.map((Program p) => p.name).toList(growable: false);
            if (programNames.isNotEmpty &&
                !programNames.contains(selectedProgramName)) {
              selectedProgramName = programNames.first;
            }
            Program? chosenProgram;
            for (final Program p in programs) {
              if (p.name == selectedProgramName) {
                chosenProgram = p;
                break;
              }
            }

            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Container(
                  decoration: BoxDecoration(
                    color: t.bgCard,
                    borderRadius: BorderRadius.circular(t.radiusCard),
                    border: Border.all(color: t.borderLine),
                    boxShadow: t.shadowCard,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                existing == null
                                    ? AfStrings.calendarScheduleTitle
                                    : AfStrings.calendarEditScheduleTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(dialogContext).pop(),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(
                                  '✕',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AfStrings.calendarWorkoutDateLabel,
                          style: AfText.muted(t, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        AfSubtle(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: t.accent,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formattedDate,
                                key: const ValueKey<String>(
                                  'schedule-selected-date',
                                ),
                                style: AfText.strong(t, size: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AfStrings.calendarWorkoutTimeLabel,
                          style: AfText.muted(t, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        AfDropdown(
                          key: const ValueKey<String>('schedule-time-dropdown'),
                          value: selectedTime,
                          items: timeItems,
                          onChanged: (String value) {
                            setModalState(() {
                              selectedTime = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AfStrings.calendarWorkoutProgramLabel,
                          style: AfText.muted(t, weight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        if (programNames.isNotEmpty)
                          AfDropdown(
                            key: const ValueKey<String>(
                              'schedule-program-dropdown',
                            ),
                            value: selectedProgramName,
                            items: programNames,
                            onChanged: (String value) {
                              setModalState(() {
                                selectedProgramName = value;
                              });
                            },
                          ),
                        if (chosenProgram != null &&
                            chosenProgram.exercises.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 6),
                          Text(
                            chosenProgram.exercises
                                .map((ProgramExercise e) => e.name)
                                .join(' · '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AfText.muted(t, size: 11),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            AfButton(
                              label: AfStrings.cancel,
                              variant: AfButtonVariant.secondary,
                              size: AfButtonSize.compact,
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(),
                            ),
                            const SizedBox(width: 8),
                            AfButton(
                              key: const ValueKey<String>(
                                'schedule-save-button',
                              ),
                              label: AfStrings.calendarSaveSchedule,
                              size: AfButtonSize.compact,
                              onPressed: () {
                                final Program? target = chosenProgram ??
                                    state.getActiveProgram() ??
                                    programs.firstOrNull;
                                if (target == null) {
                                  Navigator.of(dialogContext).pop();
                                  return;
                                }
                                state.scheduleWorkout(
                                  dayOfMonth: day,
                                  month: now.month,
                                  year: now.year,
                                  plannedTime: selectedTime,
                                  programId: target.id,
                                  existingId: existing?.id,
                                );
                                Navigator.of(dialogContext).pop();
                                state.showToast(
                                  AfStrings.fill(
                                    existing == null
                                        ? AfStrings.calendarScheduledToast
                                        : AfStrings
                                            .calendarScheduleUpdatedToast,
                                    <String, Object?>{
                                      'program': target.name,
                                      'month': monthName,
                                      'day': day,
                                      'time': selectedTime,
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.sessions,
    required this.scheduledWorkouts,
    required this.onDayTap,
  });

  final DateTime month;
  final List<WorkoutSession> sessions;
  final List<ScheduledWorkout> scheduledWorkouts;
  final void Function(int day) onDayTap;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Monday-first offset.
    final int leading = DateTime(month.year, month.month, 1).weekday - 1;
    final int today = month.day;

    final List<Widget> cells = <Widget>[];
    for (int i = 0; i < leading; i++) {
      cells.add(const SizedBox(height: 32));
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final WorkoutSession? session =
          sessions.where((WorkoutSession s) => s.dayOfMonth == day).firstOrNull;
      final ScheduledWorkout? scheduled = scheduledWorkouts
          .where(
            (ScheduledWorkout s) =>
                s.deletedAtUtc == null &&
                s.dayOfMonth == day &&
                s.month == month.month &&
                s.year == month.year,
          )
          .firstOrNull;
      final bool isToday = day == today;

      Color background = t.bgSubtle;
      Color foreground = t.textMuted;
      Border? border;

      if (session != null) {
        background = t.accent;
        foreground = Colors.white;
      } else if (scheduled != null) {
        background = t.accentTint;
        foreground = t.accentTintText;
        border = Border.all(color: t.accent, width: 1.5);
      } else if (isToday) {
        background = Colors.transparent;
        foreground = t.accent;
        border = Border.all(color: t.accent, width: 1.5);
      }

      cells.add(
        Semantics(
          button: true,
          label: scheduled != null
              ? 'Day $day, Scheduled: ${scheduled.programName} at ${scheduled.plannedTime}'
              : 'Day $day',
          child: GestureDetector(
            key: ValueKey<String>('calendar-day-$day'),
            onTap: () => onDayTap(day),
            child: Container(
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
                      fontWeight:
                          session != null || scheduled != null || isToday
                              ? FontWeight.w700
                              : FontWeight.w400,
                      height: 1.1,
                    ),
                  ),
                  if (session != null || scheduled != null)
                    Container(
                      key: scheduled != null
                          ? ValueKey<String>(
                              'calendar-scheduled-indicator-$day',
                            )
                          : null,
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: session != null ? Colors.white : t.accent,
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
