import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderHistoryScreen()` (`index.html` lines 3486-3569).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    const List<String> filters = <String>['All', 'Full', 'Micro', 'Stitched'];

    final String query = state.historySearch.trim().toLowerCase();
    final List<WorkoutSession> sessions =
        state.history.where((WorkoutSession s) {
      final bool filterMatch = state.historyFilter == 'All' ||
          s.type.toLowerCase() == state.historyFilter.toLowerCase();
      final bool searchMatch =
          query.isEmpty || s.name.toLowerCase().contains(query);
      return filterMatch && searchMatch;
    }).toList();

    final List<WorkoutSession> micros =
        state.history.where((WorkoutSession s) => s.type == 'micro').toList();

    return AfScaffold(
      screenId: AfScreen.history,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AfTextField(
            controller: _search,
            style: AfText.muted(t, size: 12),
            hint: AfStrings.historySearchPlaceholder,
            onChanged: state.setHistorySearch,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: <Widget>[
              for (final String filter in filters)
                AfButton(
                  label: filter,
                  variant:
                      state.historyFilter.toLowerCase() == filter.toLowerCase()
                          ? AfButtonVariant.primary
                          : AfButtonVariant.secondary,
                  size: AfButtonSize.compact,
                  onPressed: () => state.setHistoryFilter(filter),
                ),
            ],
          ),
          if (micros.length >= 2) ...<Widget>[
            const SizedBox(height: 12),
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
                          AfStrings.fill(
                            AfStrings.historyStitchBanner,
                            <String, Object?>{'count': micros.length},
                          ),
                          style: AfText.strong(t, size: 12),
                        ),
                        Text(
                          AfStrings.historyStitchBannerBody,
                          style: AfText.muted(t, size: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AfButton(
                    label: AfStrings.historyStitchButton,
                    variant: AfButtonVariant.tint,
                    size: AfButtonSize.compact,
                    onPressed: state.stitchMicroSessions,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (sessions.isEmpty)
            AfCard(
              padding: const EdgeInsets.all(24),
              child: Text(
                AfStrings.historyEmpty,
                textAlign: TextAlign.center,
                style: AfText.muted(t),
              ),
            )
          else
            for (final WorkoutSession session in sessions) ...<Widget>[
              _SessionCard(session: session),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session});

  final WorkoutSession session;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);

    final AfBadgeTone tone = session.isStitched
        ? AfBadgeTone.amber
        : (session.isMicro ? AfBadgeTone.green : AfBadgeTone.blue);
    final String label =
        session.isStitched ? 'Stitched' : (session.isMicro ? 'Micro' : 'Full');

    return AfCard(
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
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: <Widget>[
                        Text(
                          session.name,
                          style: AfText.strong(t, size: 14),
                        ),
                        AfBadge(label: label, tone: tone, fontSize: 10),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(session.dateLabel, style: AfText.muted(t)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    '${session.volume} kg',
                    style: TextStyle(
                      color: t.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${session.reps} reps',
                    style: AfText.muted(t, size: 11),
                  ),
                ],
              ),
            ],
          ),
          if (session.isStitched && session.children.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            AfSubtle(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AfStrings.fill(
                      AfStrings.historyStitchedFrom,
                      <String, Object?>{'count': session.children.length},
                    ),
                    style: AfText.muted(t, size: 11, weight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  for (final WorkoutSession child in session.children)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: <Widget>[
                          Text(
                            '• ${child.name}',
                            style: AfText.muted(t, size: 11),
                          ),
                          const Spacer(),
                          Text(
                            '${child.volume} kg (${child.reps} reps)',
                            style: AfText.muted(t, size: 11),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: t.borderLine)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                if (session.isStitched) ...<Widget>[
                  AfButton(
                    label: AfStrings.historyUnstitch,
                    variant: AfButtonVariant.tint,
                    size: AfButtonSize.compact,
                    onPressed: () => state.unstitchSession(session.id),
                  ),
                  const SizedBox(width: 8),
                ],
                AfButton(
                  label: AfStrings.historyDetail,
                  variant: AfButtonVariant.secondary,
                  size: AfButtonSize.compact,
                  onPressed: () => _openDetail(context, session),
                ),
                const SizedBox(width: 8),
                AfButton(
                  label: AfStrings.historyDelete,
                  variant: AfButtonVariant.danger,
                  size: AfButtonSize.compact,
                  onPressed: () => _confirmDelete(context, state, session),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _openDetail(
    BuildContext context,
    WorkoutSession session,
  ) async {
    final AfTokens t = context.af;
    await AfDialog.show<void>(
      context,
      title: session.name,
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              AfBadge(
                label: session.type,
                uppercase: true,
                tone: session.isStitched
                    ? AfBadgeTone.amber
                    : (session.isMicro ? AfBadgeTone.green : AfBadgeTone.blue),
              ),
              const SizedBox(width: 8),
              Text(session.dateLabel, style: AfText.muted(t)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            AfStrings.fill(AfStrings.historyTotalVolume, <String, Object?>{
              'volume': session.volume,
            }),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            AfStrings.fill(AfStrings.historyTotalReps, <String, Object?>{
              'reps': session.reps,
            }),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          if (session.setsDetail.isEmpty)
            Text(
              AfStrings.fill(AfStrings.historyNoSetDetail, <String, Object?>{
                'reps': session.reps,
                'count': session.setsCount,
              }),
              style: AfText.muted(t),
            )
          else
            for (int i = 0; i < session.setsDetail.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  AfStrings.fill(AfStrings.historySetRow, <String, Object?>{
                    'index': i + 1,
                    'exercise': session.setsDetail[i].exerciseName,
                    'kg': _trim(session.setsDetail[i].weightKg),
                    'reps': session.setsDetail[i].reps,
                    'method': session.setsDetail[i].inputMethod,
                  }),
                  style: AfText.muted(t, size: 12),
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
      ],
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context,
    AppState state,
    WorkoutSession session,
  ) async {
    await AfDialog.show<void>(
      context,
      title: AfStrings.historyDeleteTitle,
      body: Text(
        AfStrings.historyDeleteBody,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: <Widget>[
        AfButton(
          label: AfStrings.cancel,
          variant: AfButtonVariant.secondary,
          size: AfButtonSize.compact,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AfButton(
          label: AfStrings.historyDelete,
          variant: AfButtonVariant.danger,
          size: AfButtonSize.compact,
          onPressed: () {
            Navigator.of(context).pop();
            state.deleteSession(session.id);
          },
        ),
      ],
    );
  }
}

String _trim(double value) {
  final String text = value.toStringAsFixed(1);
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}
