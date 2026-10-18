// @atomfit/core/src/inactivity.service.ts
// 7-day inactivity trigger (BA-004, C-1). Evaluated when the app is opened
// (Section 1.3.7). A session belongs to the calendar day of its start in the
// stored IANA time zone (Rule I-21).

import type { UtcMillis } from './types';

export interface InactivityService {
  // True when the most recent completed workout started >= 7 local calendar
  // days ago (counts full OR micro sessions — Rule I-15).
  isInactive(lastWorkoutStartedAtUtc: UtcMillis, nowUtc: UtcMillis, timeZone: string): boolean;
  daysSince(lastWorkoutStartedAtUtc: UtcMillis, nowUtc: UtcMillis, timeZone: string): number;
}

export class InactivityServiceImpl implements InactivityService {
  isInactive(
    lastWorkoutStartedAtUtc: UtcMillis,
    nowUtc: UtcMillis,
    timeZone: string,
  ): boolean {
    return this.daysSince(lastWorkoutStartedAtUtc, nowUtc, timeZone) >= 7;
  }

  // Count local calendar days between the workout's start and now in the stored zone.
  daysSince(
    lastWorkoutStartedAtUtc: UtcMillis,
    nowUtc: UtcMillis,
    timeZone: string,
  ): number {
    const startLocal = new Date(lastWorkoutStartedAtUtc).toLocaleDateString('en-US', {
      timeZone,
    });
    const nowLocal = new Date(nowUtc).toLocaleDateString('en-US', { timeZone });
    const startDay = new Date(startLocal).setHours(0, 0, 0, 0);
    const nowDay = new Date(nowLocal).setHours(0, 0, 0, 0);
    return Math.max(0, Math.round((nowDay - startDay) / (1000 * 60 * 60 * 24)));
  }
}
