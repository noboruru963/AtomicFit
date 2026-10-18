// @atomfit/web/src/screens/Register.tsx
// SCR-02 Register. Fields: username, email, password, confirm, date of birth,
// terms checkbox, + gender (BA-002). Local profile; no cloud (Rule I-2).
import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { texts, t } from '../texts';
import { Button } from '../components/Button';
import { Logo } from '../components/Logo';

type Gender = 'Male' | 'Female' | 'Prefer not to say';

export function Register() {
  const navigate = useNavigate();
  const [form, setForm] = useState({
    username: '',
    email: '',
    password: '',
    confirmPassword: '',
    dateOfBirth: '',
    gender: 'Prefer not to say' as Gender,
    terms: false,
  });
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    setError(null);
    if (form.password !== form.confirmPassword) {
      setError(t('errPasswordsDoNotMatch'));
      return;
    }
    if (!form.terms) {
      setError(t('errAcceptTerms'));
      return;
    }
    // ASSUMPTION: account stored locally (Rule I-23 salted hash); no server.
    navigate('/');
  };

  return (
    <form className="page flex flex-col gap-6 pt-12" onSubmit={handleSubmit} noValidate>
      <div className="flex flex-col items-center gap-4">
        <Logo className="login-logo" />
        <h1>{texts.appName}</h1>
        <p className="muted">{texts.tagline}</p>
      </div>

      <h2>{texts.authRegisterTitle}</h2>

      <div className="flex flex-col gap-4">
        <label className="flex flex-col gap-2">
          <span>{texts.authUsernameLabel}</span>
          <input
            type="text"
            autoComplete="username"
            required
            value={form.username}
            onChange={(e) => setForm({ ...form, username: e.target.value })}
            aria-label={texts.authUsernameLabel}
          />
        </label>
        <label className="flex flex-col gap-2">
          <span>{texts.authEmailLabel}</span>
          <input
            type="email"
            autoComplete="email"
            required
            value={form.email}
            onChange={(e) => setForm({ ...form, email: e.target.value })}
            aria-label={texts.authEmailLabel}
          />
        </label>
        <label className="flex flex-col gap-2">
          <span>{texts.authPasswordLabel}</span>
          <input
            type="password"
            autoComplete="new-password"
            required
            value={form.password}
            onChange={(e) => setForm({ ...form, password: e.target.value })}
            aria-label={texts.authPasswordLabel}
          />
        </label>
        <label className="flex flex-col gap-2">
          <span>Confirm password</span>
          <input
            type="password"
            autoComplete="new-password"
            required
            value={form.confirmPassword}
            onChange={(e) => setForm({ ...form, confirmPassword: e.target.value })}
            aria-label="Confirm password"
          />
        </label>
        <label className="flex flex-col gap-2">
          <span>{texts.authDateOfBirthLabel}</span>
          <input
            type="date"
            required
            value={form.dateOfBirth}
            onChange={(e) => setForm({ ...form, dateOfBirth: e.target.value })}
            aria-label={texts.authDateOfBirthLabel}
          />
        </label>
        <label className="flex flex-col gap-2">
          <span>{texts.authGenderLabel}</span>
          <select
            required
            value={form.gender}
            onChange={(e) => setForm({ ...form, gender: e.target.value as Gender })}
            aria-label={texts.authGenderLabel}
          >
            <option value="">{texts.authGenderPlaceholder}</option>
            <option value="Male">{texts.authGenderMale}</option>
            <option value="Female">{texts.authGenderFemale}</option>
            <option value="Prefer not to say">{texts.authGenderPreferNotToSay}</option>
          </select>
        </label>
        <label className="flex items-center gap-3">
          <input
            type="checkbox"
            required
            checked={form.terms}
            onChange={(e) => setForm({ ...form, terms: e.target.checked })}
            aria-label={texts.authTermsLabel}
          />
          {texts.authTermsLabel}
        </label>
      </div>

      {error && (
        <div className="muted" style={{ color: 'var(--danger)' }} role="alert">
          {error}
        </div>
      )}

      <Button type="submit" variant="primary">
        {texts.authRegisterButton}
      </Button>

      <div className="flex flex-col gap-4 mt-8">
        <p className="muted text-center">
          {texts.authHaveAccount} <Link to="/login" className="btn-link">{texts.authLoginButton}</Link>
        </p>
      </div>
    </form>
  );
}
