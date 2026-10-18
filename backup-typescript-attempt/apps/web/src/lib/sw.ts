// @atomfit/web/src/lib/sw.ts
// Best-effort service worker helpers (PWA, Rule I-09 / BA-005).
// Lock-screen quick-add via notification is best-effort; in-app bar is mandatory (Section 8.3).

export function registerSW(): void {
  if (typeof navigator === 'undefined' || !('serviceWorker' in navigator)) return;
  void navigator.serviceWorker.register('/sw.js').catch((err) => {
    console.warn('[AtomFit] SW registration failed:', err);
  });
}

export function isSWReady(): boolean {
  return typeof navigator !== 'undefined' && 'serviceWorker' in navigator;
}

export type QuickAddAction = 'add-rep' | 'add-set';

export interface QuickAddHandlers {
  onAddRep: () => void;
  onAddSet: () => void;
}

export function registerQuickAddNotification(handlers: QuickAddHandlers): void {
  if (typeof navigator === 'undefined' || !('serviceWorker' in navigator)) return;
  // Best-effort: request notification permission only if supported.
  if (typeof Notification === 'undefined') return;
  if (Notification.permission === 'granted') {
    return;
  }
  // Do not prompt silently; the app explains before any prompt (Rule I-25).
  void Notification.requestPermission().catch(() => {
    // Denied — fall back to in-app quick-add bar (Rule I-19).
  });
}
