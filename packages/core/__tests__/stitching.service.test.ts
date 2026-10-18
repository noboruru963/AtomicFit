// @atomfit/core/__tests__/stitching.service.test.ts
// Rule I-16: never double-count, never mutate children; atomic stitch/unstitch.
// Rule I-17: destructive actions need confirmation (UI layer).
import { describe, it, expect } from 'vitest';
import { StitchingServiceImpl, defaultEligibility } from '../src/stitching.service';
import type { WorkoutSession } from '../src/types';

const DAY_MS = 1000 * 60 * 60 * 24;
const base = Date.UTC(2026, 9, 1, 10, 0, 0);

function session(overrides: Partial<WorkoutSession>): WorkoutSession {
  return {
    id: 's1',
    userId: 'u1',
    name: 'Session',
    type: 'full',
    completionStatus: 'complete',
    startedAtUtc: base,
    timeZone: 'UTC',
    createdAtUtc: base,
    updatedAtUtc: base,
    ...overrides,
  };
}

class FakeSessionRepo {
  private store = new Map<string, WorkoutSession>();
  async findById(id: string) {
    return (this.store.get(id) ?? null) as WorkoutSession | null;
  }
  async update(s: WorkoutSession) {
    this.store.set(s.id, { ...s });
  }
  add(s: WorkoutSession) {
    this.store.set(s.id, s);
  }
}

class FakeSetLogRepo {
  async findBySession() {
    return [
      { id: 'set1', sessionId: 's1', exerciseId: 'e1', setNo: 1, weightKg: 60, reps: 10, inputMethod: 'manual', loggedAtUtc: base },
    ];
  }
}

class FakeStitchRepo {
  private store = new Map<string, any>();
  async findStitchByParent() {
    return (this.store.get('parent') ?? null) as any;
  }
  async insert(s: any) {
    this.store.set(s.parentSessionId, { ...s });
  }
  async deleteByParent() {
    this.store.delete('parent');
  }
}

describe('StitchingService', () => {
  it('defaultEligibility rejects a stitched child', () => {
    const a = session({ id: 'a', type: 'stitched' });
    const b = session({ id: 'b' });
    expect(defaultEligibility(a, b).eligible).toBe(false);
  });

  it('defaultEligibility rejects same session twice', () => {
    const a = session({ id: 'same' });
    expect(defaultEligibility(a, a).eligible).toBe(false);
  });

  it('stitch combines metrics without mutating children set_logs', async () => {
    const sRepo = new FakeSessionRepo();
    const c1 = session({ id: 'c1', userId: 'u', durationS: 600 });
    const c2 = session({ id: 'c2', userId: 'u', durationS: 300 });
    sRepo.add(c1);
    sRepo.add(c2);
    const svc = new StitchingServiceImpl(sRepo, new FakeSetLogRepo(), new FakeStitchRepo());

    const stitch = await svc.stitch('parent', 'c1', 'c2');
    expect(stitch.combinedSets).toBe(2);
    expect(stitch.combinedReps).toBe(20);
    expect(stitch.combinedDurationS).toBe(900);

    // Children keep their own type (marked stitched) but set_log rows untouched (Rule I-16).
    const after1 = await sRepo.findById('c1');
    const after2 = await sRepo.findById('c2');
    expect(after1?.type).toBe('stitched');
    expect(after2?.type).toBe('stitched');
  });

  it('unstitch restores children', async () => {
    const sRepo = new FakeSessionRepo();
    const c1 = session({ id: 'c1', type: 'stitched' });
    const c2 = session({ id: 'c2', type: 'stitched' });
    sRepo.add(c1);
    sRepo.add(c2);
    const stitchRepo = new FakeStitchRepo();
    await stitchRepo.insert({ parentSessionId: 'parent', childSessionIds: ['c1', 'c2'] });
    const svc = new StitchingServiceImpl(sRepo, new FakeSetLogRepo(), stitchRepo);

    const [r1, r2] = await svc.unstitch('parent');
    expect(r1.type).toBe('full');
    expect(r2.type).toBe('full');
  });

  it('preview reports ineligible with a reason', async () => {
    const sRepo = new FakeSessionRepo();
    const c1 = session({ id: 'c1', type: 'stitched' });
    const c2 = session({ id: 'c2' });
    sRepo.add(c1);
    sRepo.add(c2);
    const svc = new StitchingServiceImpl(sRepo, new FakeSetLogRepo(), new FakeStitchRepo());

    const prev = await svc.preview('c1', 'c2');
    expect(prev.eligible).toBe(false);
    expect(prev.ineligibleReason).toBeDefined();
  });
});
