// @atomfit/web/src/screens/Profile.tsx
// SCR-04 Profile. Username, email, gender (BA-002), date of birth, weight, height.
// Gender must NOT influence quiz/program/analytics (BA-002 out of scope note).
import { useState } from 'react';
import { texts } from '../texts';
import { Button } from '../components/Button';

export function Profile() {
  const [form, setForm] = useState({
    username: 'Alex',
    email: 'alex@example.com',
    gender: 'Prefer not to say' as 'Male' | 'Female' | 'Prefer not to say',
    dateOfBirth: '',
    weightKg: '',
    heightCm: '',
  });
  const [saved, setSaved] = useState(false);

  const handleSubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    // ASSUMPTION: persisted to local profile (Rule I-24 sanitise text).
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  };

  return (
    <div className="page flex flex-col gap-6 pt-12">
      <h2>{texts.profileTitle}</h2>

      <form onSubmit={handleSubmit} noValidate className="flex flex-col gap-5">
        <div className="flex flex-col gap-2">
          <label style={{ fontWeight: 700, fontSize: 0.9rem }}>{texts.profileUsername}</label>
          <input
            type="text"
            value={form.username}
            onChange={(e) => setForm({ ...form, username: e.target.value })}
            aria-label={texts.profileUsername}
          />
        </div>
        <div className="flex flex-col gap-2">
          <label style={{ fontWeight: 700, fontSize: 0.9rem }}>{texts.profileEmail}</label>
          <input
            type="email"
            value={form.email}
            onChange={(e) => setForm({ ...form, email: e.target.value })}
            aria-label={texts.profileEmail}
          />
        </div>
        <div className="flex flex-col gap-2">
          <label style={{ fontWeight: 700, fontSize: 0.9rem }}>{texts.profileGender}</label>
          <select
            value={form.gender}
            onChange={(e) => setForm({ ...form, gender: e.target.value as any })}
            aria-label={texts.profileGender}
          >
            <option value="Male">{texts.authGenderMale}</option>
            <option value="Female">{texts.authGenderFemale}</option>
            <option value="Prefer not to say">{texts.authGenderPreferNotToSay}</option>
          </select>
        </div>
        <div className="flex flex-col gap-2">
          <label style={{ fontWeight: 700, fontSize: 0.9rem }}>{texts.profileDateOfBirth}</label>
          <input type="date" value={form.dateOfBirth} onChange={(e) => setForm({ ...form, dateOfBirth: e.target.value })} aria-label={texts.profileDateOfBirth} />
        </div>
        <div className="flex flex-col gap-2">
          <label style={{ fontWeight: 700, fontSize: 0.9rem }}>{texts.profileWeight}</label>
          <input type="number" step="0.1" min="0" max="999.9" value={form.weightKg} onChange={(e) => setForm({ ...form, weightKg: e.target.value })} aria-label="Weight (kg)" />{' kg'}
        </div>
        <div className="flex flex-col gap-2">
          <label style={{ fontWeight: 700, fontSize: 0.9rem }}>{texts.profileHeight}</label>
          <input type="number" step="1" min="0" value={form.heightCm} onChange={(e) => setForm({ ...form, heightCm: e.target.value })} aria-label="Height (cm)" />{' cm'}
        </div>
      </form>

      <Button variant="primary" onClick={() => {}}>
        {texts.profileUpdate}
      </Button>
      {saved && (
        <p className="muted" style={{ color: 'var(--success)', fontSize: 0.9rem, fontWeight: 700 }}>
          {texts.profileUpdated}
        </p>
      )}
      <p className="muted" style={{ fontSize: 0.8rem }}>
        Gender is stored/displayed only (BA-002) — it does not affect quiz rules,
        program adjustments, or analytics.
      </p>
    </div>
  );
}
