// @atomfit/web/src/screens/QuizQuestion.tsx
// SCR-06 Quiz question. One per screen, progress "n/10", Next disabled until
// answered, Back from Q2. Q1 & Q10 fixed (BA-004); Q2–Q9 placeholders (TBD-10).
// Non-diagnostic statement on every screen (Rule I-10).
import { useState, useCallback } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { texts } from '../texts';
import { Button } from '../components/Button';
import { QUIZ_QUESTION_COUNT, Q1_FITNESS_TARGET_OPTIONS, Q10_PUSH_OPTIONS, PLACEHOLDER_QUESTIONS } from '@atomfit/core/config';

type Option = { key: string; label: string };

function questionFor(index: number): { key: string; label: string; options: Option[] } {
  if (index === 1) {
    return { key: 'q1_target', label: texts.quizQ1, options: Q1_FITNESS_TARGET_OPTIONS };
  }
  if (index === 10) {
    return { key: 'q10_push', label: texts.quizQ10, options: Q10_PUSH_OPTIONS };
  }
  const ph = PLACEHOLDER_QUESTIONS[index - 2]; // Q2 -> index 0
  return { key: `q${index}`, label: ph.label, options: ph.options.map((o) => ({ key: o, label: o })) };
}

export function QuizQuestion() {
  const { index } = useParams();
  const n = index ? Number(index) : 1;
  const [selected, setSelected] = useState<string | null>(null);
  const navigate = useNavigate();

  const q = questionFor(n);
  const isLast = n >= QUIZ_QUESTION_COUNT;
  const answered = selected !== null;

  const goNext = useCallback(() => {
    if (!answered) return;
    if (isLast) {
      navigate('/quiz/explainer');
    } else {
      navigate(`/quiz/question/${n + 1}`);
    }
  }, [answered, isLast, n, navigate]);

  const goBack = useCallback(() => {
    if (n <= 1) return;
    navigate(`/quiz/question/${n - 1}`);
  }, [n, navigate]);

  return (
    <section className="page flex flex-col gap-6 pt-12">
      <div className="flex items-center justify-between gap-4">
        <span className="muted" style={{ fontSize: '0.85rem' }}>
          {texts.quizProgress.replace('{n}', String(n)).replace('/ 10', `/ ${QUIZ_QUESTION_COUNT}`)}
        </span>
        <button
          onClick={goBack}
          disabled={n <= 1}
          className="btn-link"
          aria-label="Back"
        >
          {texts.quizBack}
        </button>
      </div>

      <div className="card flex flex-col gap-4">
        {/* Non-diagnostic statement on every quiz screen (Rule I-10, FR-088) */}
        <p className="muted" style={{ fontSize: '0.8rem' }}>
          {texts.quizNonDiagnostic}
        </p>
        <h2 style={{ fontSize: '1rem' }}>{q.label}</h2>
        <div className="flex flex-col gap-3" role="radiogroup" aria-label={q.label}>
          {q.options.map((opt) => (
            <button
              key={opt.key}
              type="button"
              role="radio"
              aria-checked={selected === opt.key}
              onClick={() => setSelected(opt.key)}
              className={`opt-btn ${selected === opt.key ? 'opt-selected' : 'opt-unselected'}`}
            >
              {opt.label}
            </button>
          ))}
        </div>
      </div>

      <div className="flex flex-col gap-4 mt-auto">
        <Button variant="outlined" disabled={!answered} onClick={goNext}>
          {isLast ? texts.quizQ10Button : texts.quizNext}
        </Button>
        {n > 1 && (
          <Button variant="link" onClick={goBack}>
            {texts.quizBack}
          </Button>
        )}
      </div>
    </section>
  );
}
