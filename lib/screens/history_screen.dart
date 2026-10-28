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

  /// Whether stitch selection is open.
  bool _selecting = false;

  /// The ids picked for stitching, at most two.
  final List<String> _picked = <String>[];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  WorkoutSession? _session(AppState state, String id) {
    for (final WorkoutSession session in state.history) {
      if (session.id == id) return session;
    }
    return null;
  }

  void _exitSelection() {
    setState(() {
      _selecting = false;
      _picked.clear();
    });
  }

  /// Adds or removes a card from the selection, refusing a second session that
  /// cannot legally join the first and saying why.
  void _togglePick(AppState state, WorkoutSession session) {
    if (_picked.contains(session.id)) {
      setState(() => _picked.remove(session.id));
      return;
    }
    if (_picked.length == 2) {
      state.showToast(AfStrings.historyStitchTwoOnly, kind: ToastKind.info);
      return;
    }
    if (_picked.isNotEmpty) {
      final WorkoutSession? first = _session(state, _picked.first);
      if (first != null) {
        final String? reason = state.stitchBlockedReason(first, session);
        if (reason != null) {
          state.showToast(reason, kind: ToastKind.danger);
          return;
        }
      }
    }
    setState(() => _picked.add(session.id));
  }

  /// Shows what the merge will contain, then creates the stitched session.
  Future<void> _previewStitch(AppState state) async {
    if (_picked.length != 2) return;
    final WorkoutSession? first = _session(state, _picked[0]);
    final WorkoutSession? second = _session(state, _picked[1]);
    if (first == null || second == null) return;
    final String? reason = state.stitchBlockedReason(first, second);
    if (reason != null) {
      state.showToast(reason, kind: ToastKind.danger);
      return;
    }

    final AfTokens t = context.af;
    final bool? confirm = await AfDialog.show<bool>(
      context,
      title: AfStrings.historyStitchPreviewTitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            AfStrings.historyStitchPreviewBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          for (final WorkoutSession session in <WorkoutSession>[first, second])
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: AfSubtle(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(session.name, style: AfText.strong(t, size: 12)),
                    const SizedBox(height: 2),
                    Text(
                      AfStrings.fill(
                        AfStrings.historyStitchBreakdown,
                        <String, Object?>{
                          'sets': session.setsCount,
                          'reps': session.reps,
                          'volume': _trim(session.volume),
                          'duration': session.durationMin,
                        },
                      ),
                      style: AfText.muted(t, size: 11),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            AfStrings.fill(
              AfStrings.historyStitchBreakdown,
              <String, Object?>{
                'sets': first.setsCount + second.setsCount,
                'reps': first.reps + second.reps,
                'volume': _trim(first.volume + second.volume),
                'duration': first.durationMin + second.durationMin,
              },
            ),
            style: AfText.strong(t, size: 13),
          ),
        ],
      ),
      actions: <Widget>[
        AfButton(
          label: AfStrings.cancel,
          variant: AfButtonVariant.secondary,
          size: AfButtonSize.compact,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        AfButton(
          label: AfStrings.historyStitchConfirm,
          size: AfButtonSize.compact,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    );
    if (confirm != true) return;
    if (state.stitchSessions(_picked) != null) {
      _exitSelection();
    }
  }

  /// The two-step stitch toolbar shown while selecting.
  Widget _selectionBar(AfTokens t, AppState state) {
    return AfSubtle(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(AfStrings.historyStitchHint, style: AfText.muted(t, size: 11)),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  AfStrings.fill(
                    AfStrings.historyStitchSelected,
                    <String, Object?>{'count': _picked.length},
                  ),
                  style: AfText.strong(t, size: 12),
                ),
              ),
              AfButton(
                label: AfStrings.fill(
                  AfStrings.historyStitchAction,
                  <String, Object?>{'count': _picked.length},
                ),
                size: AfButtonSize.compact,
                onPressed:
                    _picked.length == 2 ? () => _previewStitch(state) : null,
              ),
              const SizedBox(width: 6),
              AfButton(
                label: AfStrings.historyStitchCancel,
                variant: AfButtonVariant.secondary,
                size: AfButtonSize.compact,
                onPressed: _exitSelection,
              ),
            ],
          ),
        ],
      ),
    );
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

    // Any session that is not already a parent can enter a stitch.
    final int stitchable =
        state.history.where((WorkoutSession s) => !s.isStitched).length;

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
          if (stitchable >= 2) ...<Widget>[
            const SizedBox(height: 10),
            if (_selecting)
              _selectionBar(t, state)
            else
              Align(
                alignment: Alignment.centerLeft,
                child: AfButton(
                  label: AfStrings.historyStitchEnter,
                  variant: AfButtonVariant.tint,
                  size: AfButtonSize.compact,
                  onPressed: () => setState(() => _selecting = true),
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
              _SessionCard(
                session: session,
                selectionMode: _selecting,
                selected: _picked.contains(session.id),
                onSelect: () => _togglePick(state, session),
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.selectionMode,
    required this.selected,
    required this.onSelect,
  });

  final WorkoutSession session;
  final bool selectionMode;
  final bool selected;
  final VoidCallback onSelect;

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
      onTap: selectionMode ? onSelect : null,
      borderLeftColor: selected ? t.accent : null,
      borderLeftWidth: selected ? 4 : 0,
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
                        if (selected)
                          const AfBadge(
                            label: '✓ Selected',
                            tone: AfBadgeTone.amber,
                            fontSize: 10,
                          ),
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
          if (selectionMode)
            Container(
              padding: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: t.borderLine)),
              ),
              child: Text(
                selected
                    ? AfStrings.historyStitchPicked
                    : AfStrings.historyStitchTapToPick,
                style: AfText.muted(t, size: 11),
              ),
            )
          else
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
                      onPressed: () =>
                          _confirmUnstitch(context, state, session),
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

  static Future<void> _confirmUnstitch(
    BuildContext context,
    AppState state,
    WorkoutSession session,
  ) async {
    await AfDialog.show<void>(
      context,
      title: AfStrings.historyUnstitchTitle,
      body: Text(
        AfStrings.historyUnstitchBody,
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
          label: AfStrings.historyUnstitchConfirm,
          size: AfButtonSize.compact,
          onPressed: () {
            Navigator.of(context).pop();
            state.unstitchSession(session.id);
          },
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
