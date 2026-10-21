import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../models/app_models.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderQuizQuestionScreen()` (`index.html` lines 1799-1850).
class QuizQuestionScreen extends StatelessWidget {
  const QuizQuestionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final List<QuizQuestion> questions = state.activeQuizQuestions;
    final int index = state.quizStepIndex.clamp(0, questions.length - 1);
    final QuizQuestion question = questions[index];
    final String selected =
        state.quizAnswers[question.id] ?? question.options.first;
    final bool isLast = index == questions.length - 1;

    void goToStep(int step) {
      if (step < 0) {
        Navigator.of(context).pop();
        return;
      }
      if (step >= questions.length) {
        Navigator.of(context).pushReplacementNamed(AfScreen.quizExplainer);
        return;
      }
      state.setQuizStep(step);
    }

    return AfScaffold(
      screenId: AfScreen.quizQuestion,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                AfStrings.fill(AfStrings.quizQuestionIndex, <String, Object?>{
                  'index': index + 1,
                  'total': questions.length,
                }),
                style: AfText.sectionHead(t).copyWith(fontSize: 12),
              ),
              const Spacer(),
              GestureDetector(
                onTap: state.toggleQuizLengthMode,
                child: AfBadge(
                  label: state.quizShortMode
                      ? AfStrings.quizModeFast
                      : AfStrings.quizModeFull,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AfProgress(value: (index + 1) / questions.length, height: 8),
          const SizedBox(height: 10),
          Text(
            AfStrings.quizNonDiagnostic,
            style: AfText.muted(t, size: 11),
          ),
          const SizedBox(height: 12),
          AfCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  question.text,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        height: 1.375,
                      ),
                ),
                const SizedBox(height: 16),
                for (final String option in question.options) ...<Widget>[
                  _OptionTile(
                    label: option,
                    selected: option == selected,
                    onTap: () => state.selectQuizOption(question.id, option),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: AfButton(
                  label: AfStrings.quizBack,
                  variant: AfButtonVariant.secondary,
                  size: AfButtonSize.compact,
                  expand: true,
                  onPressed: () => goToStep(index - 1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AfButton(
                  label: isLast
                      ? AfStrings.quizSeeWhatChanged
                      : AfStrings.quizNext,
                  size: AfButtonSize.compact,
                  expand: true,
                  onPressed: () => goToStep(index + 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? t.accentTint : t.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? t.accent : t.borderLine,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? t.accentTintText : t.textPrimary,
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    height: 1.5,
                  ),
                ),
              ),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected ? t.accent : Colors.transparent,
                  border: selected
                      ? null
                      : Border.all(color: t.borderLine, width: 1.5),
                ),
                alignment: Alignment.center,
                child: selected
                    ? const Text(
                        '✓',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
