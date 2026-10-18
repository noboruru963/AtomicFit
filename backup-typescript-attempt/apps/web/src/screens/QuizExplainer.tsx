// @atomfit/web/src/screens/QuizExplainer.tsx
// SCR-07 "Why we changed your program" explainer (Improved pages flow).
// Non-diagnostic (Rule I-10).
import { useNavigate } from 'react-router-dom';
import { texts } from '../texts';
import { Button } from '../components/Button';

export function QuizExplainer() {
  const navigate = useNavigate();

  return (
    <section className="page flex flex-col gap-6 pt-16">
      <div className="flex flex-col items-center gap-4">
        <h1>{texts.appName}</h1>
      </div>

      <div className="card flex flex-col gap-4">
        <h2>{texts.quizExplainerTitle}</h2>
        <p>{texts.quizExplainerBody}</p>
        <p className="muted" style={{ fontSize: '0.8rem' }}>
          {texts.quizNonDiagnostic}
        </p>
        <Button variant="primary" onClick={() => navigate('/quiz/adjusted-program')}>
          {texts.quizNext}
        </Button>
      </div>
    </section>
  );
}
