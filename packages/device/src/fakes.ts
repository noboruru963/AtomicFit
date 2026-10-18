// @atomfit/device/src/fakes.ts
// Fake (no-op) adapters for tests and for environments where the real APIs
// are unavailable. Real adapters swap in here (Section 6.3).
import type {
  SensorAdapter,
  SpeechAdapter,
  VibrationAdapter,
  LockScreenAdapter,
  MotionSample,
} from './interfaces';

export const fakeSensor: SensorAdapter = {
  isAvailable: () => Promise.resolve(false),
  requestPermission: () => Promise.resolve(false),
  start: () => Promise.resolve(),
  stop: () => Promise.resolve(),
};

export const fakeSpeech: SpeechAdapter = {
  isAvailable: () => Promise.resolve(false),
  requestPermission: () => Promise.resolve(false),
  startListening: () => Promise.resolve(),
  stopListening: () => Promise.resolve(),
};

export const fakeVibration: VibrationAdapter = {
  vibrate: () => {
    // no-op
  },
};

export const fakeLockScreen: LockScreenAdapter = {
  isSupported: () => Promise.resolve(false),
  registerQuickAdd: () => Promise.resolve(),
  unregister: () => Promise.resolve(),
};

export function makeFakeDevices() {
  return {
    sensor: fakeSensor,
    speech: fakeSpeech,
    vibration: fakeVibration,
    lockScreen: fakeLockScreen,
  };
}

// Sensor signal processing helpers (Section 6.3: smoothing -> peak detection -> count).
// Parameters are per-exercise config objects (TBD-08 defines supported exercises).
export function smooth(samples: number[], window = 5): number[] {
  if (samples.length === 0) return [];
  const out: number[] = [];
  const half = Math.floor(window / 2);
  for (let i = 0; i < samples.length; i++) {
    let sum = 0;
    let count = 0;
    for (let j = Math.max(0, i - half); j <= Math.min(samples.length - 1, i + half); j++) {
      sum += samples[j];
      count++;
    }
    out[i] = sum / count;
  }
  return out;
}

export function countPeaks(
  signal: number[],
  threshold: number,
  minIntervalMs: number,
  sampleIntervalMs: number,
): number {
  let count = 0;
  let lastPeakIndex = -Infinity;
  const minIntervalSamples = Math.ceil(minIntervalMs / sampleIntervalMs);
  for (let i = 1; i < signal.length - 1; i++) {
    if (
      signal[i] > threshold &&
      signal[i] > signal[i - 1] &&
      signal[i] > signal[i + 1] &&
      i - lastPeakIndex >= minIntervalSamples
    ) {
      count++;
      lastPeakIndex = i;
    }
  }
  return count;
}
