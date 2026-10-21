import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderQuizExplainerScreen()` (`index.html` lines 1897-1931).
class QuizExplainerScreen extends StatelessWidget {
  const QuizExplainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final QuizAdjustment adjustment = state.computedQuizAdjustment();

    return AfScaffold(
      screenId: AfScreen.quizExplainer,
      child: AfCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: t.accentTint,
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: const Text('📊', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(height: 12),
            Text(
              AfStrings.quizWhyTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              AfStrings.quizWhyBody,
              style: AfText.muted(t).copyWith(height: 1.625),
            ),
            const SizedBox(height: 16),
            _AdjustmentRow(
              label: AfStrings.quizSessionLength,
              value: adjustment.sessionLength,
              accent: true,
            ),
            const SizedBox(height: 10),
            _AdjustmentRow(
              label: AfStrings.quizIntensity,
              value: adjustment.intensityLabel,
              accent: true,
            ),
            const SizedBox(height: 10),
            _AdjustmentRow(
              label: AfStrings.quizFrequency,
              value: adjustment.frequency,
              accent: false,
            ),
            const SizedBox(height: 10),
            AfSubtle(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      AfStrings.quizWeightAdjustment,
                      style: AfText.muted(t, size: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AfBadge(
                    label: '${adjustment.pctText} across exercises',
                    tone: AfBadgeTone.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AfButton(
              label: AfStrings.quizSeeAdjustedPlan,
              expand: true,
              fontSize: 14,
              onPressed: () => Navigator.of(context)
                  .pushReplacementNamed(AfScreen.quizAdjusted),
            ),
            const SizedBox(height: 10),
            AfButton(
              label: AfStrings.quizBackToQuiz,
              variant: AfButtonVariant.secondary,
              expand: true,
              size: AfButtonSize.compact,
              onPressed: () => Navigator.of(context)
                  .pushReplacementNamed(AfScreen.quizQuestion),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustmentRow extends StatelessWidget {
  const _AdjustmentRow({
    required this.label,
    required this.value,
    required this.accent,
  });

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    return AfSubtle(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            child: Text(label, style: AfText.muted(t, size: 12)),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: accent ? t.accent : t.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
