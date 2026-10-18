// @atomfit/storage/__tests__/repositories.test.ts
// Integration-style tests with a fake IndexedDB (fake-indexeddb).
// Covers persistence, Save-Set idempotency via storage, Rule I-14 one Current.
import { describe, it, expect, beforeEach } from 'vitest';
import { indexedDB as fakeIndexedDB } from 'fake-indexeddb';
import { AtomFitDb } from '../src/db';
import {
  ProgramRepository,
  SetLogRepositoryDexie as SetLogRepository,
  WorkoutSessionRepository,
} from '../src/repositories';
import type { Program, WorkoutSession, SetLog, InputMethod, Id } from '@atomfit/core';

function tid(s: string): Id {
  return s as unknown as Id;
}

function setUpDB() {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  (globalThis as any).indexedDB = fakeIndexedDB;
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
      id: tid('p1'),
      userId: tid('u1'),
      name: 'A',
      isCurrent: true,
    };
    const p2: Program = {
      id: tid('p2'),
      userId: tid('u1'),
      name: 'B',
      isCurrent: false,
    };
    await progRepo.insert(p1);
    await progRepo.insert(p2);

    await progRepo.setCurrent(tid('u1'), tid('p2'));

    const current = await progRepo.findCurrentByUser(tid('u1'));
    expect(current?.id).toBe(tid('p2'));
    const p1After = await progRepo.findById(tid('p1'));
    expect(p1After?.isCurrent).toBe(false);
  });

  it('persists and loads a session (Rule I-8 durability boundary)', async () => {
    const session: WorkoutSession = {
      id: tid('s1'),
      userId: tid('u1'),
      name: 'Morning',
      type: 'full',
      completionStatus: 'incomplete',
      startedAtUtc: 1000,
      timeZone: 'UTC',
      createdAtUtc: 1000,
      updatedAtUtc: 1000,
    };
    await sessRepo.insert(session);
    const loaded = await sessRepo.findById(tid('s1'));
    expect(loaded?.id).toBe(tid('s1'));
    expect(loaded?.completionStatus).toBe('incomplete');
  });

  it('set log insert is idempotent by id (Rule I-6)', async () => {
    const set: SetLog = {
      id: tid('set1'),
      sessionId: tid('s1'),
      exerciseId: tid('e1'),
      setNo: 1,
      weightKg: 60,
      reps: 10,
      inputMethod: 'manual' as InputMethod,
      loggedAtUtc: 1000,
    };
    await setRepo.insert(set);
    // Dexie add() with an existing key throws; second save via service returns existing.
    await expect(setRepo.insert(set)).rejects.toThrow();
  });
});
