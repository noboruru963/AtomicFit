import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderQuizPromptScreen()` (`index.html` lines 1758-1781).
class QuizPromptScreen extends StatelessWidget {
  const QuizPromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);

    void start({required bool short}) {
      state.quizShortMode = short;
      state.setQuizStep(0);
      Navigator.of(context).pushNamed(AfScreen.quizQuestion);
    }

    return AfScaffold(
      screenId: AfScreen.quizPrompt,
      child: AfCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: t.accentTint,
                  borderRadius: BorderRadius.circular(16),
                ),
                alignment: Alignment.center,
                child: const Text('⚡', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: constraints.maxWidth),
                    child: const AfBadge(label: AfStrings.quizNonDiagnostic),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                AfStrings.quizPromptTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AfStrings.quizPromptBody,
              textAlign: TextAlign.center,
              style: AfText.muted(t).copyWith(height: 1.625),
            ),
            const SizedBox(height: 16),
            AfSubtle(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    AfStrings.quizTuningHeader,
                    style: AfText.strong(t, size: 12),
                  ),
                  const SizedBox(height: 8),
                  const _TuningRow(
                    label: AfStrings.quizTuningVolume,
                    value: AfStrings.quizTuningVolumeValue,
                  ),
                  const _TuningRow(
                    label: AfStrings.quizTuningDuration,
                    value: AfStrings.quizTuningDurationValue,
                  ),
                  const _TuningRow(
                    label: AfStrings.quizTuningRest,
                    value: AfStrings.quizTuningRestValue,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            AfButton(
              label: AfStrings.quizStartFull,
              expand: true,
              fontSize: 14,
              onPressed: () => start(short: false),
            ),
            const SizedBox(height: 10),
            AfButton(
              label: AfStrings.quizStartQuick,
              variant: AfButtonVariant.tint,
              expand: true,
              size: AfButtonSize.compact,
              onPressed: () => start(short: true),
            ),
            const SizedBox(height: 10),
            AfButton(
              label: AfStrings.quizNotNow,
              variant: AfButtonVariant.secondary,
              expand: true,
              size: AfButtonSize.compact,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TuningRow extends StatelessWidget {
  const _TuningRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Text(
              '• $label',
              style: AfText.muted(t, size: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: AfText.strong(t, size: 12, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
