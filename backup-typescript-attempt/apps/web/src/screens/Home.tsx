// @atomfit/web/src/screens/Home.tsx
// SCR-03 Home. Welcome back, calendar, monthly count, Continue last workout,
// Empty workout, My programs, quiz entry. Bottom nav Home highlighted/unclickable (BA-001).
import { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { texts, t } from '../texts';
import { Button } from '../components/Button';

export function Home() {
  const navigate = useNavigate();
  const [username] = useState('Alex'); // ASSUMPTION: from local account after login
  const [monthlyCount, setMonthlyCount] = useState(0);
  const [hasUnfinished, setHasUnfinished] = useState(false);

  useEffect(() => {
    // ASSUMPTION: load from local storage layer. TBD-15: none-exists behavior.
    setMonthlyCount(3);
    setHasUnfinished(false);
  }, []);

  const currentMonth = new Date().toLocaleDateString(undefined, { month: 'long', year: 'numeric' });

  return (
    <div className="page flex flex-col gap-6 pt-12">
      <div className="flex flex-col gap-2">
        <h1>{t('homeWelcome', { name: username })}</h1>
        <p className="muted">{texts.tagline}</p>
      </div>

      {/* Quiz entry control (US-004) — shown when inactive for 7+ days */}
      <section className="card flex flex-col gap-4">
        <div className="flex items-center justify-between gap-4">
          <h2 style={{ fontSize: '0.95rem' }}>{texts.homeQuizEntry}</h2>
        </div>
        <p className="muted" style={{ fontSize: '0.85rem' }}>
          Short non-diagnostic quiz to adjust your program to your pace.
        </p>
        <Button variant="outlined" onClick={() => navigate('/quiz/prompt')}>
          {texts.quizStartButton}
        </Button>
      </section>

      {/* Calendar + monthly count */}
      <section className="card flex flex-col gap-4">
        <div className="flex items-center justify-between gap-4">
          <h2 style={{ fontSize: '0.95rem' }}>{t('homeCalendarMonth')}</h2>
          <div className="flex items-center gap-3">
            <span className="badge">{monthlyCount}</span>
            <span className="muted" style={{ fontSize: '0.85rem' }}>
              {t('homeMonthlyCount')}
            </span>
          </div>
        </div>
        <div className="calendar" style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: 4 }}>
          {['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((d) => (
            <div key={d} className="muted" style={{ fontSize: '0.75rem', textAlign: 'center' }}>
              {d}
            </div>
          ))}
          {[...Array(31)].map((_, i) => {
            const day = i + 1;
            const today = new Date().getDate() === day;
            return (
              <div
                key={day}
                className="calendar-day"
                style={{
                  aspectRatio: 1,
                  border: '1px solid var(--line)',
                  borderRadius: 8,
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  fontSize: '0.85rem',
                  background: today ? 'var(--primary-light)' : 'transparent',
                  color: today ? 'var(--primary-dark)' : 'var(--text)',
                  fontWeight: today ? 800 : 400,
                }}
              >
                {day}
              </div>
            );
          })}
        </div>
        <p className="muted" style={{ fontSize: '0.8rem' }}>
          {currentMonth} · days with completed workouts are marked
        </p>
      </section>

      {/* Actions */}
      <section className="flex flex-col gap-4">
        {hasUnfinished ? (
          <Button variant="primary" onClick={() => navigate('/workout/active')}>
            {t('homeContinueLast')}
          </Button>
        ) : (
          <Button variant="outlined" disabled>
            {t('homeContinueNone')}
          </Button>
        )}
        <Button variant="primary" onClick={() => navigate('/workout/active')}>
          {texts.homeEmptyWorkout}
        </Button>
        <Button variant="outlined" onClick={() => navigate('/programs')}>
          {texts.homeMyPrograms}
        </Button>
      </section>

      <p className="muted text-center" style={{ fontSize: '0.8rem' }}>
        {texts.homeNoWorkoutsYet}
      </p>
    </div>
  );
}
