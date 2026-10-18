// @atomfit/device/__tests__/fakes.test.ts
import { describe, it, expect } from 'vitest';
import {
  fakeSensor,
  fakeSpeech,
  fakeVibration,
  fakeLockScreen,
  smooth,
  countPeaks,
} from '../src/fakes';

describe('device fakes', () => {
  it('sensor unavailable by default -> graceful degradation (Rule I-19)', async () => {
    expect(await fakeSensor.isAvailable()).toBe(false);
    expect(await fakeSensor.requestPermission()).toBe(false);
  });

  it('speech unavailable by default -> nothing saved on unparseable input (Rule I-18)', async () => {
    expect(await fakeSpeech.isAvailable()).toBe(false);
    await fakeSpeech.startListening(() => {});
    await fakeSpeech.stopListening();
  });

  it('vibration is a safe no-op', () => {
    expect(() => fakeVibration.vibrate(300)).not.toThrow();
  });

  it('lock screen unsupported -> best-effort only (BA-005)', async () => {
    expect(await fakeLockScreen.isSupported()).toBe(false);
    await fakeLockScreen.registerQuickAdd(() => {}, () => {});
    await fakeLockScreen.unregister();
  });

  it('smooth reduces noise', () => {
    expect(smooth([1, 2, 3, 4, 5], 3)).toEqual([1.5, 2, 3, 4, 4.5]);
  });

  it('countPeaks counts threshold crossings with min interval', () => {
    const signal = [0, 1, 5, 1, 0, 0, 1, 5, 1, 0];
    expect(countPeaks(signal, 3, 0, 10)).toBe(2);
  });
});
