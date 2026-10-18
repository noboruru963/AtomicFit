// @atomfit/core/src/progression.ts
// Progression policy (TBD-18). Results must be identical stitched or not
// (Rule I-16). Smallest replaceable implementation; promote to an addendum.

import type { SetLog } from './types';

// Next planned weight for an exercise given its last completed sets.
// ASSUMPTION: linear +2.5 kg progression when all planned reps completed.
// TBD-18: confirm exact progression policy with the team.
export function nextPlannedWeightKg(
  lastSets: SetLog[],
  plannedWeightKg: number,
  targetReps: number,
): number {
  const completed = lastSets.filter((s) => s.reps >= targetReps);
  if (completed.length === 0) return plannedWeightKg; // not ready to progress
  const allCompleted = completed.length === lastSets.length;
  return allCompleted ? Math.round((plannedWeightKg + 2.5) * 10) / 10 : plannedWeightKg;
}
