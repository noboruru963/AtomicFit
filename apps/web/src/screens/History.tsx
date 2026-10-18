// @atomfit/web/src/screens/History.tsx
// SCR-16 History. Reverse-chronological; case-insensitive search by program name;
// filters All/Full/Micro; Micro badge; stitched badge; detail; delete with
// confirmation (Rule I-17); unstitch (Rule I-16).
import { useState } from 'react';
import { texts } from '../texts';
import { Button } from '../components/Button';

type Session = {
  id: string;
  name: string;
  type: 'full' | 'micro' | 'stitched';
  status: 'complete' | 'incomplete';
  date: string;
  reps: number;
  volumeKg: number;
  children?: number;
};

const MOCK_SESSIONS: Session[] = [
  { id: 's1', name: 'Push Pull Leg', type: 'full', status: 'complete', date: '2026-10-18 17:30', reps: 30, volumeKg: 600 },
  { id: 's2', name: 'Empty program', type: 'micro', status: 'incomplete', date: '2026-10-17 08:15', reps: 12, volumeKg: 240 },
  { id: 's3', name: 'Upper Lower', type: 'stitched', status: 'complete', date: '2026-10-15 19:00', reps: 45, volumeKg: 900, children: 2 },
  { id: 's4', name: 'Push Pull Leg', type: 'full', status: 'complete', date: '2026-10-12 10:00', reps: 28, volumeKg: 560 },
];

export function History() {
  const [search, setSearch] = useState('');
  const [filter, setFilter] = useState<'All' | 'Full' | 'Micro'>('All');
  const [deleteId, setDeleteId] = useState<string | null>(null);

  const filtered = MOCK_SESSIONS.filter((s) => {
    const match = s.name.toLowerCase().includes(search.toLowerCase());
    const typeMatch =
      filter === 'All' ||
      (filter === 'Full' && s.type === 'full') ||
      (filter === 'Micro' && s.type === 'micro');
    return match && typeMatch;
  });

  const handleDelete = (id: string) => {
    if (!window.confirm(texts.historyDeleteConfirm)) return;
    // ASSUMPTION: delete via storage; rejecting if referenced by a stitch parent
    // names the parent (NFR-020).
    setDeleteId(null);
  };

  return (
    <div className="page flex flex-col gap-6 pt-12">
      <h2>{texts.historyTitle}</h2>

      <div className="flex flex-col gap-4">
        <div className="flex flex-col gap-3">
          <label style={{ fontSize: 0.85rem, fontWeight: 700 }}>{texts.historySearch}</label>
          <input
            type="search"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            aria-label={texts.historySearch}
            placeholder="Search by program name"
          />
        </div>

        <div className="flex gap-3">
          {['All', 'Full', 'Micro'] as const.map((f) => (
            <button
              key={f}
              type="button"
              role="radio"
              aria-checked={filter === f}
              onClick={() => setFilter(f)}
              className={`pill ${filter === f ? 'pill micro' : 'pill'}`}
            >
              {f === 'All' ? texts.historyFilterAll : f === 'Full' ? texts.historyFilterFull : texts.historyFilterMicro}
            </button>
          ))}
        </div>

        {filtered.length === 0 ? (
          <p className="muted text-center" style={{ padding: 24 }}>{texts.historyNoWorkoutsFound}</p>
        ) : (
          <div className="flex flex-col gap-3">
            {filtered.map((s) => (
              <div key={s.id} className="card p-4 flex items-center justify-between gap-4">
                <div className="flex flex-col gap-1">
                  <div className="flex items-center gap-3">
                    <span style={{ fontWeight: 700 }}>{s.name}</span>
                    {s.type === 'micro' && <span className="pill micro">{texts.historyMicroBadge}</span>}
                    {s.type === 'stitched' && <span className="pill stitched">{texts.historyStitchedBadge}</span>}
                    {s.children && <span className="badge">{s.children} sessions</span>}
                  </div>
                  <span className="muted" style={{ fontSize: 0.8rem }}>
                    {s.date} · {s.reps} reps · {s.volumeKg} kg volume
                  </span>
                </div>
                <div className="flex gap-2">
                  <Button variant="link" size="small" onClick={() => {}}>
                    {texts.historyDetail}
                  </Button>
                  {deleteId === s.id ? (
                    <Button variant="danger" size="small" onClick={() => handleDelete(s.id)}>
                      {texts.genericDelete}
                    </Button>
                  ) : (
                    <Button variant="link" size="small" onClick={() => setDeleteId(s.id)}>
                      {texts.genericDelete}
                    </Button>
                  )}
                  {s.type === 'stitched' && (
                    <Button variant="link" size="small" onClick={() => {}}>
                      {texts.historyUnstitch}
                    </Button>
                  )}
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
