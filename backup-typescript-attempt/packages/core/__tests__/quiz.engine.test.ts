// @atomfit/core/__tests__/quiz.engine.test.ts
// Quiz rule engine — deterministic (Rule I-12), non-diagnostic (Rule I-10),
// ease-in clamped 10–20% (BA-004). Covers FR-074..089 / AC-074..089.
import { describe, it, expect } from 'vitest';
import { QuizEngineImpl } from '../src/quiz.engine';
import { QUIZ_RULE_TABLE, type RuleRow } from '../src/config';
import type { QuizAttempt, QuizAnswer, Id } from '../src/types';

// Helper for tests: plain string -> branded Id
function tid(s: string): Id {
  return s as unknown as Id;
}

function attempt(): QuizAttempt {
  return { id: tid('a1'), userId: tid('u1'), startedAtUtc: 1000, status: 'complete' };
}

function answer(q: string, k: string): QuizAnswer {
  return { id: tid('x'), quizAttemptId: tid('a1'), questionKey: q, answerKey: k };
}

describe('QuizEngine', () => {
  it('applies no adjustment when no answers match a rule', () => {
    const engine = new QuizEngineImpl();
    const out = engine.evaluate(attempt(), [answer('q10_push', 'push')], 100);
    expect(out.weightReductionPct).toBeUndefined();
    expect(out.intensity).toBe('Progress the weight');
  });

  it('applies reduced intensity within the 10–20% ease-in range (BA-004)', () => {
    const engine = new QuizEngineImpl();
    const out = engine.evaluate(attempt(), [answer('q10_push', 'reduced')], 100);
    expect(out.weightReductionPct).toBeDefined();
    expect(out.weightReductionPct).toBeGreaterThanOrEqual(10);
    expect(out.weightReductionPct).toBeLessThanOrEqual(20);
    expect(out.intensity).toBe('Reduce the weight');
  });

  it('clamps out-of-range rule-table percentages into 10–20%', () => {
    const badRow: RuleRow = {
      questionKey: 'q10_push',
      answerKey: 'reduced',
      sessionLength: 'Shorter',
      intensity: 'Reduce the weight',
      frequency: 'Same',
      weightReductionPct: 50, // out of range
      reason: 'test clamp',
    };
    const engine = new QuizEngineImpl([badRow]);
    const out = engine.evaluate(attempt(), [answer('q10_push', 'reduced')], 100);
    expect(out.weightReductionPct).toBe(20); // clamped to max
  });

  it('applies documented precedence: later applied rows win per field', () => {
    const rows: RuleRow[] = [
      {
        questionKey: 'q2_energy',
        answerKey: 'Low',
        sessionLength: 'Short',
        intensity: 'Maintain',
        frequency: 'Same',
        reason: 'low energy',
      },
      {
        questionKey: 'q2_energy',
        answerKey: 'Low',
        sessionLength: 'Shorter',
        intensity: 'Reduce the weight',
        frequency: 'Reduced',
        weightReductionPct: 12,
        reason: 'low energy override',
      },
    ];
    const engine = new QuizEngineImpl(rows);
    const out = engine.evaluate(attempt(), [answer('q2_energy', 'Low')], 100);
    expect(out.sessionLength).toBe('Shorter');
    expect(out.intensity).toBe('Reduce the weight');
    expect(out.frequency).toBe('Reduced');
    expect(out.weightReductionPct).toBe(12);
  });

  it('exposes the non-diagnostic statement (Rule I-10)', () => {
    const engine = new QuizEngineImpl();
    expect(engine.nonDiagnosticStatement()).toContain('Non-diagnostic quiz');
  });
});
