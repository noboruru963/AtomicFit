// @atomfit/storage/src/db.ts
// Typed Dexie (IndexedDB) schema with versioning + migrations.
// Rule I-6 idempotency and Rule I-7 atomic transactions are implemented here
// via Dexie tables and `db.transaction('rw', ...)`.
import Dexie, { Table, type Transaction } from 'dexie';
import type {
  UserAccount,
  AppSetting,
  Exercise,
  Program,
  ProgramVersion,
  ProgramSet,
  WorkoutSession,
  SetLog,
  StitchedSession,
  QuizAttempt,
  QuizAnswer,
  UserProgramAdjustment,
  AnalyticsEvent,
  Id,
} from '@atomfit/core';

export class AtomFitDb extends Dexie {
  userAccounts!: Table<UserAccount, Id>;
  appSettings!: Table<AppSetting, Id>;
  exercises!: Table<Exercise, Id>;
  programs!: Table<Program, Id>;
  programVersions!: Table<ProgramVersion, Id>;
  programSets!: Table<ProgramSet, Id>;
  workoutSessions!: Table<WorkoutSession, Id>;
  setLogs!: Table<SetLog, Id>;
  stitchedSessions!: Table<StitchedSession, Id>;
  quizAttempts!: Table<QuizAttempt, Id>;
  quizAnswers!: Table<QuizAnswer, Id>;
  userProgramAdjustments!: Table<UserProgramAdjustment, Id>;
  analyticsEvents!: Table<AnalyticsEvent, Id>;

  constructor() {
    super('AtomFitDb');
    this.version(1).stores({
      userAccounts: '++id, email, username',
      appSettings: '++id, userId',
      exercises: '++id, name',
      programs: '++id, userId, isCurrent',
      programVersions: '++id, programId, versionNo',
      programSets: '++id, programVersionId, exerciseId, setNo',
      workoutSessions:
        '++id, userId, programVersionId, type, completionStatus, startedAtUtc',
      setLogs: '++id, sessionId, exerciseId, setNo, inputMethod, loggedAtUtc',
      stitchedSessions: '++id, parentSessionId',
      quizAttempts: '++id, userId, startedAtUtc',
      quizAnswers: '++id, quizAttemptId, questionKey',
      userProgramAdjustments: '++id, quizAttemptId, programVersionTo',
      analyticsEvents: '++id, name, timestampUtc, anonUserId',
    });

    // Rule I-8: durability — changes to an active workout persisted within 1s.
    // Dexie writes to IndexedDB; callers should await the returned promise.
  }
}

// Singleton database instance (Rule I-5: all writes route through Save-Set service
// which uses the setLogs table via this db).
export const db = new AtomFitDb();

// Type-safe atomic transaction helper (Rule I-7).
// Dexie's transaction() accepts tables as variadic arguments, so we spread the
// array and cast to satisfy TypeScript's rest/tuple checking.
export function atomically<R>(
  tables: Array<Table<any, any>>,
  mode: 'r' | 'rw' | 'rw!',
  work: (tx: Transaction) => Promise<R>,
): Promise<R> {
  const args: unknown[] = [mode, ...tables, work];
  return (db.transaction as (...a: unknown[]) => Promise<R>)(...args);
}
