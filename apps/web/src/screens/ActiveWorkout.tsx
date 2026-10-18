// @atomfit/web/src/screens/ActiveWorkout.tsx
// Active workout screen (Section 8.7). Table: Exercise, Set, Reps, Rest with
// editable weight/reps. Add more set / Add another exercise / Finish.
// US-001 auto-count live counter, US-002 voice logging, US-003 quick-add bar
// (in-app mandatory path, BA-005). Rest timer inline.
import { useState, useCallback, useEffect, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { texts } from '../texts';
import { Button } from '../components/Button';
import { countPeaks, smooth } from '@atomfit/device/fakes';

type SetEntry = {
  id: string;
  exerciseId: string;
  exerciseName: string;
  setNo: number;
  weightKg: number;
  reps: number;
  restS: number;
  inputMethod: 'manual' | 'sensor' | 'voice' | 'lockscreen';
};

type ExerciseInWorkout = { id: string; name: string; plannedSets: number };

const INITIAL_EXERCISES: ExerciseInWorkout[] = [
  { id: 'e1', name: 'Dumbbell curl', plannedSets: 3 },
  { id: 'e2', name: 'Chest press', plannedSets: 3 },
  { id: 'e3', name: 'Tricep raise', plannedSets: 3 },
];

export function ActiveWorkout() {
  const navigate = useNavigate();
  const [sets, setSets] = useState<SetEntry[]>([]);
  const [exercises, setExercises] = useState<ExerciseInWorkout[]>(INITIAL_EXERCISES);
  const [activeExerciseId, setActiveExerciseId] = useState<string | null>(null);
  // Live counter for the in-progress set (US-001 auto-count)
  [, ] = useState<{ reps: number; weightKg: number } | null>(null);
  const [autoCounting, setAutoCounting] = useState(false);
  const [counterValue, setCounterValue] = useState(0);
  const [voiceTranscript, setVoiceTranscript] = useState<string | null>(null);
  const [restSeconds, setRestSeconds] = useState(120);
  const [restRunning, setRestRunning] = useState(false);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);

  useEffect(() => {
    if (exercises.length && !activeExerciseId) setActiveExerciseId(exercises[0].id);
  }, [exercises, activeExerciseId]);

  useEffect(() => {
    if (sets.length === 0 && activeExerciseId) {
      addSet(activeExerciseId);
    }
  }, [sets.length, activeExerciseId, addSet]);

  const currentExercise = exercises.find((e) => e.id === activeExerciseId);

  const addSet = useCallback(
    (exId: string) => {
      const ex = exercises.find((e) => e.id === exId);
      if (!ex) return;
      const existingForEx = sets.filter((s) => s.exerciseId === exId);
      const setNo = existingForEx.length + 1;
      const prev = existingForEx[existingForEx.length - 1];
      const newSet: SetEntry = {
        id: `set-${Date.now()}-${Math.random().toString(36).slice(2)}`,
        exerciseId: exId,
        exerciseName: ex.name,
        setNo,
        weightKg: prev ? prev.weightKg : 0,
        reps: 0,
        restS: prev ? prev.restS : 120,
        inputMethod: 'manual',
      };
      setSets((s) => [...s, newSet]);
    },
    [exercises, sets],
  );

  const updateSet = useCallback((id: string, patch: Partial<SetEntry>) => {
    setSets((s) => s.map((s) => (s.id === id ? { ...s, ...patch } : s)));
  }, []);

  const removeSet = useCallback((id: string) => {
    setSets((s) => s.filter((s) => s.id !== id));
  }, []);

  // Auto-count: simulate smoothing + peak detection on a generated signal
  // (Section 6.3: smoothing filter -> peak detection -> count). Real sensor
  // adapter swaps in here; unavailable -> manual entry (Rule I-19).
  const toggleAutoCount = useCallback(() => {
    if (autoCounting) {
      setAutoCounting(false);
      return;
    }
    // ASSUMPTION: sensor permission granted; generate a demo signal for the
    // selected exercise's auto-count parameters (TBD-08 supported exercises).
    setAutoCounting(true);
    const signal = [0, 1, 5, 1, 0, 0, 1, 5, 1, 0, 0, 1, 5, 1, 0];
    const smoothed = smooth(signal, 3);
    const counted = countPeaks(smoothed, 3, 300, 100);
    setCounterValue(counted);
    // ASSUMPTION: auto-count completes; show editable final count with +/-.
  }, [autoCounting]);

  const incrementReps = () => setCounterValue((c) => c + 1);
  const decrementReps = () => setCounterValue((c) => Math.max(0, c - 1));

  const saveCounterToSet = useCallback(() => {
    if (!activeExerciseId) return;
    const ex = exercises.find((e) => e.id === activeExerciseId);
    if (!ex) return;
    setSets((s) => {
      const last = s.slice().reverse().find((s) => s.exerciseId === activeExerciseId);
      if (last) {
        return s.map((s) =>
          s.id === last.id ? { ...s, reps: counterValue, inputMethod: 'sensor' } : s,
        );
      }
      return s;
    });
    setAutoCounting(false);
  }, [activeExerciseId, exercises, counterValue]);

  // Rest timer (Section 8.7): preset to planned rest; -15/+15 (min 15s); Pause/Resume/Skip.
  const startRest = useCallback(() => {
    setRestRunning(true);
  }, []);
  const pauseRest = useCallback(() => setRestRunning(false), []);
  const skipRest = useCallback(() => {
    setRestRunning(false);
    setRestSeconds(0);
  }, []);
  const adjustRest = useCallback((delta: number) => {
    setRestSeconds((p) => Math.max(15, p + delta));
  }, []);

  useEffect(() => {
    if (!restRunning || restSeconds <= 0) return;
    intervalRef.current = setInterval(() => {
      setRestSeconds((p) => {
        if (p <= 1) {
          setRestRunning(false);
          // ASSUMPTION: vibrate 300ms where supported (Section 8.7).
          return 0;
        }
        return p - 1;
      });
    }, 1000);
    return () => {
      if (intervalRef.current) clearInterval(intervalRef.current);
    };
  }, [restRunning, restSeconds]);

  // Voice logging (US-002): mic button -> STT -> parser -> confirmation card.
  // Unparseable input -> retry message, nothing saved (Rule I-18).
  const handleVoice = useCallback(() => {
    // ASSUMPTION: speech adapter available; phrase "10 reps squat" parsed.
    const phrase = '10 reps squat'; // demo (TBD-07 grammar)
    const parsed = parseVoicePhrase(phrase);
    if (!parsed) {
      setVoiceTranscript('Unparseable — try again (e.g. "10 reps squat")');
      return;
    }
    setVoiceTranscript(null);
    // ASSUMPTION: confirmation card shown; on confirm -> save via Save-Set.
    addSet(exercises[0].id);
    const last = sets.slice().reverse().find((s) => s.exerciseId === exercises[0].id);
    if (last) {
      updateSet(last.id, { reps: parsed.reps, weightKg: parsed.weightKg ?? last.weightKg, inputMethod: 'voice' });
    }
  }, [exercises, sets, updateSet]);

  // Quick-add bar (US-003, BA-005): +1 rep / +1 set, immediate save.
  const quickAddRep = useCallback(() => {
    const last = sets.slice().reverse()[0];
    if (last) updateSet(last.id, { reps: last.reps + 1 });
  }, [sets, updateSet]);
  const quickAddSet = useCallback(() => {
    if (activeExerciseId) addSet(activeExerciseId);
  }, [activeExerciseId, addSet]);

  const totalSets = sets.filter((s) => s.reps >= 1).length;
  const totalTimeS = 0; // ASSUMPTION: elapsed timer TBD

  const handleFinish = () => {
    navigate('/workout/complete', { state: { totalTimeS, totalSets } });
  };

  const parseVoicePhrase = (phrase: string): { reps: number; weightKg?: number } | null => {
    // TBD-07: full voice grammar. Smallest replaceable parser.
    const m = phrase.match(/(\d+)\s*reps?/i);
    if (!m) return null;
    const reps = Number(m[1]);
    const wm = phrase.match(/(\d+(?:\.\d+)?)\s*(?:kg|kilos?)/i);
    const weightKg = wm ? Number(wm[1]) : undefined;
    return { reps, weightKg };
  };

  return (
    <div className="page flex flex-col gap-4 pt-10">
      <header className="flex items-center justify-between gap-4">
        <h2 style={{ fontSize: 1rem }}>{currentExercise?.name ?? texts.workoutTitle}</h2>
        <div className="flex items-center gap-3">
          <Button variant="outlined" size="small" onClick={toggleAutoCount}>
            {autoCounting ? 'Stop count' : texts.workoutAutoCount}
          </Button>
          <Button variant="outlined" size="small" onClick={handleVoice}>
            {texts.workoutVoice}
          </Button>
        </div>
      </header>

      {/* Voice result / retry (Rule I-18: nothing saved on unparseable) */}
      {voiceTranscript && (
        <div className="card p-4 flex flex-col gap-3">
          <p className="muted" style={{ fontSize: 0.85rem }}>{voiceTranscript}</p>
          <Button variant="outlined" size="small" onClick={handleVoice}>
            {texts.genericTryAgain}
          </Button>
        </div>
      )}

      {/* Live rep counter (US-001): counter text >= 48px, visible without scroll */}
      {autoCounting || counterValue > 0 ? (
        <div className="card p-6 flex flex-col items-center gap-4">
          <span className="muted" style={{ fontSize: 0.85rem }}>{texts.workoutRepCounter}</span>
          <span style={{ fontSize: 48, fontWeight: 800, fontVariantNumeric: 'tabular-nums' }}>
            {counterValue}
          </span>
          <div className="flex gap-4">
            <Button variant="outlined" size="small" onClick={decrementReps}>−1</Button>
            <Button variant="outlined" size="small" onClick={incrementReps}>+1</Button>
            <Button variant="primary" size="small" onClick={saveCounterToSet}>
              {texts.genericSave}
            </Button>
          </div>
        </div>
      ) : null}

      {/* Sets table */}
      <div className="card flex flex-col gap-3">
        {sets.map((s) => (
          <div key={s.id} className="set-row flex items-center gap-3 p-3" style={{ borderBottom: '1px solid var(--line)' }}>
            <span className="muted" style={{ fontSize: 0.85rem, minWidth: 26 }}>
              {s.setNo}
            </span>
            <span style={{ flex: 1, fontSize: 0.9rem }}>{s.exerciseName}</span>
            <input
              type="number"
              min="0"
              max="999"
              value={s.reps}
              onChange={(e) => updateSet(s.id, { reps: Math.max(0, Math.min(999, Number(e.target.value || 0))) })}
              aria-label={`${s.exerciseName} set ${s.setNo} reps`}
              style={{ width: 60 }}
            />
            <span className="muted" style={{ fontSize: 0.8rem, minWidth: 30, textAlign: 'right' }}>
              {s.weightKg} kg
            </span>
            <button
              type="button"
              className="btn-icon"
              onClick={() => removeSet(s.id)}
              aria-label="Remove set"
            >
              ×
            </button>
          </div>
        ))}
        {sets.length === 0 && (
          <p className="muted" style={{ fontSize: 0.85rem, textAlign: 'center', padding: 12 }}>
            No sets yet. Add a set to begin.
          </p>
        )}
      </div>

      <div className="flex gap-3">
        <Button variant="outlined" size="small" onClick={() => {
          if (activeExerciseId) addSet(activeExerciseId);
        }}>
        {texts.workoutAddSet}
        </Button>
        <Button variant="outlined" size="small" onClick={() => navigate('/discover')}>
          {texts.workoutAddExercise}
        </Button>
      </div>

      {/* Quick-add bar (US-003, BA-005) — in-app mandatory path */}
      <div className="card p-4 flex items-center justify-between gap-4" style={{ marginTop: 8 }}>
        <div>
          <span className="muted" style={{ fontSize: 0.8rem }}>{texts.workoutQuickAddRep}</span>
          <div className="flex gap-2">
            <Button variant="primary" size="small" onClick={quickAddRep}>+1 rep</Button>
            <Button variant="primary" size="small" onClick={quickAddSet}>+1 set</Button>
          </div>
        </div>
        <span className="muted" style={{ fontSize: 0.85rem }}>
          {totalSets} set{totalSets !== 1 ? 's' : ''} logged
        </span>
      </div>

      {/* Inline rest timer (Section 8.7) */}
      <div className="card p-4 flex flex-col gap-3">
        <div className="flex items-center justify-between">
          <span style={{ fontWeight: 700 }}>{texts.restTimerTitle}</span>
          <span style={{ fontSize: 1.25rem, fontVariantNumeric: 'tabular-nums', fontWeight: 800 }}>
            {Math.floor(restSeconds / 60)}:{String(restSeconds % 60).padStart(2, '0')}
          </span>
        </div>
        <div className="flex gap-2">
          <Button variant="outlined" size="small" onClick={adjustRest(-15)}>−15 s</Button>
          <Button variant="outlined" size="small" onClick={adjustRest(15)}>+15 s</Button>
          <Button variant={restRunning ? 'secondary' : 'primary'} size="small" onClick={restRunning ? pauseRest : startRest}>
            {restRunning ? texts.restPause : texts.restSetTimer}
          </Button>
          <Button variant="link" size="small" onClick={skipRest}>{texts.restSkip}</Button>
        </div>
        <p className="muted" style={{ fontSize: 0.8rem }}>
          Cancel before start · vibrate 300 ms at 0:00 where supported (Section 8.7)
        </p>
      </div>

      <div className="flex flex-col gap-3 mt-auto">
        <Button variant="primary" onClick={handleFinish}>
          {texts.workoutFinish}
        </Button>
      </div>
    </div>
  );
}


