// @atomfit/storage/src/repositories.ts
// Repository classes wrapping Dexie tables. Implement the core-port interfaces
// so the domain layer (packages/core) stays free of storage imports (Rule I-04).
// Rule I-6: idempotent writes. Rule I-7: atomic multi-record ops via db.transaction.

import {
  atomically,
  db,
  type AtomFitDb,
} from './db';
import type {
  Id,
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
} from '@atomfit/core';
import type { Table } from 'dexie';
import type {
  SetLogRepository as SetLogRepositoryPort,
  SessionRepository as SessionRepositoryPort,
  StitchRepository as StitchRepositoryPort,
} from '@atomfit/core';

// ---------------------------------------------------------------------------
// Generic CRUD repository
// ---------------------------------------------------------------------------
class CrudRepo<T extends { id: Id }> {
  constructor(public readonly table: Table<T, Id>) {}
  async findById(id: Id): Promise<T | null> {
    const entity = await this.table.get(id);
    return entity ?? null;
  }
  async insert(entity: T): Promise<void> {
    await this.table.add(entity); // add throws if key exists (idempotency guard)
  }
  async update(entity: T): Promise<void> {
    await this.table.put(entity);
  }
  async remove(id: Id): Promise<void> {
    await this.table.delete(id);
  }
}

// ---------------------------------------------------------------------------
// UserAccount
// ---------------------------------------------------------------------------
export class UserAccountRepository {
  private readonly repo = new CrudRepo<UserAccount>(db.userAccounts);
  async findById(id: Id) {
    return this.repo.findById(id);
  }
  async findByEmail(email: string) {
    const entity = await db.userAccounts.where('email').equals(email).first();
    return entity ?? null;
  }
  async insert(entity: UserAccount) {
    return this.repo.insert(entity);
  }
  async update(entity: UserAccount) {
    return this.repo.update(entity);
  }
}

// ---------------------------------------------------------------------------
// AppSetting
// ---------------------------------------------------------------------------
export class AppSettingRepository {
  async findByUser(userId: Id) {
    const entity = await db.appSettings.where('userId').equals(userId).first();
    return entity ?? null;
  }
  async upsert(entity: AppSetting) {
    await db.appSettings.put(entity);
  }
}

// ---------------------------------------------------------------------------
// Exercise
// ---------------------------------------------------------------------------
export class ExerciseRepository {
  async findAll() {
    return db.exercises.toArray();
  }
  async findById(id: Id) {
    const entity = await db.exercises.get(id);
    return entity ?? null;
  }
  async insert(entity: Exercise) {
    await db.exercises.add(entity);
  }
}

// ---------------------------------------------------------------------------
// Program (Rule I-14: exactly one Current per user — enforced here)
// ---------------------------------------------------------------------------
export class ProgramRepository {
  async findById(id: Id) {
    const entity = await db.programs.get(id);
    return entity ?? null;
  }
  async findCurrentByUser(userId: Id) {
    const entity = await db.programs
      .where('userId')
      .equals(userId)
      .filter((p) => p.isCurrent)
      .first();
    return entity ?? null;
  }
  async insert(entity: Program) {
    await db.programs.add(entity);
  }
  async update(entity: Program) {
    await db.programs.put(entity);
  }
  async setCurrent(userId: Id, programId: Id) {
    // Exactly one Current per user (Rule I-14): clear others atomically.
    await atomically([db.programs], 'rw', async () => {
      const others = await db.programs.where('userId').equals(userId).toArray();
      await Promise.all(
        others.map((p) =>
          p.id !== programId && p.isCurrent
            ? db.programs.update(p.id, { isCurrent: false })
            : Promise.resolve(),
        ),
      );
      await db.programs.update(programId, { isCurrent: true });
    });
  }
}

// ---------------------------------------------------------------------------
// ProgramVersion / ProgramSet
// ---------------------------------------------------------------------------
export class ProgramVersionRepository {
  async insert(entity: ProgramVersion) {
    await db.programVersions.add(entity);
  }
  async findByProgram(programId: Id) {
    return db.programVersions.where('programId').equals(programId).toArray();
  }
}
export class ProgramSetRepository {
  async insert(entity: ProgramSet) {
    await db.programSets.add(entity);
  }
  async findByVersion(versionId: Id) {
    return db.programSets.where('programVersionId').equals(versionId).toArray();
  }
}

// ---------------------------------------------------------------------------
// WorkoutSession (SessionRepository port)
// ---------------------------------------------------------------------------
export class WorkoutSessionRepository implements SessionRepositoryPort {
  async findById(id: Id) {
    const entity = await db.workoutSessions.get(id);
    return entity ?? null;
  }
  async findUnfinishedByUser(userId: Id) {
    const rows = await db.workoutSessions
      .where('userId')
      .equals(userId)
      .filter((s) => s.completionStatus === 'incomplete')
      .toArray();
    return (
      rows.sort((a, b) => (b.startedAtUtc ?? 0) - (a.startedAtUtc ?? 0))[0] ??
      null
    );
  }
  async insert(entity: WorkoutSession) {
    await db.workoutSessions.add(entity);
  }
  async update(entity: WorkoutSession) {
    await db.workoutSessions.put(entity);
  }
}

// ---------------------------------------------------------------------------
// SetLog (SetLogRepository port — Rule I-5: written only via Save-Set service)
// ---------------------------------------------------------------------------
export class SetLogRepositoryDexie implements SetLogRepositoryPort {
  async findById(id: Id) {
    const entity = await db.setLogs.get(id);
    return entity ?? null;
  }
  async findBySession(sessionId: Id) {
    return db.setLogs.where('sessionId').equals(sessionId).toArray();
  }
  async insert(entity: SetLog) {
    await db.setLogs.add(entity);
  }
  async update(entity: SetLog) {
    await db.setLogs.put(entity);
  }
}

// ---------------------------------------------------------------------------
// StitchedSession (StitchRepository port)
// ---------------------------------------------------------------------------
export class StitchedSessionRepository implements StitchRepositoryPort {
  async findStitchByParent(parentSessionId: Id) {
    const entity = await db.stitchedSessions
      .where('parentSessionId')
      .equals(parentSessionId)
      .first();
    return entity ?? null;
  }
  async insert(entity: StitchedSession) {
    await db.stitchedSessions.add(entity);
  }
  async deleteByParent(parentSessionId: Id) {
    await db.stitchedSessions.where('parentSessionId').equals(parentSessionId).delete();
  }
}

// ---------------------------------------------------------------------------
// Quiz
// ---------------------------------------------------------------------------
export class QuizAttemptRepository {
  async insert(entity: QuizAttempt) {
    await db.quizAttempts.add(entity);
  }
  async findById(id: Id) {
    const entity = await db.quizAttempts.get(id);
    return entity ?? null;
  }
  async update(entity: QuizAttempt) {
    await db.quizAttempts.put(entity);
  }
}
export class QuizAnswerRepository {
  async insert(entity: QuizAnswer) {
    await db.quizAnswers.add(entity);
  }
  async findByAttempt(attemptId: Id) {
    return db.quizAnswers.where('quizAttemptId').equals(attemptId).toArray();
  }
}
export class UserProgramAdjustmentRepository {
  async insert(entity: UserProgramAdjustment) {
    await db.userProgramAdjustments.add(entity);
  }
  async findByAttempt(attemptId: Id) {
    return db.userProgramAdjustments
      .where('quizAttemptId')
      .equals(attemptId)
      .toArray();
  }
}

// ---------------------------------------------------------------------------
// Analytics (local only, Rule I-3)
// ---------------------------------------------------------------------------
export class AnalyticsEventRepository {
  async insert(entity: AnalyticsEvent) {
    await db.analyticsEvents.add(entity);
  }
  async findAll() {
    return db.analyticsEvents.toArray();
  }
  async clear() {
    await db.analyticsEvents.clear();
  }
}
