// @atomfit/web/src/screens/WorkoutComplete.tsx
// SCR-?? Workout completed. Total Time mm:ss, Total Sets, then Go to home page (Section 8.7).
import { useNavigate, useLocation } from 'react-router-dom';
import { texts } from '../texts';
import { Button } from '../components/Button';

type LocationState = { totalTimeS?: number; totalSets?: number };

export function WorkoutComplete() {
  const navigate = useNavigate();
  const location = useLocation<LocationState>();
  const state = location.state ?? {};
  const totalTimeS = state.totalTimeS ?? 0;
  const totalSets = state.totalSets ?? 0;
  const minutes = Math.floor(totalTimeS / 60);
  const seconds = totalTimeS % 60;

  return (
    <section className="page flex flex-col items-center gap-6 pt-16">
      <div className="card flex flex-col items-center gap-6 p-24">
        <div style={{ fontSize: 48, lineHeight: 1, fontWeight: 800 }}>{'✓'}</div>
        <h2>{texts.completeTitle}</h2>
        <div className="flex gap-12 text-center">
          <div className="flex flex-col">
            <span className="muted" style={{ fontSize: 0.85rem }}>{texts.completeTotalTime}</span>
            <span style={{ fontSize: 1.5rem, fontWeight: 800 }}>
              {minutes.toString().padStart(2, '0')}:{seconds.toString().padStart(2, '0')}
            </span>
          </div>
          <div className="flex flex-col">
            <span className="muted" style={{ fontSize: 0.85rem }}>{texts.completeTotalSets}</span>
            <span style={{ fontSize: 1.5rem, fontWeight: 800 }}>{totalSets}</span>
          </div>
        </div>
        <p className="muted" style={{ fontSize: 0.85rem, textAlign: 'center' }}>
          Every rep counts. Saved to your history.
        </p>
        <Button variant="primary" onClick={() => navigate('/')}>
          {texts.completeGoHome}
        </Button>
      </div>
    </section>
  );
}
