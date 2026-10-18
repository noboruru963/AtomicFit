# AtomFit v1

Local-first, mobile-first workout tracker built as an installable offline-capable PWA
(React + TypeScript). Purpose: **consistency, not perfection**. Tagline: *"Log it. Keep going."*

## Architecture (per AGENTS.md)

```
packages/
├─ core/       domain logic — Save-Set service, session service, quiz engine,
│              inactivity service, stitching service, progression, analytics.
│              NO UI / device / storage imports. (Rule I-04)
├─ storage/    Dexie (IndexedDB) schema, repositories, migrations. (depends on core)
└─ device/     sensor / speech / vibration / lock-screen adapter interfaces + fakes.
apps/
└─ web/        React 18 + React Router + Vite, typed text resources, light/dark theme,
               all screens, PWA service worker + manifest.
```

Dependency direction: `apps/web → core, storage, device`; `storage → core`; `device → core`; **`core → nothing app-specific`**.

## Prerequisites

Node.js >= 20 and pnpm are required. They are **not** installed in this environment, so run these on a machine with Node:

```bash
# Install dependencies
pnpm install

# Type-check (Rule I-01: tsc --noEmit must pass with zero errors)
pnpm run typecheck

# Run unit + integration tests (Rule I-30: core domain >= 80% line coverage)
pnpm run test

# Lint + format (build fails on ESLint error)
pnpm run lint
pnpm run format

# Start dev server (mobile-first, 360-430 px viewports)
pnpm run dev
```

## GitHub upload

This folder is a git repository with one initial commit. To upload it to your GitHub:

```bash
# 1. Set your identity (one-time)
git config user.name "Your Name"
git config user.email "you@example.com"

# 2. Create an empty repository on GitHub (do NOT initialize with README),
#    then add it as the remote:
git remote add origin https://github.com/YOUR_USERNAME/atomfit.git

# 3. Push
git branch -M main
git push -u origin main
```

If you use SSH instead of HTTPS, use `git@github.com:YOUR_USERNAME/atomfit.git` and make sure your SSH key is added to GitHub.

## Scope notes (v1)

- Built to the AGENTS.md immutable rules: local-first (no server), TypeScript strict,
  one Save-Set service, idempotent writes, atomic multi-record operations, kg-only units,
  UTC + IANA time-zone timestamps, light/dark themes, typed text resources, accessible controls.
- Quiz is non-diagnostic (Rule I-10); zero-guilt language (Rule I-11); 7-day inactivity
  trigger, 10 questions, 10–20% ease-in (BA-004).
- Navigation: Home | History | Discover | Profile, Home locked when active (BA-001).
- Lock-screen quick-add (US-003) is delivered as an in-app quick-add bar plus a
  best-effort service-worker notification (PWA-only, BA-005). A true native lock-screen
  widget is not possible in a PWA (Rule I-09) and is marked platform-limited.

## Open / TBD items

Several behaviors are deliberately left behind replaceable configs flagged `// TBD-nn`
or `// ASSUMPTION:` (per Rule I-29) because the SRS marks them TBD or Assumption. Promote
these to Behavior Addenda or decide them with the team before shipping:
- TBD-05 lock-screen feasibility / "+1 set" meaning
- TBD-06 speech-to-text engine / offline support
- TBD-07 voice grammar
- TBD-08 supported auto-count exercises
- TBD-10 quiz Q2–Q9 wording
- TBD-11 quiz rule table + safety limits / weekly ramp
- TBD-12 quiz re-prompt rule
- TBD-15 "continue last workout" when nothing is unfinished
- TBD-16 streak behavior
- TBD-17 stitching eligibility
- TBD-18 progression policy
- TBD-20 exercise catalogue
- TBD-27 rest timer sound
