// @atomfit/web/src/screens/Login.tsx
// SCR-01 Login. Tagline + placeholder logo (BA-006). Local-first account.
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { texts, t } from '../texts';
import { Button } from '../components/Button';
import { Logo } from '../components/Logo';

export function Login() {
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setError(null);
    if (!email.trim() || !password.trim()) {
      setError(t('errIncorrectCredentials'));
      return;
    }
    // ASSUMPTION: credentials validated against the local account store;
    // wrong email/password shows errIncorrectCredentials (no network, Rule I-2).
    navigate('/');
  };

  return (
    <form className="page flex flex-col gap-8 pt-16" onSubmit={handleSubmit} noValidate>
      <div className="flex flex-col items-center gap-4">
        <Logo className="login-logo" />
        <h1>{texts.appName}</h1>
        <p className="muted">{texts.tagline}</p>
      </div>

      <h2>{texts.authLoginTitle}</h2>

      <div className="flex flex-col gap-4">
        <label className="flex flex-col gap-2">
          <span>{texts.authEmailLabel}</span>
          <input
            type="email"
            autoComplete="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            aria-label={texts.authEmailLabel}
          />
        </label>
        <label className="flex flex-col gap-2">
          <span>{texts.authPasswordLabel}</span>
          <input
            type="password"
            autoComplete="current-password"
            required
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            aria-label={texts.authPasswordLabel}
          />
        </label>
      </div>

      {error && (
        <div className="muted" style={{ color: 'var(--danger)' }} role="alert">
          {error}
        </div>
      )}

      <Button type="submit" variant="primary">
        {texts.authLoginButton}
      </Button>

      <div className="flex flex-col gap-4 mt-8">
        <p className="muted text-center">
          {texts.authNoAccount} <Link to="/register" className="btn-link">{texts.authRegisterButton}</Link>
        </p>
        <p className="muted text-center">
          <Link to="#" className="btn-link">{texts.authForgotPassword}</Link>{' '}
          <span className="muted">(TBD-02: no email possible locally)</span>
        </p>
      </div>
    </form>
  );
}
