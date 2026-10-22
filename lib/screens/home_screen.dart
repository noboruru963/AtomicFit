import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderHomeScreen()` (`index.html` lines 1615-1726).
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
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AfButton(
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
                        onPressed: () {
                          if (active == null) return;
                          state.startProgramWorkout(active.id, 'full');
                          Navigator.of(context)
                              .pushNamed(AfScreen.activeWorkout);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    AfButton(
                      label: AfStrings.homeEmptyWorkout,
                      variant: AfButtonVariant.secondary,
                      size: AfButtonSize.medium,
                      onPressed: () {
                        state.startEmptyWorkout();
                        Navigator.of(context).pushNamed(AfScreen.activeWorkout);
                      },
                    ),
                  ],
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
    final List<WorkoutSession> matches =
        state.history.where((WorkoutSession s) => s.dayOfMonth == day).toList();
    if (matches.isEmpty) {
      state.showToast(
        AfStrings.fill(AfStrings.calendarRestDayToast, <String, Object?>{
          'month': _monthTitle(now).split(' ').first,
          'day': day,
        }),
        kind: ToastKind.info,
      );
      return;
    }

    final WorkoutSession session = matches.first;
    final AfTokens t = context.af;
    await AfDialog.show<void>(
      context,
      title: AfStrings.fill(AfStrings.calendarDayTitle, <String, Object?>{
        'month': _monthTitle(now).split(' ').first,
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
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.sessions,
    required this.onDayTap,
  });

  final DateTime month;
  final List<WorkoutSession> sessions;
  final void Function(int day) onDayTap;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // Monday-first offset.
    final int leading = DateTime(month.year, month.month, 1).weekday - 1;
    final int today = DateTime.now().day;
    final bool sameMonth = DateTime.now().year == month.year &&
        DateTime.now().month == month.month;

    final List<Widget> cells = <Widget>[];
    for (int i = 0; i < leading; i++) {
      cells.add(const SizedBox(height: 32));
    }
    for (int day = 1; day <= daysInMonth; day++) {
      final WorkoutSession? session =
          sessions.where((WorkoutSession s) => s.dayOfMonth == day).firstOrNull;
      final bool isToday = sameMonth && day == today;

      Color background = t.bgSubtle;
      Color foreground = t.textMuted;
      Border? border;

      if (session != null) {
        background = t.accent;
        foreground = Colors.white;
      } else if (isToday) {
        background = Colors.transparent;
        foreground = t.accent;
        border = Border.all(color: t.accent, width: 1.5);
      }

      cells.add(
        GestureDetector(
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
                    fontWeight: session != null || isToday
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
                  ),
              ],
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
