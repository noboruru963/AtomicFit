// @atomfit/core/src/analytics.ts
// Local-only analytics event schema (Section 8.7, Rule I-3: no transmission).
// Common schema reused across features (Rule I-13 / NFR-044).

import type { Id, UtcMillis, AnalyticEventName } from './config';
import type { AnalyticsEvent } from './types';
import { newId } from './id';

export interface AnalyticsService {
  record(event: Omit<AnalyticsEvent, 'id'>): Promise<void>;
}

export class InMemoryAnalyticsService implements AnalyticsService {
  private events: AnalyticsEvent[] = [];

  async record(event: Omit<AnalyticsEvent, 'id'>): Promise<void> {
    const full: AnalyticsEvent = {
      id: newId(),
      name: event.name,
      timestampUtc: event.timestampUtc ?? Date.now(),
      anonUserId: event.anonUserId,
      sessionId: event.sessionId,
      properties: { ...event.properties },
    };
    this.events.push(full);
  }

  getEvents(): AnalyticsEvent[] {
    return [...this.events];
  }

  clear(): void {
    this.events = [];
  }
}

export function makeAnalyticsEvent(props: {
  name: AnalyticEventName;
  anonUserId: Id;
  timestampUtc?: UtcMillis;
  sessionId?: Id;
  properties?: Record<string, unknown>;
}): Omit<AnalyticsEvent, 'id'> {
  return {
    name: props.name,
    timestampUtc: props.timestampUtc ?? Date.now(),
    anonUserId: props.anonUserId,
    sessionId: props.sessionId,
    properties: props.properties ?? {},
  };
}
