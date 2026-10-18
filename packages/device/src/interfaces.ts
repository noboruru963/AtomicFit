// @atomfit/device/src/interfaces.ts
// Adapter interfaces defined in core's spirit (implemented here, consumed by apps/web).
// Rule I-19: if sensors/mic/lock-screen are unavailable or permission denied, degrade
// gracefully — keep manual logging fully available.

import type { Id } from '@atomfit/core';

export interface MotionSample {
  timestamp: number;
  acceleration: { x: number; y: number; z: number };
  rotation: { alpha: number; beta: number; gamma: number };
}

export interface SensorAdapter {
  isAvailable(): Promise<boolean>;
  // Explain permission before the OS prompt (Rule I-25 / NFR-041).
  requestPermission(): Promise<boolean>;
  start(onSample: (sample: MotionSample) => void): Promise<void>;
  stop(): Promise<void>;
}

export interface SpeechAdapter {
  isAvailable(): Promise<boolean>;
  requestPermission(): Promise<boolean>;
  startListening(onResult: (transcript: string, isFinal: boolean) => void): Promise<void>;
  stopListening(): Promise<void>;
}

export interface VibrationAdapter {
  vibrate(ms: number): void;
}

export interface LockScreenAdapter {
  isSupported(): Promise<boolean>;
  registerQuickAdd(onAddRep: () => void, onAddSet: () => void): Promise<void>;
  unregister(): Promise<void>;
}

export interface DeviceAdapters {
  sensor: SensorAdapter;
  speech: SpeechAdapter;
  vibration: VibrationAdapter;
  lockScreen: LockScreenAdapter;
}
