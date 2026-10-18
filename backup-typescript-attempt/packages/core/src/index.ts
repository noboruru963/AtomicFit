// @atomfit/core — domain types + public API surface
// Rule I-04: core must not import UI, browser-device, or storage code.

export * from './types';
export * from './id';
export * from './config';
export * from './save-set.service';
export * from './session.service';
export * from './quiz.engine';
export * from './inactivity.service';
export * from './stitching.service';
export * from './progression';
export * from './analytics';
// Re-export repository interfaces explicitly to avoid ambiguity with storage package.
// These are port interfaces; storage package provides the Dexie implementations.
export type { SetLogRepository } from './save-set.service';
export type { SessionRepository } from './session.service';
export type { StitchRepository } from './stitching.service';
