// @atomfit/web/src/components/BottomNav.tsx
// Bottom navigation: Home | History | Discover | Profile. Home leftmost.
// Home highlighted & unclickable on the Home screen (BA-001, Rule I-28 accessible names).
import { NavLink, useLocation } from 'react-router-dom';
import { Logo } from './Logo';

const TABS = [
  { to: '/', label: 'Home' },
  { to: '/history', label: 'History' },
  { to: '/discover', label: 'Discover' },
  { to: '/profile', label: 'Profile' },
];

export function BottomNav({ location }: { location: { pathname: string } }) {
  return (
    <nav
      className="bottom-nav"
      aria-label="Bottom navigation"
      style={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        display: 'flex',
        height: '72px',
        paddingBottom: 'env(safe-area-inset-bottom)',
        background: 'var(--card)',
        borderTop: '1px solid var(--line)',
        zIndex: 50,
      }}
    >
      {TABS.map((tab) => {
        const active = location.pathname === tab.to;
        return (
          <NavLink
            key={tab.label}
            to={tab.to}
            end={tab.label === 'Home'}
            className={({ isActive }) =>
              'nav-tab flex flex-col items-center justify-center gap-2 flex-1 ' +
              (isActive ? 'nav-tab-active' : 'nav-tab-inactive') +
              (active ? ' active' : '')
            }
            aria-current={active ? 'page' : undefined}
            aria-label={tab.label}
            onClick={(e) => {
              // Home on the Home screen is unclickable (BA-001).
              if (active) e.preventDefault();
            }}
          >
            {tab.label === 'Home' ? (
              <Logo className="nav-logo" />
            ) : null}
            <span className={active ? 'nav-label-active' : 'nav-label'}>
              {tab.label}
            </span>
          </NavLink>
        );
      })}
    </nav>
  );
}
