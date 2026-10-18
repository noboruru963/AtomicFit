// @atomfit/web/src/screens/QuizPrompt.tsx
// SCR-05 Quiz prompt. "Let's restart at your pace" — Start quiz / Not now.
// Shown on app open when inactive 7+ local days (BA-004). Non-diagnostic (Rule I-10).
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { texts } from '../texts';
import { Button } from '../components/Button';

export function QuizPrompt() {
  const navigate = useNavigate();
  const [dismissed, setDismissed] = useState(false);

  if (dismissed) return null;

  return (
    <section className="page flex flex-col gap-6 pt-16">
      <div className="flex flex-col items-center gap-4">
        <h1>{texts.appName}</h1>
      </div>

      <div className="card flex flex-col gap-4">
        <h2>{texts.quizPromptTitle}</h2>
        <p>{texts.quizPromptBody}</p>
        {/* Non-diagnostic statement on every quiz screen (Rule I-10, FR-088) */}
        <p className="muted" style={{ fontSize: '0.8rem' }}>
          {texts.quizNonDiagnostic}
        </p>
        <div className="flex flex-col gap-4">
          <Button variant="primary" onClick={() => navigate('/quiz/question/1')}>
            {texts.quizStartButton}
          </Button>
          <Button variant="outlined" onClick={() => setDismissed(true)}>
            {texts.quizNotNowButton}
          </Button>
        </div>
      </div>
    </section>
  );
}
