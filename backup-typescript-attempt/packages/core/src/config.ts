// @atomfit/core/src/config.ts
// Replaceable, documented configuration for quiz behaviour.
// Rule I-29 / I-12: quiz adjustment is a deterministic, documented rule table;
// nothing here is random, ML-based, or network-driven.
// Flags marked TBD-nn need a human decision (Rule I-29).

export const INACTIVITY_THRESHOLD_DAYS = 7; // BA-004, C-1 (was 14 in Improved pages copy — use 7)
export const QUIZ_QUESTION_COUNT = 10; // BA-004

// Ease-in: when a weight reduction applies, target weights reduced 10–20% (BA-004, C-4).
// Clamp any computed reduction into this range. Mapping of answers -> % is TBD-11.
export const EASE_IN_MIN_PCT = 10;
export const EASE_IN_MAX_PCT = 20;

// Q1 fixed options (BA-004).
export const Q1_FITNESS_TARGET_OPTIONS = [
  { key: 'muscle_gain', label: 'Muscle gain' },
  { key: 'staying_healthy', label: 'Staying healthy' },
  { key: 'look_fit', label: 'Look fit' },
  { key: 'no_target', label: 'No target' },
] as const;

// Q10 fixed options (BA-004). Button reads "See what changed".
export const Q10_PUSH_OPTIONS = [
  { key: 'push', label: 'Yes, progress the weight' },
  { key: 'same', label: 'No, same program as last' },
  { key: 'reduced', label: 'No, reduced intensity' },
] as const;

// Q2–Q9 wording is TBD-10. Placeholders covering target / energy / motivation.
// Never present invented wording as final (AGENTS.md 8.4).
export const PLACEHOLDER_QUESTIONS = [
  { key: 'q2_energy', label: 'How is your energy today?', options: ['High', 'Normal', 'Low'] },
  { key: 'q3_motivation', label: 'How motivated do you feel to train?', options: ['High', 'Normal', 'Low'] },
  { key: 'q4_days_per_week', label: 'How many days per week can you train?', options: ['1–2', '3–4', '5+'] },
  { key: 'q5_session_length', label: 'How long are your usual sessions?', options: ['<30 min', '30–60 min', '>60 min'] },
  { key: 'q6_recent_interruptions', label: 'Have real-life interruptions cut sessions short lately?', options: ['Yes', 'No', 'Prefer not to say'] },
  { key: 'q7_confidence', label: 'How confident do you feel with your current program?', options: ['High', 'Normal', 'Low'] },
  { key: 'q8_goal_focus', label: 'What matters most right now?', options: ['Strength', 'Consistency', 'Mobility', 'General health'] },
  { key: 'q9_readiness', label: 'How ready are you to resume your usual load?', options: ['Ready', 'Ease in', 'Not sure'] },
] as const;

// Deterministic rule table (Rule I-12). Each row maps an answer key -> adjustment.
// Precedence & safety limits TBD-11. This is the smallest replaceable table.
export interface RuleRow {
  questionKey: string;
  answerKey: string;
  sessionLength: string;
  intensity: string;
  frequency: string;
  weightReductionPct?: number; // undefined = no reduction; must be within EASE_IN range when set
  reason: string;
}

export const QUIZ_RULE_TABLE: RuleRow[] = [
  {
    questionKey: 'q10_push',
    answerKey: 'push',
    sessionLength: 'Same as last',
    intensity: 'Progress the weight',
    frequency: 'Same as last',
    reason: 'You want to push — no weight reduction applied.',
  },
  {
    questionKey: 'q10_push',
    answerKey: 'same',
    sessionLength: 'Same as last',
    intensity: 'Maintain the weight',
    frequency: 'Same as last',
    reason: 'Keep the current program unchanged.',
  },
  {
    questionKey: 'q10_push',
    answerKey: 'reduced',
    sessionLength: 'Slightly shorter',
    intensity: 'Reduce the weight',
    frequency: 'Same as last',
    weightReductionPct: 15, // within 10–20% (BA-004); TBD-11 confirm exact mapping
    reason: 'Reduced intensity requested — easing back in.',
  },
] as const;

// Non-diagnostic statement shown on every quiz screen (Rule I-10, FR-088).
export const QUIZ_NON_DIAGNOSTIC_STATEMENT =
  'Non-diagnostic quiz · used only to adjust your workouts';

// Analytics event names (Section 8.7). Stored locally only (Rule I-3).
export const ANALYTIC_EVENTS = [
  'quiz_prompt_shown',
  'quiz_started',
  'quiz_completed',
  'program_accepted',
  'next_workout_started',
  'workout_quit',
  'micro_session_saved',
  'micro_session_discarded',
  'workout_started_within_48h',
  'stitch_started',
  'stitch_preview_shown',
  'stitch_confirmed',
  'stitch_reversed',
] as const;
export type AnalyticEventName = (typeof ANALYTIC_EVENTS)[number];
