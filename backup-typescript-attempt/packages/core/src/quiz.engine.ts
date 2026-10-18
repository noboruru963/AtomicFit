// @atomfit/core/src/quiz.engine.ts
// Non-diagnostic quiz rule engine (Rule I-10, I-12, FR-074..089).
// Deterministic rule table + precedence + safety limits; outputs an Adjustment
// { sessionLength, intensity, frequency } shown as a preview before Accept (Rule I-13).
// Rule I-13: nothing changes the Current program silently; applied only on Accept
// as a new program version; previous version retained and revertable.

import type { Id, QuizAttempt, QuizAnswer } from './types';
import {
  QUIZ_RULE_TABLE,
  QUIZ_NON_DIAGNOSTIC_STATEMENT,
  EASE_IN_MIN_PCT,
  EASE_IN_MAX_PCT,
  type RuleRow,
} from './config';

export interface AdjustmentPreview {
  sessionLength: string;
  intensity: string;
  frequency: string;
  weightReductionPct: number | undefined; // within 10–20% when set (BA-004)
  reason: string;
  ruleRowsApplied: RuleRow[];
}

export interface QuizEngine {
  evaluate(
    attempt: QuizAttempt,
    answers: QuizAnswer[],
    lastLoadKg: number | undefined,
  ): AdjustmentPreview;
}

export class QuizEngineImpl implements QuizEngine {
  constructor(private readonly ruleTable: RuleRow[] = QUIZ_RULE_TABLE) {}

  evaluate(
    attempt: QuizAttempt,
    answers: QuizAnswer[],
    lastLoadKg: number | undefined,
  ): AdjustmentPreview {
    const applied: RuleRow[] = [];

    // Deterministic precedence: later rows in the table override earlier ones
    // for the same output field (documented precedence, Rule I-12).
    for (const answer of answers) {
      const match = this.ruleTable.find(
        (row) => row.questionKey === answer.questionKey && row.answerKey === answer.answerKey,
      );
      if (match) {
        // Avoid duplicate application of the same question (first match wins per question).
        if (!applied.some((r) => r.questionKey === match.questionKey)) {
          applied.push(match);
        }
      }
    }

    // Merge outputs in table order (later applied rows win for each field).
    let sessionLength = 'Same as last';
    let intensity = 'Maintain the weight';
    let frequency = 'Same as last';
    let reason = 'No program adjustment indicated by your answers.';
    let weightReductionPct: number | undefined;

    for (const row of applied) {
      sessionLength = row.sessionLength;
      intensity = row.intensity;
      frequency = row.frequency;
      reason = row.reason;
      if (row.weightReductionPct !== undefined) {
        weightReductionPct = this.clampEaseIn(row.weightReductionPct);
      }
    }

    return {
      sessionLength,
      intensity,
      frequency,
      weightReductionPct,
      reason,
      ruleRowsApplied: applied,
    };
  }

  // Clamp any reduction into the documented 10–20% safety limit (BA-004).
  private clampEaseIn(pct: number): number {
    return Math.min(EASE_IN_MAX_PCT, Math.max(EASE_IN_MIN_PCT, pct));
  }

  /** Non-diagnostic statement shown on every quiz screen (Rule I-10). */
  nonDiagnosticStatement(): string {
    return QUIZ_NON_DIAGNOSTIC_STATEMENT;
  }
}
