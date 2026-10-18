// @atomfit/core/src/save-set.service.ts
// The ONE Save-Set service (Rule I-5). Manual entry, auto-count, voice logging,
// and lock-screen actions ALL persist sets through this service. No other code
// path may write set_log rows.
// Rule I-6: idempotent writes — saving an existing set id must not duplicate.
// Rule I-8: durability — persist within 1 second; restored after force-close
// (durability is the storage layer's job; this service is the transaction boundary).

import type { Id, SetLog, InputMethod } from './types';
import { isValidWeightKg, isValidReps } from './types';
import { newId } from './id';

export interface SaveSetInput {
  sessionId: Id;
  exerciseId: Id;
  setNo: number;
  weightKg: number; // kg
  reps: number; // whole 0–999
  restS?: number; // seconds
  inputMethod: InputMethod;
  idempotencyKey?: Id; // client-generated id; reuse => no duplicate (Rule I-6)
  loggedAtUtc?: number; // defaults to now
}

export interface SaveSetService {
  saveSet(input: SaveSetInput): Promise<SetLog>;
}

export interface SetLogRepository {
  findById(id: Id): Promise<SetLog | null>;
  findBySession(sessionId: Id): Promise<SetLog[]>;
  insert(set: SetLog): Promise<void>;
  update(set: SetLog): Promise<void>;
}

export class SaveSetServiceImpl implements SaveSetService {
  constructor(private readonly repo: SetLogRepository) {}

  async saveSet(input: SaveSetInput): Promise<SetLog> {
    // Validate units (Rule I-20).
    if (!isValidWeightKg(input.weightKg)) {
      throw new Error(`weightKg must be 0–999.9 kg, got ${input.weightKg}`);
    }
    if (!isValidReps(input.reps)) {
      throw new Error(`reps must be a whole number 0–999, got ${input.reps}`);
    }

    const id = input.idempotencyKey ?? newId();
    const now = input.loggedAtUtc ?? Date.now();

    // Idempotency (Rule I-6): if a set with this id already exists, return it.
    const existing = await this.repo.findById(id);
    if (existing) {
      return existing;
    }

    const set: SetLog = {
      id,
      sessionId: input.sessionId,
      exerciseId: input.exerciseId,
      setNo: input.setNo,
      weightKg: input.weightKg,
      reps: input.reps,
      restS: input.restS,
      inputMethod: input.inputMethod,
      loggedAtUtc: now,
    };

    await this.repo.insert(set);
    return set;
  }
}
