// @atomfit/web/src/screens/Discover.tsx
// SCR-17 Discover / Explore exercise. Cards with name, short description, add (+).
// Initial catalogue >= Barbell shoulder press, Dumbbell shoulder press, Inverted plank,
// Dumbbell curl, Chest press, Tricep raise, Lateral pushdown (Section 8.7).
import { useState } from 'react';
import { texts } from '../texts';
import { Button } from '../components/Button';

type Exercise = { id: string; name: string; description: string };

const CATALOGUE: Exercise[] = [
  { id: 'e1', name: 'Barbell shoulder press', description: 'Overhead press with a barbell. Stand or seated.' },
  { id: 'e2', name: 'Dumbbell shoulder press', description: 'Seated or standing dumbbell press.' },
  { id: 'e3', name: 'Inverted plank', description: 'Reverse plank targeting posterior chain.' },
  { id: 'e4', name: 'Dumbbell curl', description: 'Bicep curl with dumbbells.' },
  { id: 'e5', name: 'Chest press', description: 'Bench or floor chest press.' },
  { id: 'e6', name: 'Tricep raise', description: 'Triceps extension.' },
  { id: 'e7', name: 'Lateral pushdown', description: 'Cable or band lateral pushdown.' },
];

export function Discover() {
  const [search, setSearch] = useState('');
  const [added, setAdded] = useState<Set<string>>(new Set());

  const filtered = CATALOGUE.filter((e) =>
    e.name.toLowerCase().includes(search.toLowerCase()),
  );

  const handleAdd = (id: string) => {
    setAdded((prev) => {
      const next = new Set(prev);
      next.add(id);
      return next;
    });
  };

  return (
    <div className="page flex flex-col gap-6 pt-12">
      <h2>{texts.discoverTitle}</h2>

      <div className="flex flex-col gap-4">
        <div className="flex flex-col gap-3">
          <label style={{ fontSize: '0.85rem', fontWeight: 700 }}>{texts.discoverSearch ?? texts.discoverExplore}</label>
          <input
            type="search"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            aria-label="Search exercises"
            placeholder="Search exercises"
          />
        </div>

        <div className="flex flex-col gap-3">
          {filtered.map((ex) => {
            const isAdded = added.has(ex.id);
            return (
              <div key={ex.id} className="card p-4 flex items-center justify-between gap-4">
                <div className="flex flex-col gap-1">
                  <span style={{ fontWeight: 700 }}>{ex.name}</span>
                  <span className="muted" style={{ fontSize: '0.85rem' }}>{ex.description}</span>
                </div>
                <Button
                  variant={isAdded ? 'secondary' : 'outlined'}
                  size="small"
                  onClick={() => handleAdd(ex.id)}
                  disabled={isAdded}
                >
                  {isAdded ? 'Added' : texts.discoverAdd}
                </Button>
              </div>
            );
          })}
          {filtered.length === 0 && (
            <p className="muted text-center" style={{ padding: 24 }}>No exercises match.</p>
          )}
        </div>
      </div>

      <p className="muted text-center" style={{ fontSize: '0.8rem' }}>
        From an active workout, "Add another exercise?" adds to the workout.
        Catalogue content TBD-20.
      </p>
    </div>
  );
}
