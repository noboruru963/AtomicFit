// @atomfit/web/src/App.tsx
// Shell: theme provider + router. MainLayout (TopBar + BottomNav) wraps all
// app screens; login/register are standalone (no nav, BA-001).
import React, { useEffect, useState, useCallback, createContext, useContext } from 'react';
import { Routes, Route, Navigate, useLocation } from 'react-router-dom';
import { texts } from './texts';
import { BottomNav } from './components/BottomNav';
import { TopBar } from './components/TopBar';
import { Home } from './screens/Home';
import { Login } from './screens/Login';
import { Register } from './screens/Register';
import { QuizPrompt } from './screens/QuizPrompt';
import { QuizQuestion } from './screens/QuizQuestion';
import { QuizExplainer } from './screens/QuizExplainer';
import { QuizAdjustedProgram } from './screens/QuizAdjustedProgram';
import { Programs } from './screens/Programs';
import { ActiveWorkout } from './screens/ActiveWorkout';
import { WorkoutComplete } from './screens/WorkoutComplete';
import { History } from './screens/History';
import { Discover } from './screens/Discover';
import { Profile } from './screens/Profile';
import { Settings } from './screens/Settings';

export type Theme = 'light' | 'dark';

export const themeContext = createContext<{ theme: Theme; toggle: () => void } | null>(null);

function ThemeProvider({ children }: { children: React.ReactNode }) {
  const [theme, setTheme] = useState<Theme>('light');
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
    const stored = localStorage.getItem('atomfit_theme') as Theme | null;
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    setTheme(stored ?? (prefersDark ? 'dark' : 'light'));
  }, []);

  const toggle = useCallback(() => {
    setTheme((prev) => {
      const next = prev === 'light' ? 'dark' : 'light';
      localStorage.setItem('atomfit_theme', next);
      document.documentElement.setAttribute('data-theme', next);
      return next;
    });
  }, []);

  useEffect(() => {
    if (!mounted) return;
    document.documentElement.setAttribute('data-theme', theme);
  }, [theme, mounted]);

  const ctx = { theme, toggle };
  return <themeContext.Provider value={ctx}>{children}</themeContext.Provider>;
}

function useTheme() {
  const ctx = React.useContext(themeContext);
  if (!ctx) throw new Error('useTheme must be used within ThemeProvider');
  return ctx;
}

// Layout shared by all app screens (TopBar + BottomNav). Not used on login/register.
function MainLayout({ children }: { children: React.ReactNode }) {
  const { theme } = useTheme();
  const location = useLocation();
  return (
    <div className="app-shell" data-theme={theme}>
      <TopBar theme={theme} />
      <main className="page">{children}</main>
      <BottomNav location={location} />
    </div>
  );
}

export default function App() {
  return (
    <ThemeProvider>
      <Routes>
        <Route element={<MainLayout />}>
          <Route index element={<Home />} />
          <Route path="quiz/prompt" element={<QuizPrompt />} />
          <Route path="quiz/question/:index" element={<QuizQuestion />} />
          <Route path="quiz/explainer" element={<QuizExplainer />} />
          <Route path="quiz/adjusted-program" element={<QuizAdjustedProgram />} />
          <Route path="programs" element={<Programs />} />
          <Route path="workout/active" element={<ActiveWorkout />} />
          <Route path="workout/complete" element={<WorkoutComplete />} />
          <Route path="history" element={<History />} />
          <Route path="discover" element={<Discover />} />
          <Route path="profile" element={<Profile />} />
          <Route path="settings" element={<Settings />} />
        </Route>
        <Route path="login" element={<Login />} />
        <Route path="register" element={<Register />} />
        <Route path="*" element={<Navigate to="/" replace />} />
      </Routes>
    </ThemeProvider>
  );
}
