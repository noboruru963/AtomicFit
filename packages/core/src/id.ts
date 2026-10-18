// @atomfit/core/src/id.ts
// Client-generated UUIDs for idempotent writes (Rule I-6).
import type { Id } from './types';

// ASSUMPTION: the runtime (browser/Node 19+) provides crypto.randomUUID.
// If unavailable, fall back to a timestamp+random string (still unique enough for local MVP).
export function newId(): Id {
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const crypto = (typeof self !== 'undefined' ? (self as any) : (globalThis as any)).crypto;
  const raw =
    crypto && typeof crypto.randomUUID === 'function'
      ? crypto.randomUUID()
      : `${Date.now()}-${Math.random().toString(36).slice(2)}`;
  return raw as Id;
}
