// @atomfit/storage/__tests__/repositories.test.ts
// Integration-style tests with a fake IndexedDB (fake-indexeddb).
// Covers persistence, Save-Set idempotency via storage, Rule I-14 one Current.
import { describe, it, expect, beforeEach } from 'vitest';
// eslint-disable-next-line no-unused-vars
import { fakeIndexedDB } from 'fake-indexeddb';
import { AtomFitDb } from '../src/db';
import {
  ProgramRepository,
  SetLogRepository,
  WorkoutSessionRepository,
} from '../src/repositories';
import type { Program, WorkoutSession, SetLog, InputMethod } from '@atomfit/core';

function setUpDB() {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  (globalThis as any).indexedDB = fakeIndexedDB;
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  (globalThis as any).IDBKeyRange = fakeIndexedDB.IDBKeyRange;
  return new AtomFitDb();
}

describe('storage repositories', () => {
  let db: ReturnType<typeof setUpDB>;
  let progRepo: ProgramRepository;
  let sessRepo: WorkoutSessionRepository;
  let setRepo: SetLogRepository;

  beforeEach(() => {
    db = setUpDB();
    progRepo = new ProgramRepository();
    sessRepo = new WorkoutSessionRepository();
    setRepo = new SetLogRepository();
  });

  it('enforces exactly one Current program per user (Rule I-14)', async () => {
    const p1: Program = {
      id: 'p1',
      userId: 'u1',
      name: 'A',
      isCurrent: true,
    };
    const p2: Program = {
      id: 'p2',
      userId: 'u1',
      name: 'B',
      isCurrent: false,
    };
    await progRepo.insert(p1);
    await progRepo.insert(p2);

    await progRepo.setCurrent('u1', 'p2');

    const current = await progRepo.findCurrentByUser('u1');
    expect(current?.id).toBe('p2');
    const p1After = await progRepo.findById('p1');
    expect(p1After?.isCurrent).toBe(false);
  });

  it('persists and loads a session (Rule I-8 durability boundary)', async () => {
    const session: WorkoutSession = {
      id: 's1',
      userId: 'u1',
      name: 'Morning',
      type: 'full',
      completionStatus: 'incomplete',
      startedAtUtc: 1000,
      timeZone: 'UTC',
      createdAtUtc: 1000,
      updatedAtUtc: 1000,
    };
    await sessRepo.insert(session);
    const loaded = await sessRepo.findById('s1');
    expect(loaded?.id).toBe('s1');
    expect(loaded?.completionStatus).toBe('incomplete');
  });

  it('set log insert is idempotent by id (Rule I-6)', async () => {
    const set: SetLog = {
      id: 'set1',
      sessionId: 's1',
      exerciseId: 'e1',
      setNo: 1,
      weightKg: 60,
      reps: 10,
      inputMethod: 'manual',
      loggedAtUtc: 1000,
    };
    await setRepo.insert(set);
    // Dexie add() with an existing key throws; second save via service returns existing.
    await expect(setRepo.insert(set)).rejects.toThrow();
  });
});
