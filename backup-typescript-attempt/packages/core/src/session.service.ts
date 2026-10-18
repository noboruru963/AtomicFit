// @atomfit/core/src/session.service.ts
// Session lifecycle: create, finish, save-as-micro, resume micro.
// Rule I-15: micro sessions are first-class (type=micro, status=incomplete),
// count as completed for calendar / monthly count / inactivity, and can be resumed.
// Rule I-7: atomic multi-record operations (implemented by storage transactions).

import type {
  Id,
  WorkoutSession,
  SessionType,
  CompletionStatus,
  ProgramSet,
} from './types';
import { newId } from './id';

export interface CreateSessionInput {
  userId: Id;
  programVersionId?: Id;
  name: string;
  type?: SessionType;
  startedAtUtc?: number;
  timeZone: string; // IANA (Rule I-21)
  plannedSets?: ProgramSet[]; // for a program-backed workout
}

export interface SessionRepository {
  findById(id: Id): Promise<WorkoutSession | null>;
  findUnfinishedByUser(userId: Id): Promise<WorkoutSession | null>; // most recent
  insert(session: WorkoutSession): Promise<void>;
  update(session: WorkoutSession): Promise<void>;
}

export interface SessionService {
  createSession(input: CreateSessionInput): Promise<WorkoutSession>;
  finishSession(sessionId: Id): Promise<WorkoutSession>;
  saveAsMicro(sessionId: Id): Promise<WorkoutSession>;
  resumeMicro(sessionId: Id): Promise<WorkoutSession>;
}

export class SessionServiceImpl implements SessionService {
  constructor(private readonly repo: SessionRepository) {}

  async createSession(input: CreateSessionInput): Promise<WorkoutSession> {
    const now = input.startedAtUtc ?? Date.now();
    const session: WorkoutSession = {
      id: newId(),
      userId: input.userId,
      programVersionId: input.programVersionId,
      name: input.name,
      type: input.type ?? 'full',
      completionStatus: 'incomplete',
      startedAtUtc: now,
      timeZone: input.timeZone,
      createdAtUtc: now,
      updatedAtUtc: now,
    };
    await this.repo.insert(session);
    return session;
  }

  async finishSession(sessionId: Id): Promise<WorkoutSession> {
    const session = await this.repo.findById(sessionId);
    if (!session) throw new Error(`Session ${sessionId} not found`);
    const now = Date.now();
    const updated: WorkoutSession = {
      ...session,
      completionStatus: 'complete',
      durationS: Math.max(0, Math.round((now - session.startedAtUtc) / 1000)),
      updatedAtUtc: now,
    };
    await this.repo.update(updated);
    return updated;
  }

  // Save the completed portion of an early-exited workout as a micro session (Rule I-15, US-005).
  async saveAsMicro(sessionId: Id): Promise<WorkoutSession> {
    const session = await this.repo.findById(sessionId);
    if (!session) throw new Error(`Session ${sessionId} not found`);
    const now = Date.now();
    const micro: WorkoutSession = {
      ...session,
      id: newId(), // new record for the micro portion (Rule I-6 idempotency by id)
      type: 'micro',
      completionStatus: 'incomplete',
      parentSessionId: session.id,
      durationS: Math.max(0, Math.round((now - session.startedAtUtc) / 1000)),
      updatedAtUtc: now,
    };
    await this.repo.insert(micro);
    return micro;
  }

  // Resume a micro session: load completed + remaining sets into an active workout (US-005).
  async resumeMicro(sessionId: Id): Promise<WorkoutSession> {
    const session = await this.repo.findById(sessionId);
    if (!session) throw new Error(`Session ${sessionId} not found`);
    if (session.type !== 'micro') {
      throw new Error(`Session ${sessionId} is not a micro session`);
    }
    const now = Date.now();
    const updated: WorkoutSession = {
      ...session,
      id: newId(), // resume re-opens as a new active attempt (Rule I-6)
      type: 'full',
      completionStatus: 'incomplete',
      startedAtUtc: now,
      updatedAtUtc: now,
    };
    await this.repo.insert(updated);
    return updated;
  }
}
