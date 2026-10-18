// @atomfit/core/__tests__/inactivity.service.test.ts
// 7-day inactivity trigger (BA-004, C-1). Boundary: 7 days => inactive, 6 days => active.
// Uses fixed time zone for determinism (Rule I-21: UTC + IANA).
import { describe, it, expect } from 'vitest';
import { InactivityServiceImpl } from '../src/inactivity.service';

const DAY_MS = 1000 * 60 * 60 * 24;

describe('InactivityService', () => {
  const svc = new InactivityServiceImpl();
  const tz = 'America/New_York';
  const now = Date.UTC(2026, 9, 18, 12, 0, 0); // 2026-10-18

  it('returns inactive at exactly 7 days', () => {
    const last = new Date(now - 7 * DAY_MS).getTime();
    expect(svc.isInactive(last, now, tz)).toBe(true);
    expect(svc.daysSince(last, now, tz)).toBeGreaterThanOrEqual(7);
  });

  it('returns active at 6 days (below threshold)', () => {
    const last = new Date(now - 6 * DAY_MS).getTime();
    expect(svc.isInactive(last, now, tz)).toBe(false);
  });

  it('returns inactive at 8 days', () => {
    const last = new Date(now - 8 * DAY_MS).getTime();
    expect(svc.isInactive(last, now, tz)).toBe(true);
  });
});
