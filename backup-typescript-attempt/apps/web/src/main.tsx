// @atomfit/web/src/main.tsx
// Entry point. Registers the PWA service worker (Rule I-09) and boots React Router.
import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import App from './App';
import './index.css';
import './theme.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </React.StrictMode>,
);

// Register the service worker for installable offline PWA (Rule I-09).
if (typeof navigator !== 'undefined' && 'serviceWorker' in navigator) {
  void navigator.serviceWorker.register('/sw.js').catch(() => {
    // Service worker registration failure must not break the app (graceful degradation, Rule I-19).
  });
}
