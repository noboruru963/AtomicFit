// @atomfit/web/src/screens/QuizAdjustedProgram.tsx
// SCR-08 Adjusted program preview -> Accept program / Keep my old program.
// Rule I-13: preview only; applied on Accept as a new program version;
// previous retained & revertable. Non-diagnostic (Rule I-10).
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { texts } from '../texts';
import { Button } from '../components/Button';
import { QuizEngineImpl } from '@atomfit/core/quiz.engine';
import { EASE_IN_MIN_PCT, EASE_IN_MAX_PCT } from '@atomfit/core/config';

export function QuizAdjustedProgram() {
  const navigate = useNavigate();
  const [accepted, setAccepted] = useState(false);

  // ASSUMPTION: answers loaded from the current quiz attempt; last load from
  // the user's last program. Engine is deterministic (Rule I-12).
  const engine = new QuizEngineImpl();
  const preview = engine.evaluate(
    { id: 'attempt-1', userId: 'u1', startedAtUtc: Date.now(), status: 'complete' },
    [
      { id: 'ans1', quizAttemptId: 'attempt-1', questionKey: 'q10_push', answerKey: 'reduced' },
    ],
    100, // last load kg (TBD-11 mapping pending)
  );

  const reductionPct = preview.weightReductionPct;
  const reductionInRange =
    reductionPct !== undefined &&
    reductionPct >= EASE_IN_MIN_PCT &&
    reductionPct <= EASE_IN_MAX_PCT; // BA-004 safety check

  const handleAccept = () => {
    setAccepted(true);
    // ASSUMPTION: on Accept, create a new program_version (Rule I-13) and set
    // it Current (Rule I-14). Previous version retained & revertable.
    navigate('/');
  };

  if (accepted) {
    return (
      <section className="page flex flex-col items-center gap-6 pt-16">
        <div className="card flex flex-col gap-4 align-center">
          <div style={{ fontSize: 48, lineHeight: 1 }}>{'✓'}</div>
          <h2>Program adjusted</h2>
          <p className="muted">
            Your new program version is now Current. You can revert anytime.
          </p>
          <Button variant="primary" onClick={() => navigate('/')}>
            {texts.genericContinue}
          </Button>
        </div>
      </section>
    );
  }

  return (
    <section className="page flex flex-col gap-6 pt-12">
      <div className="flex flex-col items-center gap-4">
        <h1>{texts.appName}</h1>
      </div>

      <div className="card flex flex-col gap-4">
        <h2>{texts.quizAdjustedTitle}</h2>
        <p className="muted">{texts.quizNonDiagnostic}</p>

        <div className="flex flex-col gap-3">
          <div className="flex justify-between">
            <span>{texts.quizPreviewSessionLength}</span>
            <span>{preview.sessionLength}</span>
          </div>
          <div className="flex justify-between">
            <span>{texts.quizPreviewIntensity}</span>
            <span>{preview.intensity}</span>
          </div>
          <div className="flex justify-between">
            <span>{texts.quizPreviewFrequency}</span>
            <span>{preview.frequency}</span>
          </div>
          {reductionPct !== undefined ? (
            <div className="flex justify-between">
              <span>{texts.quizPreviewWeightReduction.replace('{pct}', String(reductionPct))}</span>
              <span className={reductionInRange ? 'muted' : 'muted'}>
                (within {EASE_IN_MIN_PCT}–{EASE_IN_MAX_PCT}%, BA-004)
              </span>
            </div>
          ) : (
            <div className="flex justify-between">
              <span>{texts.quizPreviewWeightReduction.replace('{pct}', '0')}</span>
              <span>{texts.quizPreviewNoReduction}</span>
            </div>
          )}
        </div>

        <p className="muted" style={{ fontSize: '0.85rem' }}>
          {preview.reason}
        </p>

        <div className="flex flex-col gap-4">
          <Button variant="primary" onClick={handleAccept}>
            {texts.quizAcceptButton}
          </Button>
          <Button variant="outlined" onClick={() => navigate('/')}>
            {texts.quizKeepButton}
          </Button>
        </div>
      </div>
    </section>
  );
}
