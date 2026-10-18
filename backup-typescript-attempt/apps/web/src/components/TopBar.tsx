// @atomfit/web/src/components/TopBar.tsx
// Top bar (Home): title/clock, notification bell, three-dots settings menu next to the bell
// (BA-003). Gear icon not used. Profile reached via Profile tab.
import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Logo } from './Logo';

export function TopBar({ theme }: { theme: string }) {
  const navigate = useNavigate();
  const [menuOpen, setMenuOpen] = useState(false);
  const now = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });

  return (
    <header
      className="top-bar"
      style={{
        background: `linear-gradient(90deg, var(--primary), var(--primary-dark))`,
        color: '#fff',
        padding: '12px 16px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        position: 'sticky',
        top: 0,
        zIndex: 40,
      }}
    >
      <div className="top-bar-left flex items-center gap-12">
        <Logo className="top-logo" />
        <div className="top-bar-title">
          <div style={{ fontWeight: 800, fontSize: '1.05rem' }}>AtomFit</div>
          <div style={{ fontSize: '0.8rem', opacity: 0.85 }}>{now}</div>
        </div>
      </div>
      <div className="top-bar-right flex items-center gap-12">
        <button
          aria-label="Notifications"
          className="top-icon"
          title="Notifications"
          disabled
          // Bell is decoration (TBD-29); do not build notifications (ASM-22).
        >
          🔔
        </button>
        <button
          aria-label="Open settings"
          className="top-icon"
          onClick={() => setMenuOpen(true)}
          title="Settings"
        >
          ⋮
        </button>
        {menuOpen && (
          <div className="settings-menu">
            <button className="menu-item" onClick={() => {
              setMenuOpen(false);
              navigate('/settings');
            }}>
              Settings
            </button>
          </div>
        )}
      </div>
    </header>
  );
}
