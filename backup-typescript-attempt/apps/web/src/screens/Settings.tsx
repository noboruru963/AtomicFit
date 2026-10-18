// @atomfit/web/src/screens/Settings.tsx
// Settings: Display (light/dark, persisted), Personalization ("Coming soon"),
// About app (name + version). Three-dots menu opens this screen (BA-003).
import { useContext } from 'react';
import { texts } from '../texts';
import { Button } from '../components/Button';
import { themeContext } from '../App';

export function Settings() {
  const { theme, toggle } = useContext(themeContext);

  return (
    <div className="page flex flex-col gap-6 pt-12">
      <h2>{texts.settingsTitle}</h2>

      <section className="card flex flex-col gap-4">
        <h3 style={{ fontSize: '0.95rem' }}>{texts.settingsDisplay}</h3>
        <div className="flex items-center justify-between gap-4">
          <span>{texts.settingsTheme}</span>
          <Button variant="outlined" size="small" onClick={toggle!}>
            {theme === 'light' ? texts.settingsThemeDark : texts.settingsThemeLight}
          </Button>
        </div>
        <p className="muted" style={{ fontSize: '0.85rem' }}>
          Theme preference saved locally (FR-012).
        </p>
      </section>

      <section className="card flex flex-col gap-4">
        <h3 style={{ fontSize: '0.95rem' }}>{texts.settingsPersonalization}</h3>
        <Button variant="secondary" disabled>
          {texts.settingsPersonalizationComingSoon}
        </Button>
        <p className="muted" style={{ fontSize: '0.85rem' }}>
          Personalization settings are not in the MVP (ASM-22).
        </p>
      </section>

      <section className="card flex flex-col gap-4">
        <h3 style={{ fontSize: '0.95rem' }}>{texts.settingsAbout}</h3>
        <p>{texts.settingsAboutName}</p>
        <p>{texts.settingsAboutVersion}</p>
        <p className="muted" style={{ fontSize: '0.85rem' }}>{texts.settingsAboutLine}</p>
      </section>
    </div>
  );
}
