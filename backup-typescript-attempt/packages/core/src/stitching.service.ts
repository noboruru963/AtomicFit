// @atomfit/core/src/stitching.service.ts
// Set stitching (US-006, FR-100..108). A stitched session is a parent referencing
// exactly two children; children keep their own data; every child's metrics count
// exactly once in totals; unstitch restores both children.
// Rule I-16: never double-count, never mutate children. Rule I-7: atomic.
// Rule I-17: destructive actions need confirmation (handled by UI layer).

import type {
  Id,
  WorkoutSession,
  SetLog,
  StitchedSession,
} from './types';

export interface SessionRepository {
  findById(id: Id): Promise<WorkoutSession | null>;
  update(session: WorkoutSession): Promise<void>;
}

export interface SetLogRepository {
  findBySession(sessionId: Id): Promise<SetLog[]>;
}

export interface StitchRepository {
  findStitchByParent(parentSessionId: Id): Promise<StitchedSession | null>;
  insert(stitch: StitchedSession): Promise<void>;
  deleteByParent(parentSessionId: Id): Promise<void>;
}

export interface StitchPreview {
  parent: WorkoutSession;
  children: [WorkoutSession, WorkoutSession];
  combinedSets: number;
  combinedReps: number;
  combinedVolumeKg: number;
  combinedDurationS: number;
  eligible: boolean;
  ineligibleReason?: string;
}

export interface StitchingService {
  preview(child1Id: Id, child2Id: Id): Promise<StitchPreview>;
  stitch(
    parentSessionId: Id,
    child1Id: Id,
    child2Id: Id,
  ): Promise<StitchedSession>;
  unstitch(parentSessionId: Id): Promise<[WorkoutSession, WorkoutSession]>;
}

// TBD-17: stitching eligibility rules are not fully specified. This is the
// smallest replaceable eligibility check. Promote to an addendum when decided.
export function defaultEligibility(
  a: WorkoutSession,
  b: WorkoutSession,
): { eligible: boolean; reason?: string } {
  if (a.type === 'stitched' || b.type === 'stitched') {
    return { eligible: false, reason: 'A stitched session cannot be a child.' };
  }
  if (a.userId !== b.userId) {
    return { eligible: false, reason: 'Sessions must belong to the same user.' };
  }
  // Must be distinct sessions.
  if (a.id === b.id) {
    return { eligible: false, reason: 'Select two different sessions.' };
  }
  // TBD-17: add same-program / time-window / completion rules here.
  return { eligible: true };
}

export class StitchingServiceImpl implements StitchingService {
  constructor(
    private readonly sessionRepo: SessionRepository,
    private readonly setLogRepo: SetLogRepository,
    private readonly stitchRepo: StitchRepository,
    private readonly eligibility = defaultEligibility,
  ) {}

  async preview(child1Id: Id, child2Id: Id): Promise<StitchPreview> {
    const [c1, c2] = await Promise.all([
      this.sessionRepo.findById(child1Id),
      this.sessionRepo.findById(child2Id),
    ]);
    if (!c1 || !c2) throw new Error('One or both sessions not found');

    const elig = this.eligibility(c1, c2);
    const parent = await this.sessionRepo.findById(child1Id); // placeholder parent metrics

    const sets1 = await this.setLogRepo.findBySession(c1.id);
    const sets2 = await this.setLogRepo.findBySession(c2.id);
    const allSets = [...sets1, ...sets2];

    const combinedSets = allSets.length;
    const combinedReps = allSets.reduce((acc, s) => acc + s.reps, 0);
    const combinedVolumeKg = allSets.reduce(
      (acc, s) => (s.reps >= 1 ? acc + s.weightKg * s.reps : acc),
      0,
    );
    const combinedDurationS =
      (c1.durationS ?? 0) + (c2.durationS ?? 0);

    return {
      parent: c1,
      children: [c1, c2],
      combinedSets,
      combinedReps,
      combinedVolumeKg,
      combinedDurationS,
      eligible: elig.eligible,
      ineligibleReason: elig.reason,
    };
  }

  async stitch(
    parentSessionId: Id,
    child1Id: Id,
    child2Id: Id,
  ): Promise<StitchedSession> {
    const prev = await this.stitchRepo.findStitchByParent(parentSessionId);
    if (prev) throw new Error(`Session ${parentSessionId} is already a stitch parent.`);

    const preview = await this.preview(child1Id, child2Id);
    if (!preview.eligible) {
      throw new Error(preview.ineligibleReason ?? 'Sessions are not eligible for stitching.');
    }

    // Mark both children as stitched (they keep their own set_log rows — Rule I-16).
    const c1 = await this.sessionRepo.findById(child1Id);
    const c2 = await this.sessionRepo.findById(child2Id);
    if (!c1 || !c2) throw new Error('Child session not found');

    const stitched: StitchedSession = {
      parentSessionId,
      childSessionIds: [child1Id, child2Id],
      combinedSets: preview.combinedSets,
      combinedReps: preview.combinedReps,
      combinedVolumeKg: preview.combinedVolumeKg,
      combinedDurationS: preview.combinedDurationS,
    };

    // Atomic multi-record operation (Rule I-7): repository must wrap in a transaction.
    await this.stitchRepo.insert(stitched);

    const updatedC1: WorkoutSession = { ...c1, type: 'stitched' };
    const updatedC2: WorkoutSession = { ...c2, type: 'stitched' };
    await this.sessionRepo.update(updatedC1);
    await this.sessionRepo.update(updatedC2);

    return stitched;
  }

  // Unstitch restores both children and prior totals (Rule I-16).
  async unstitch(parentSessionId: Id): Promise<[WorkoutSession, WorkoutSession]> {
    const stitch = await this.stitchRepo.findStitchByParent(parentSessionId);
    if (!stitch) throw new Error(`No stitching found for parent ${parentSessionId}`);

    const [child1Id, child2Id] = stitch.childSessionIds;
    const c1 = await this.sessionRepo.findById(child1Id);
    const c2 = await this.sessionRepo.findById(child2Id);
    if (!c1 || !c2) throw new Error('Child session not found');

    // Atomic: delete stitch record + restore children in one transaction.
    await this.stitchRepo.deleteByParent(parentSessionId);

    const restored1: WorkoutSession = { ...c1, type: 'full' };
    const restored2: WorkoutSession = { ...c2, type: 'full' };
    await this.sessionRepo.update(restored1);
    await this.sessionRepo.update(restored2);

    return [restored1, restored2];
  }
}
