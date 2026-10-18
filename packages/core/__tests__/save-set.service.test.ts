// @atomfit/core/__tests__/save-set.service.test.ts
// Rule I-5 (single Save-Set service), Rule I-6 (idempotent writes).
import { describe, it, expect } from 'vitest';
import { SaveSetServiceImpl } from '../src/save-set.service';
import type { InputMethod, SetLog, Id } from '../src/types';

function tid(s: string): Id {
  return s as unknown as Id;
}

class FakeRepo {
  private store = new Map<string, SetLog>();
  async findById(id: Id) {
    return (this.store.get(id) ?? null) as SetLog | null;
  }
  async findBySession() {
    return [];
  }
  async insert(s: SetLog) {
    if (this.store.has(s.id)) throw new Error('duplicate insert');
    this.store.set(s.id, { ...s });
  }
  async update(s: SetLog) {
    this.store.set(s.id, { ...s });
  }
}

describe('SaveSetService', () => {
  it('saves a set and returns it', async () => {
    const repo = new FakeRepo();
    const svc = new SaveSetServiceImpl(repo);
    const input = {
      sessionId: tid('s1'),
      exerciseId: tid('e1'),
      setNo: 1,
      weightKg: 60,
      reps: 10,
      inputMethod: 'manual' as InputMethod,
    };
    const out = await svc.saveSet(input);
    expect(out.reps).toBe(10);
    expect(out.weightKg).toBe(60);
    expect(out.inputMethod).toBe('manual');
  });

  it('is idempotent: saving the same id twice returns one record (Rule I-6)', async () => {
    const repo = new FakeRepo();
    const svc = new SaveSetServiceImpl(repo);
    const key = tid('idem-key-1');
    const a = await svc.saveSet({
      sessionId: tid('s1'),
      exerciseId: tid('e1'),
      setNo: 1,
      weightKg: 60,
      reps: 10,
      inputMethod: 'manual' as InputMethod,
      idempotencyKey: key,
    });
    const b = await svc.saveSet({
      sessionId: tid('s1'),
      exerciseId: tid('e1'),
      setNo: 1,
      weightKg: 99,
      reps: 99,
      inputMethod: 'voice' as InputMethod,
      idempotencyKey: key,
    });
    expect(b.id).toBe(a.id);
    expect(b.reps).toBe(10); // original values preserved, not overwritten
  });

  it('rejects invalid weightKg (Rule I-20)', async () => {
    const repo = new FakeRepo();
    const svc = new SaveSetServiceImpl(repo);
    await expect(
      svc.saveSet({
        sessionId: tid('s1'),
        exerciseId: tid('e1'),
        setNo: 1,
        weightKg: 1000,
        reps: 5,
        inputMethod: 'manual' as InputMethod,
      }),
    ).rejects.toThrow();
  });

  it('rejects invalid reps (Rule I-20)', async () => {
    const repo = new FakeRepo();
    const svc = new SaveSetServiceImpl(repo);
    await expect(
      svc.saveSet({
        sessionId: tid('s1'),
        exerciseId: tid('e1'),
        setNo: 1,
        weightKg: 60,
        reps: 1000,
        inputMethod: 'manual' as InputMethod,
      }),
    ).rejects.toThrow();
  });
});
