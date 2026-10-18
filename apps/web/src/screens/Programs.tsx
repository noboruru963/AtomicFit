// @atomfit/web/src/screens/Programs.tsx
// My programs. 3 built-ins (Upper Lower, Push Pull Leg, Gorilla Training).
// Push Pull Leg = Dumbbell curl, Chest press, Tricep raise, Lateral pushdown,
// 3 sets × 10 kg, 2:00 rest (Section 8.7). Exactly one Current (Rule I-14).
import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { texts } from '../texts';
import { Button } from '../components/Button';

type Program = { id: string; name: string; type: 'Built-in' | 'Current'; exercises: string[]; sets: number; weight: number; rest: string };

const BUILT_INS: Program[] = [
  {
    id: 'p-upper-lower',
    name: 'Upper Lower',
    type: 'Built-in',
    exercises: ['Bench press', 'Dumbbell curl', 'Chest press', 'Tricep raise'],
    sets: 3, weight: 10, rest: '2:00',
  },
  {
    id: 'p-ppl',
    name: 'Push Pull Leg',
    type: 'Built-in',
    exercises: ['Dumbbell curl', 'Chest press', 'Tricep raise', 'Lateral pushdown'],
    sets: 3, weight: 10, rest: '2:00',
  },
  {
    id: 'p-gorilla',
    name: 'Gorilla Training',
    type: 'Built-in',
    exercises: ['Dumbbell shoulder press', 'Inverted plank', 'Barbell shoulder press'],
    sets: 3, weight: 12, rest: '2:00',
  },
];

export function Programs() {
  const navigate = useNavigate();
  const [currentId, setCurrentId] = useState<string | null>('p-ppl');

  const startProgram = (id: string) => {
    setCurrentId(id);
    navigate('/workout/active');
  };

  return (
    <div className="page flex flex-col gap-6 pt-12">
      <h2>{texts.programsTitle}</h2>

      <div className="flex flex-col gap-4">
        {BUILT_INS.map((prog) => {
          const isCurrent = currentId === prog.id;
          return (
            <div key={prog.id} className="card flex flex-col gap-3">
              <div className="flex items-center justify-between gap-4">
                <div>
                  <div className="flex items-center gap-3">
                    <span style={{ fontWeight: 800 }}>{prog.name}</span>
                    <span className="pill">{prog.type}</span>
                    {isCurrent && <span className="badge">Current</span>}
                  </div>
                  <p className="muted" style={{ fontSize: '0.85rem' }}>
                    {prog.exercises.join(' · ')}
                  </p>
                </div>
                <div className="flex items-center gap-3">
                  <Button variant="outlined" size="small" onClick={() => startProgram(prog.id)}>
                    {texts.programsStart}
                  </Button>
                  {!isCurrent && (
                    <Button variant="link" size="small" onClick={() => setCurrentId(prog.id)}>
                      Set current
                    </Button>
                  )}
                </div>
              </div>
              <div className="muted" style={{ fontSize: '0.85rem' }}>
                {prog.sets} sets × {prog.weight} kg · rest {prog.rest}
              </div>
            </div>
          );
        })}
      </div>

      <p className="muted text-center" style={{ fontSize: '0.8rem' }}>
        Edits require "Confirm edit?" (Yes/Cancel). Programme content TBD-19.
      </p>
    </div>
  );
}
