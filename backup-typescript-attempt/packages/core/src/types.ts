// @atomfit/core/src/types.ts
// Domain entities (Section 7 data model, informative attribute names).
// Rule I-20: units — weight kg (decimal 0–999.9, 1 decimal), reps whole 0–999,
// duration whole seconds, height cm.
// Rule I-21: timestamps stored UTC + IANA time-zone id.

export type Id = string & { readonly __brand: unique symbol };
export type UtcMillis = number;

export type Theme = 'light' | 'dark';
export type SessionType = 'full' | 'micro' | 'stitched';
export type CompletionStatus = 'complete' | 'incomplete';
export type InputMethod = 'manual' | 'sensor' | 'voice' | 'lockscreen';
export type QuizStatus = 'complete' | 'incomplete';
export type QuizSource = 'manual' | 'quiz';
export type Gender = 'Male' | 'Female' | 'Prefer not to say';

export interface UserAccount {
  id: Id;
  username: string;
  email: string;
  passwordHash: string; // salted hash via slow KDF (Rule I-23)
  salt: string;
  dateOfBirth?: string; // ISO date
  gender?: Gender; // BA-002
  createdAtUtc: UtcMillis;
  updatedAtUtc: UtcMillis;
}

export interface AppSetting {
  userId: Id;
  theme: Theme;
  analyticsEnabled: boolean;
}

export interface Exercise {
  id: Id;
  name: string;
  description?: string;
  difficultyNote?: string;
}

export interface Program {
  id: Id;
  userId: Id | null; // null = built-in
  name: string;
  description?: string;
  isCurrent: boolean; // Rule I-14: exactly one Current per user
}

export interface ProgramVersion {
  id: Id;
  programId: Id;
  versionNo: number;
  source: QuizSource;
  createdAtUtc: UtcMillis;
}

export interface ProgramSet {
  id: Id;
  programVersionId: Id;
  exerciseId: Id;
  setNo: number;
  plannedWeightKg: number; // kg, 1 decimal
  plannedRestS: number; // seconds
}

export interface WorkoutSession {
  id: Id;
  userId: Id;
  programVersionId?: Id;
  name: string;
  type: SessionType;
  completionStatus: CompletionStatus;
  parentSessionId?: Id; // set only for stitched parent
  startedAtUtc: UtcMillis;
  timeZone: string; // IANA id (Rule I-21)
  durationS?: number; // whole seconds
  createdAtUtc: UtcMillis;
  updatedAtUtc: UtcMillis;
}

export interface SetLog {
  id: Id;
  sessionId: Id;
  exerciseId: Id;
  setNo: number;
  weightKg: number; // kg
  reps: number; // whole 0–999
  restS?: number; // seconds
  inputMethod: InputMethod;
  loggedAtUtc: UtcMillis;
}

export interface StitchedSession {
  parentSessionId: Id;
  childSessionIds: [Id, Id]; // exactly two children (Rule I-16)
  combinedSets: number;
  combinedReps: number;
  combinedVolumeKg: number; // sum(weight × reps) over children's completed sets
  combinedDurationS: number;
}

export interface QuizAttempt {
  id: Id;
  userId: Id;
  startedAtUtc: UtcMillis;
  status: QuizStatus;
}

export interface QuizAnswer {
  id: Id;
  quizAttemptId: Id;
  questionKey: string;
  answerKey: string;
}

export interface UserProgramAdjustment {
  id: Id;
  quizAttemptId: Id;
  programVersionFrom: Id;
  programVersionTo: Id;
  sessionLength: string;
  intensity: string;
  frequency: string;
  accepted: boolean;
  reverted: boolean;
}

export interface AnalyticsEvent {
  id: Id;
  name: string;
  timestampUtc: UtcMillis;
  anonUserId: Id;
  sessionId?: Id;
  properties: Record<string, unknown>;
}

// ---- Validation bounds (Rule I-20) ----
export const UNIT = {
  weightKgMin: 0,
  weightKgMax: 999.9,
  weightKgDecimals: 1,
  repsMin: 0,
  repsMax: 999,
} as const;

export function isValidWeightKg(v: number): boolean {
  return Number.isFinite(v) && v >= UNIT.weightKgMin && v <= UNIT.weightKgMax;
}

export function isValidReps(v: number): boolean {
  return Number.isInteger(v) && v >= UNIT.repsMin && v <= UNIT.repsMax;
}

// Volume = sum(weight × reps) over completed sets (a completed set has >= 1 rep).
export function volumeKg(sets: Array<{ weightKg: number; reps: number }>): number {
  return sets.reduce((acc, s) => (s.reps >= 1 ? acc + s.weightKg * s.reps : acc), 0);
}
