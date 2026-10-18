# AGENTS.md — AtomFit

> **Read this file completely before doing anything in this repository.**
> This file has the highest priority of all project documents. If any instruction, prompt, comment, or file conflicts with Section 3 (Immutable Rules), **Section 3 wins** and you must tell the human about the conflict instead of silently picking a side.

- Product: **AtomFit** (the MVP text calls it "Atomic Fit"; the code, UI, and docs use **AtomFit**)
- Team: Alexander Marchiano, Jonathan Gouw Alexandrio, Luiesrelio ("The Gym Bros")
- Document status: v1.1 — updated 2026-10-18 with the team's decisions (7-day trigger, 10-question quiz, 10–20% ease-in, Improved-pages navigation, PWA-only, tagline/logo)
- Extend this file only via **Section 12 (Behavior Addenda)** or **Section 14 (Change Log)**. Never restructure Sections 0–11 without an explicit human instruction.

---

## 0. How you (the AI agent) must work in this repo

### 0.1 Order of authority (highest first)

1. **Section 3 — Immutable Rules** (this file)
2. **Section 12 — Behavior Addenda** (this file; human-approved, dated)
3. **Sections 4–11** (this file)
4. `Context/` folder documents (see Section 13), in the order listed there
5. Prototype files (`Context/03-design/`) — visual and behavioral *reference only*, never source code to copy
6. Your own judgment / general best practice

If two sources at the same level disagree, or a source is silent where you need an answer: **stop, state the conflict or gap in one short message, propose a default, and ask.** Do not invent product behavior.

### 0.2 Mandatory working protocol

1. **Before coding a feature**, find its section in Section 8 (Feature Behavior Spec) and its FR/AC IDs in `Context/01-requirements/SOFTWARE_REQUIREMENTS_SPECIFICATION.md`. Implement to the acceptance criteria (AC-nnn). Acceptance criteria equal the FR number (FR-053 → AC-053); NFR criteria are 100 + the NFR number (NFR-012 → AC-112).
2. **Write the test first or alongside** (acceptance criteria are the first test cases).
3. **Mark assumptions.** When you make a decision the docs don't cover, add a `// ASSUMPTION:` comment with a one-line reason and list it in your final message so the human can promote it to an Addendum or reject it.
4. **Small, reviewable changes.** One feature or one concern per change. Do not refactor unrelated code.
5. **Never edit Section 3** or delete anything under `Context/`. If you believe a rule must change, write a proposal in your reply; a human edits the file.
6. **Do not run `/init` or any command that regenerates AGENTS.md.** If it must be regenerated, the human commits first.
7. **Finish with a short report:** what changed, which FR/AC IDs are covered, which tests were added, assumptions made, open questions.

### 0.3 Things you must never do

- Add a server, cloud sync, account backend, third-party analytics SDK, or any network call that carries user data (Rules I-02, I-03).
- Write hand-authored JavaScript source files (Rule I-01).
- Write medical, diagnostic, shaming, or guilt-inducing copy (Rules I-10, I-11).
- Copy code from the HTML prototype into production (it is a throwaway, in-memory demo with hard-coded data).
- Invent exercises, quiz rules, ramp-down percentages, or eligibility rules that are marked **TBD** in this file or the SRS. Implement them behind a documented, replaceable config/table and flag them.

---

## 1. Product in one paragraph

AtomFit is a **local-first, mobile-first workout tracker** whose purpose is **consistency, not perfection**. It makes logging nearly effortless (automatic rep counting from phone sensors, voice logging, lock-screen quick-add) and removes guilt when real life interrupts training (a short **non-diagnostic quiz** after inactivity that adjusts the program, **micro sessions** that save partial workouts, and **set stitching** that merges fragmented sessions). Final UI tagline: **"Log it. Keep going."** Internal guiding principle (not the UI tagline): *every rep counts.*

**Core insight:** The pain is not forgetting numbers. The pain is that a lost count makes the session feel like it *"didn't count."* Demotivation hits hardest for people whose only reward is visible progress.

**Two root causes the product targets:**
1. **In-workout friction** — typing, losing count, losing position mid-set.
2. **Post-lapse guilt** — broken streaks, the "it didn't count" mindset, restarting after a break.

**Origin problem (Alex):** People who exercise alone must manage their program, form, and reps *and* remember to log everything; fatigue makes them forget, so logs become inaccurate, progress slows, and motivation drops. A personal trainer solves this, but most people can't access one.

**Guiding question:** *Can we give people affordable, low-effort, personal-trainer-like support that tracks progress automatically, adapts to real-life disruptions, and suggests a plan suited to the individual — without a trainer's time, money, or specialist knowledge?*

---

## 2. Users and personas

### 2.1 Target audience
1. **Students** — health and aesthetics; strongly budget-restricted.
2. **Young working people** — maximize sessions around routines; receptive to digital tools.
3. **Middle-aged working people** — job and family first; exercise for longevity.
4. **Stay-at-home parents** — errands and housework first; highly fragmented time.

### 2.2 SRS user classes (use these IDs in code comments, tests, and docs)

| ID | Class | Key traits | Primary stories |
|---|---|---|---|
| UC-01 | Recreational lifter | Trains regularly; wants quick logging mid-workout | US-001–003 |
| UC-02 | Returning user | 7+ days inactive; wants a guilt-free restart | US-004 |
| UC-03 | Time-constrained user | Leaves early or splits workouts; wants partial work to count | US-005, US-006 |
| UC-04 | Beginner | Unfamiliar with exercises; needs safe, simple guidance | US-012, US-013 |

### 2.3 Research personas (design intuition; keep names consistent with this list)

| Persona | Needs | Design implication |
|---|---|---|
| High Schooler Newbie (e.g., Jamie, 17) | Free "coach in pocket", structure, visible progress, no gym intimidation | Clear defaults, safe exercise notes, no pay-wall feel |
| Fit Undergraduate (e.g., Kevin, 20) | Zero-subscription auto counting; typing breaks rhythm | Auto-count, one-tap/steppers, no keyboard mid-set |
| Corporate Lifter / 9-to-5 Gym Bro (e.g., Tony 50, Joshua 25) | Sessions cut short by meetings; restart after breaks without guilt | Micro sessions, quiz, ease-in |
| On-the-Go Mom (e.g., Sarah, 43) | 15-minute sessions valid; remembers exact stop point | Micro sessions, resume, stitching |

### 2.4 Research facts that justify design decisions
- 15 respondents: 12 lost track of progress; 10 exercise 0–2×/week; only 1 would definitely pay (10 "maybe") → **the MVP must work free, offline, with no subscription logic.**
- Reasons for losing track: mid-workout interruptions (family/work), forgetting to count, distraction, cutting workouts short for errands/childcare.
- Users want: automatic tracking, free/low cost, adaptation to schedule, progress visualization.
- Competitors: Hevy (manual input, experienced lifters), Fitbod (beginners, expensive subscription), Strava (passive tracking but toxic "all-or-nothing" mindset). AtomFit differentiates on **zero-guilt re-engagement + near-zero-effort logging, free and local.**

---

## 3. IMMUTABLE RULES (never violate; never edit without a human)

Each rule has an ID. Cite the ID in code comments or PR text when a decision depends on it.

### 3.1 Platform and architecture

| ID | Rule |
|---|---|
| **I-01** | **TypeScript 5.x with `strict: true`** for all hand-written source. JavaScript only for generated/config files. `tsc --noEmit` must pass with zero errors. (NFR-025) |
| **I-02** | **Local-first, no project server.** All MVP functions work offline. Data lives on the device. The only permitted network use is a speech-to-text engine *if* the chosen engine requires it (TBD-06). (FR-116, NFR-026) |
| **I-03** | **No user data leaves the device.** No third-party analytics/crash SDKs that transmit data. Analytics events are stored locally only. (NFR-037, FR-130) |
| **I-04** | **Layered architecture with a framework-independent core.** `packages/core` contains domain logic and **must not import UI, browser-device, or storage code.** Enforce with a dependency-rule check. (NFR-043) |
| **I-05** | **One Save-Set service.** Manual entry, automatic counting, voice logging, and lock-screen actions **all** persist sets through the single `Save-Set` service. No other code path may write `set_log` rows. (FR-118) |
| **I-06** | **Idempotent writes.** Every set and session has a client-generated UUID; saving an existing ID again must not create a duplicate. (FR-119, FR-098) |
| **I-07** | **Atomic multi-record operations.** Save session, stitch, unstitch, and apply program version are all-or-nothing transactions. (NFR-019, FR-107) |
| **I-08** | **Durability.** Every change to an active workout is persisted within 1 second and restored after force-close. (FR-117, NFR-033) |
| **I-09** | **Delivery form: installable, offline-capable PWA (React + TypeScript) only.** No Capacitor/Cordova/native wrapper and no native source code in the MVP *(decided 2026-10-18; supersedes the optional Capacitor path in ASM-02)*. Use standard web APIs only (NFR-031). A feature the web platform cannot deliver must degrade gracefully (I-19), be reported, and **never be faked**. |

### 3.2 Product behavior

| ID | Rule |
|---|---|
| **I-10** | **The quiz is non-diagnostic.** It supports workout planning only, never a medical/psychological assessment. Every quiz screen shows a non-diagnostic statement. Never use words like "diagnose", "assessment of your health", "disorder". The UI label is **"Quiz"** or **"Restart quiz"**; never "Diagnostic Quiz" in user-facing text. (FR-088) |
| **I-11** | **Zero-guilt language.** Never shame, nag, or use "failed", "missed", "broken streak", "incomplete" in a negative frame in user-facing text. Partial work is *legitimate* ("Micro session", "Saved"). |
| **I-12** | **Quiz adjustment is a deterministic, documented rule table.** No machine learning, no network call, no randomness. Conflicts resolved by documented precedence; adjustments stay within documented safety limits. (FR-083, FR-084) |
| **I-13** | **The user stays in control of program changes.** A quiz adjustment is shown as a **preview**; applied only on **Accept** as a **new program version**; the previous version is retained and **revertable**. Nothing changes the Current program silently. (FR-085–087) |
| **I-14** | **Exactly one Current program per user at any time.** (FR-026, ASM-20) |
| **I-15** | **Micro sessions are first-class.** A saved partial workout is a real session (`type = micro`, `completion_status = incomplete`), counts as a completed workout for the calendar, monthly count, and inactivity rule, and can be resumed. (FR-092, FR-099) |
| **I-16** | **Stitching never double-counts and never mutates children.** A stitched session is a *parent* referencing exactly two *child* sessions; children keep their own data; every child's metrics count exactly once in totals; unstitch restores both children and prior totals; progression results are identical stitched or not. (FR-103, FR-105, FR-106, FR-108) |
| **I-17** | **Destructive actions need confirmation** (discard workout, delete session, unstitch, delete all data). (NFR-008) *(The HTML prototype deletes history instantly — that is a prototype shortcut, not the rule.)* |
| **I-18** | **Auto-count and voice results are always user-correctable before saving.** Auto-count shows an editable final count plus +1/−1; voice shows a confirmation card (confirm/edit/cancel). Unparseable voice input shows a retry message and **saves nothing**. (FR-056, FR-057, FR-065, FR-066) |
| **I-19** | **Graceful degradation.** If sensors, mic, or lock-screen support are unavailable or permission is denied, show a clear message and keep **manual logging fully available**. (FR-050, FR-059, FR-061) |

### 3.3 Data and privacy

| ID | Rule |
|---|---|
| **I-20** | **Units:** weight in **kg** (decimal, 0–999.9, one decimal), reps whole 0–999, duration whole **seconds**, height **cm**. No unit selector in MVP. (ASM-07, ASM-08, NFR-021) |
| **I-21** | **Time:** store timestamps in **UTC + IANA time-zone ID**; a session belongs to the calendar day of its start in the stored zone. (FR-120, ASM-19) |
| **I-22** | **Raw sensor samples and raw audio are processed in memory only and never persisted.** (NFR-040, ASM-21) |
| **I-23** | **Passwords stored only as salted hashes via a slow KDF** — never plain text. (NFR-036) |
| **I-24** | **Sanitise all user-entered text** before storing or displaying. (NFR-035) |
| **I-25** | **Explain permissions before the OS prompt** (sensors, microphone). (NFR-041) |

### 3.4 UI and quality

| ID | Rule |
|---|---|
| **I-26** | **Mobile-first layout:** no horizontal scroll at 360–430 CSS px; centred frame ≤ 430 px on wider screens; touch targets ≥ 44×44 px; **light and dark themes** both fully supported; contrast ≥ 4.5:1 (WCAG 2.2 AA). (NFR-002, 003, 005, 030) |
| **I-27** | **All user-facing strings live in a typed text-resource module** (keyed by ID). English only in MVP, but no hard-coded UI strings in components. (NFR-007) |
| **I-28** | **Every control has an accessible name;** the full quiz flow must be screen-reader operable. (NFR-004) |
| **I-29** | **Do not invent requirements.** Where the SRS says **TBD** or **Assumption**, implement the smallest reasonable thing behind a replaceable config, mark it `// TBD-nn`, and report it. |
| **I-30** | **Quality gates:** build fails on ESLint error or failing unit test; core domain modules ≥ 80% line coverage. (NFR-028, NFR-042) |

---

## 4. Problem and proposed solution

### 4.1 Problem
1. **In-workout friction:** manual logging interrupts rhythm; tired, breathless users forget or lose count → inaccurate logs → slower progress → lower motivation.
2. **Post-interruption guilt:** missed days, early exits, and split workouts make users feel the effort "didn't count", so they quit tracking.

### 4.2 Solution — Epic **EP-001: Easy Exercise Tracking and Re-engagement** (the MVP heart)

**Group A — Easy Exercise Tracking (reduce effort in the moment)**
| Story | Feature |
|---|---|
| **US-001** | Automatic repetition counting from accelerometer + gyroscope |
| **US-002** | Voice-based workout logging (speech-to-text → parser → confirmation card) |
| **US-003** | Lock-screen quick add (+1 rep, +1 set) — PWA-constrained, see 8.3 |

**Group B — Re-engagement (preserve value after interruptions)**
| Story | Feature |
|---|---|
| **US-004** | Short non-diagnostic quiz after 7+ days inactive → adjusted program |
| **US-005** | Micro sessions: save the completed portion of an early-exited workout; resume later |
| **US-006** | Set stitching: combine two eligible sessions into one parent session; unstitch |

### 4.3 Supporting epic **EP-002: Foundation** (US-007 … US-018)
Registration/login (local profiles), home (calendar, monthly count, continue last workout), profile, settings (theme), programs, exercise exploration, manual workout logging, rest timer, history (search/delete), local persistence, local analytics events. These exist because the six MVP stories depend on them (ASM-06).

---

## 5. MVP scope

### 5.1 In the MVP
- All six EP-001 stories (US-001 … US-006) and the EP-002 foundation (US-007 … US-018).
- Local accounts, local data, offline operation, light/dark theme, English, kg.

### 5.2 Not in the MVP (do not build, do not scaffold) — ASM-22
Native app wrappers (Capacitor/Cordova) and any native code, a guaranteed OS-level lock-screen widget, cloud sync, social features, wearable/smartwatch integration, nutrition tracking, payments/subscriptions, push notifications, administrator role, analytics dashboards (events are recorded locally; dashboards are Future), data export (JSON/CSV is Future), profile-picture change (Future), password-reset email (impossible locally), Personalization settings (shows "Coming soon").

### 5.3 Ideas from research that are **not** MVP (backlog only; do not implement without an Addendum)
Weekly Rep/Volume Bucket, "Save Point" resume widget (partially covered by US-005), Seasons / "Welcome Back" framing, "Pause" history log, charts/graphs, exercise demo videos/GIFs, cardio recording, onboarding tour, peer support.

### 5.4 MoSCoW totals (from SRS §4.1)
Must: 78 FR / 15 NFR in MVP. Should: 44 FR / 29 NFR. Could: 3 FR / 1 NFR in MVP (+ Future items). Won't: FR-014.

---

## 6. Architecture (binding)

### 6.1 Layers

| Layer | Responsibility | Technology | Status |
|---|---|---|---|
| Presentation | Screens, navigation, themes, a11y, text resources | React 18, React Router, CSS custom properties (light/dark), typed text-resource module | Fixed (ASM-03) |
| **Domain core** | Business logic: session service, **Save-Set service**, repetition detector, voice parser, quiz rule engine, stitching service, progression policy, inactivity service, analytics service | Plain TypeScript package `core` — **no UI/device/storage imports** | **Fixed (I-04)** |
| Device adapters | Sensors, mic, speech-to-text, vibration, lock-screen — behind TS interfaces | Device Motion / Generic Sensor, MediaDevices, speech engine (TBD-06), Vibration API, Notifications API via service worker (best-effort quick-add, see 8.3) | Fixed pattern; engines TBD |
| Persistence | Typed tables, transactions, schema versioning, idempotent writes | IndexedDB via **Dexie** + repository classes | Fixed (ASM-03) |
| Validation | Shared input/event schemas | **Zod** | Fixed |
| Build/quality | Compile, lint, format | TypeScript strict, Vite, ESLint (typescript-eslint), Prettier | Fixed |
| Testing | Unit/integration/E2E/a11y | Vitest, React Testing Library, fake-indexeddb, Playwright (mobile emulation), axe-core | Fixed |
| Packaging | Installable offline app | PWA + service worker (vite-plugin-pwa or Workbox); **no native wrapper (I-09)** | Fixed |

### 6.2 Repository structure (pnpm workspaces)

```
/
├─ AGENTS.md                 ← this file
├─ Context/                  ← overflow context (Section 13)
├─ packages/
│  ├─ core/                  ← domain logic; unit tests with fixtures; NO UI/device/storage imports
│  ├─ storage/               ← Dexie schema, repositories, migrations; integration tests (fake-indexeddb)
│  └─ device/                ← sensor/speech/vibration/lock-screen adapters + fakes (contract tests)
├─ apps/
│  └─ web/                   ← React screens, routing, themes, text resources, PWA config
└─ tests/
   └─ fixtures/              ← recorded sensor signals, voice phrases, time-zone & termination fixtures, rule-table cases
```
Dependency direction: `apps/web → core, storage, device`; `storage → core`; `device → core`; **`core → nothing app-specific`**.

### 6.3 Rules of thumb for implementation
- UI components call **core services** (via thin hooks), never repositories or device APIs directly.
- Device adapters expose interfaces defined in `core`; swap real ↔ fake in tests. Provide **fakes for sensor and speech** from the start.
- Sensor signal → **smoothing filter → peak detection (threshold + minimum interval) → count**; parameters are **per-exercise** config objects.
- Voice: `speech-to-text → parser → ParsedSet {exercise, reps, weight?} | ParseError → confirmation card → Save-Set`.
- Quiz: `answers → rule table (+ precedence + safety limits) → Adjustment {sessionLength, intensity, frequency} → preview → Accept → new program_version`.
- A single **preview-and-confirm** UI pattern is shared by Quiz and Stitch; a single analytics **event schema** and shared test fixtures (time zones, offline, app termination) are reused across features. (Reuse is a design requirement, NFR-044.)
- Prefer pure functions in `core`; inject clock and time zone for testability.

### 6.4 Performance targets (proposals; ASM-13)
Home interactive ≤ 3 s cold start (p95); screen transition ≤ 300 ms (p95); live counter update ≤ 200 ms (p95); Save-Set ≤ 200 ms (p95); voice confirmation card ≤ 3 s after speech end (p95); History 5000 sessions renders ≤ 500 ms, search keystroke ≤ 300 ms; motion sampling ≥ 25 Hz else disable auto-count with a message; rest timer drift ≤ 1 s over 120 s (including backgrounded); auto-count within ±1 rep in ≥ 90% of test sets per supported exercise.

---

## 7. Data model (informative; attribute names are proposals)

| Entity | Key attributes | Notes |
|---|---|---|
| `user_account` | id, username, email, password_hash, salt, date_of_birth, **gender** (see BA-002), created_at, updated_at | One per local account |
| `user_profile` | user_id, weight_kg, height_cm, picture | |
| `app_setting` | user_id, theme (light/dark), analytics_enabled | |
| `exercise` | id, name, description, difficulty_note | Catalogue (TBD-20) |
| `program` | id, user_id (null = built-in), name, description, is_current | Exactly one `is_current` per user |
| `program_version` | id, program_id, version_no, source (manual/quiz), created_at | Quiz adjustment = new version; previous retained |
| `program_set` | id, program_version_id, exercise_id, set_no, planned_weight_kg, planned_rest_s | |
| `workout_session` | id (client UUID), user_id, program_version_id?, name, **type (full/micro/stitched)**, completion_status, parent_session_id?, started_at_utc, time_zone, duration_s, created_at, updated_at | |
| `set_log` | id (client UUID), session_id, exercise_id, set_no, weight_kg, reps, rest_s, input_method (manual/sensor/voice/lockscreen), logged_at_utc | **Written only via Save-Set (I-05)** |
| `stitched_session` | parent_session_id, child_session_ids (2), combined_sets/reps/volume_kg/duration_s | Children keep their own `set_log` rows |
| `quiz_attempt` | id, user_id, started_at_utc, status (complete/incomplete) | |
| `quiz_answer` | id, quiz_attempt_id, question_key, answer_key | |
| `user_program_adjustment` | id, quiz_attempt_id, program_version_from/to, session_length, intensity, frequency, accepted, reverted | |
| `analytics_event` | id, name, timestamp_utc, anon_user_id, session_id, properties(JSON) | Local only |

**Definitions:** Volume = Σ(weight × reps) over completed sets. A *completed set* on the summary screen = a set with ≥ 1 rep. Inactive user = most recent completed workout (full or micro) started ≥ 7 local calendar days ago. Every record carries created/updated UTC timestamps.

---

## 8. Feature behavior spec (condensed; full detail in the SRS)

> Format: **Behavior** → key FR/AC IDs. Implement to the acceptance criteria. Anything marked **TBD** needs a human decision (see Section 11).

### 8.1 Automatic repetition counting (US-001, FR-049–059)
- Start set for a selected exercise → live counter at 0, sensor capture starts; stop → editable final count; **+1/−1** steppers (never below 0); save through Save-Set.
- Request motion-sensor permission before first use if the platform requires it; on denial → manual entry.
- Counter text ≥ 48 px, visible with controls without scrolling at 360×640 (NFR-009).
- Error state if sensors unavailable or 0 reps counted → message + manual entry.
- Supported exercises (proposal ASM-11, TBD-08): squat, bench/chest press, dumbbell curl, dumbbell shoulder press, tricep raise. Phone is held or strapped to limb/bar; pocket/floor unsupported (ASM-12).

### 8.2 Voice logging (US-002, FR-060–068)
- Mic button on active workout screen → permission (explain first) → listening indicator → speech-to-text → parser → **confirmation card** (exercise, reps, optional weight; confirm / edit / cancel).
- Examples: "10 reps squat" → squat, 10, no weight; "squat 10 reps 60 kilos" → weight 60 kg. Full grammar TBD-07. English only.
- Unparseable ("hello there") → retry message, **nothing saved**.

### 8.3 Lock-screen quick add (US-003, FR-069–073) — PWA-constrained
- **Intent (unchanged):** outside the main app, one tap adds **+1 rep** or **+1 set**; each tap is saved immediately via Save-Set; the in-app count matches; counts survive app close; the control disappears on finish/discard.
- **Decision 2026-10-18:** the product is a **PWA only (I-09)**. A web app cannot render a true lock-screen widget (iOS Live Activity / Android ongoing notification need native code).
- **Build order:**
  1. **In-app quick-add bar** on the active workout screen (large +1 rep / +1 set, immediate save). **Mandatory.** It satisfies the persistence behavior FR-070–072.
  2. **Best-effort persistent notification with action buttons** via the service worker, only where the browser supports it. Run a **feasibility spike first**. Do not promise iOS support; do not claim behavior you haven't verified on a real device.
  3. The rest timer's "Show on lock screen" option (Improved pages concept screen) uses the same mechanism and the same caveat.
- **Reporting:** FR-069's criterion ("control visible while the device is locked") cannot be guaranteed on a PWA. Mark it *platform-limited* in your report and ask the human. Meaning of "+1 set" is TBD-05.

### 8.4 Re-engagement quiz (US-004, FR-074–089) — decisions of 2026-10-18 applied (BA-004)
- **Trigger:** on app open when inactive for **7 local calendar days or more** (`INACTIVITY_THRESHOLD_DAYS = 7`, decided). The Improved-pages explanatory copy says "14+ days"; **use 7 and fix that copy.** The Improved pages also say the quiz appears "for testing" on new accounts: implement that only as a dev-only flag, off in production.
- **Prompt:** "Let's restart at your pace" with **Start quiz** / **Not now**. "Not now" re-prompt rule: TBD-12.
- **Length:** the short MVP quiz with **10 questions**, one per screen, progress shown as "n/10", **Next question** disabled until answered, Back from Q2.
  - **Q1 (fixed):** "What is your current fitness target?" — Muscle gain / Staying healthy / Look fit / No target.
  - **Q10 (fixed):** "Do you still want to push?" — Yes, progress the weight / No, same program as last / No, reduced intensity. Its button reads **See what changed**.
  - **Q2–Q9: wording TBD-10.** The MVP text requires the quiz to cover **target, energy, motivation**; the HTML prototype also asks days per week and today's energy (High / Normal / Low). Load questions from a typed `quizQuestions` config; use clearly marked placeholder questions covering those topics; **never present invented wording as final.**
- **Result flow (Improved pages):** Q10 → **"Why we changed your program"** explainer → **Adjusted program** preview → **Accept program** or **Keep my old program**. A later **Revert** to the previous version stays supported (I-13).
- **Ease-in rule (decided): when a weight reduction applies, target weights are reduced by 10–20% from the last load.** This replaces the 15–20% in the research docs and the 30% (70% of last load) in the HTML prototype. Cases that need no reduction (e.g., the user chooses to push) are allowed. Keep the mapping in a typed `easeInTable` config that is clamped to the 10–20% range. Which answers map to which percentage, whether sets/volume also drop, and whether weights ramp back up weekly (the Improved pages show a 4-week ramp) are **TBD-11 — ask before implementing the ramp.**
- Output also covers adjusted **session length, intensity, frequency** via the deterministic rule table (I-12).
- **Every quiz screen** shows: "Non-diagnostic quiz · used only to adjust your workouts" (I-10). Every attempt is stored (`incomplete` if abandoned).

### 8.5 Micro sessions (US-005, FR-090–099)
- Leaving an active workout with unfinished planned sets → **exit sheet**: **Save as micro session** / **Discard** (with confirm) / **Continue workout**.
- Saved micro session stores completed sets, total reps, volume, duration; shows a **Micro badge** in History; opening shows completed summary; **Resume** loads completed + remaining sets into an active workout.
- Duplicate saves of the same command → one record. Counts as a completed workout (calendar, monthly count, inactivity). Streak behavior TBD-16.

### 8.6 Set stitching (US-006, FR-100–108)
- History **selection mode**: exactly two sessions; eligibility rules (TBD-17) → disabled with reason if ineligible; **preview** of combined metrics; **confirm** creates parent; History shows **one expandable card** with the two children; **Unstitch** (confirm) restores both children; stitch/unstitch atomic; metrics counted once; progression policy (TBD-18) yields identical output stitched or not.
- Deleting a child referenced by an existing parent is rejected with a message naming the parent (NFR-020).

### 8.7 Foundation behaviors (EP-002)
- **Navigation/layout note:** screens and navigation follow the **Improved App Pages PDF** (BA-001). The SRS's separate *Start workout* screen (FR-021) is superseded: its actions map to **Home** (Empty workout, My programs incl. Adjusted program), **Discover** (Explore exercise), and **Add exercise** inside an active workout. Behavior and acceptance criteria of those actions are unchanged.
- **Login/Register:** email + password; register fields: username, email, password, confirm password, date of birth, terms checkbox (+ gender per BA-002). Messages: "Passwords do not match", "Please accept the terms", "Incorrect email or password". Accounts are local profiles; "Forgot password?" link is present but behavior TBD-02 (no email possible).
- **Home:** "Welcome back!" + username; current-month calendar marking days with completed workouts and today highlighted; monthly workout count; **Continue last workout?** (reopens most recent unfinished workout; none-exists behavior TBD-15); quiz entry control.
- **Programs:** 3 built-ins (Upper Lower, Push Pull Leg, Gorilla Training). Push Pull Leg = Dumbbell curl, Chest press, Tricep raise, Lateral pushdown, 3 sets × 10 kg, 2:00 rest. Edits require **Confirm edit?** (Yes/Cancel). Start-workout screen actions: Start empty program, Current program, All program, Adjusted program, Explore exercise.
- **Explore exercise:** cards with name, short description, add (+); from Start workout → "Add to which program?" sheet; from an active workout → adds to the workout. Initial catalogue ≥ Barbell shoulder press, Dumbbell shoulder press, Inverted plank, Dumbbell curl, Chest press, Tricep raise, Lateral pushdown.
- **Active workout:** table (Exercise, Set, Reps, Rest) with editable weight/reps; **Add more set?** (copies previous weight/rest), **Add another exercise?**, **Finish** → stores a full session → **Workout Completed** (Total Time mm:ss, Total Sets) → **Go to home page**.
- **Rest timer:** preset to planned rest; −15 s/+15 s (min 15 s) before start; **Set timer**; Pause/Resume/Skip; at 0:00 return to workout + 300 ms vibration where supported; Cancel before start. Sound TBD-27.
- **History:** reverse-chronological; case-insensitive search by program name updating per keystroke; "No workouts found"; detail view read-only; delete with confirmation; date format `YYYY-MM-DD HH:mm`; session named after its program or "Empty program".
- **Settings:** Display (light/dark, persisted), Personalization ("Coming soon"), About app (name + version).
- **Analytics (local):** common schema; events `quiz_prompt_shown, quiz_started, quiz_completed, program_accepted, next_workout_started, workout_quit, micro_session_saved, micro_session_discarded, workout_started_within_48h, stitch_started, stitch_preview_shown, stitch_confirmed, stitch_reversed`; user can turn recording off; no transmission.

---

## 9. UI and design system

> The high-fidelity HTML prototype in `Context/03-design/` is the **visual reference**. Reproduce the look, not the code.

### 9.1 Identity
- Name: **AtomFit**. Final tagline: **"Log it. Keep going."** (BA-006).
- Logo: the **panda** (round blue gradient badge in the HTML prototype) is a **placeholder**; the team will design the final logo later. Render it through one replaceable `Logo` component / single asset path so swapping it touches one place. Do not use the "AF" monogram.
- Tone: supportive, short, encouraging, never judgmental (I-11).

### 9.2 Design tokens (from the high-fidelity prototype; treat as the default theme)

| Token | Light | Dark |
|---|---|---|
| `--primary` | `#2563eb` | `#3b82f6` |
| `--primary-dark` | `#1d4ed8` | `#2563eb` |
| `--primary-light` | `#dbeafe` | `#1e3a8a` |
| `--bg` | `#f4f7fe` | `#0b1220` |
| `--card` | `#ffffff` | `#131c2e` |
| `--text` | `#0f172a` | `#e8eefc` |
| `--muted` | `#64748b` | `#94a3b8` |
| `--line` | `#e2e8f0` | `#24304a` |
| `--danger` | `#dc2626` | `#dc2626` |

- Font: **Plus Jakarta Sans** (400/600/800) with a system-ui fallback stack.
- Shape: rounded cards (≈ 18 px), buttons/inputs (≈ 12–14 px), pill buttons in header; header = blue gradient (`primary → primary-dark`) with white text; large full-width primary buttons; secondary = outlined.
- Layout: mobile frame ≤ 430 px; bottom navigation; sticky/safe-area aware (`env(safe-area-inset-*)`).
- Theme: honor `prefers-color-scheme`, with a manual override saved in settings (FR-012). Define colors as CSS variables only; never hard-code colors in components.

### 9.3 Navigation and global chrome (follows the Improved App Pages PDF + lecturer feedback — BA-001, BA-003)
- **Bottom navigation:** `Home | History | Discover | Profile`. **Home is leftmost.** On the Home screen, Home is **highlighted and unclickable** (`aria-current="page"`, no navigation). On other tabs, the current tab is highlighted and the others are clickable.
- **Top bar (Home):** title/clock area, **notification bell**, and a **three-dots (⋮) menu for system settings placed next to the bell** (opens Settings). The gear icon is not used. Profile is reached through the Profile tab, so there is no profile icon in the top bar.
- **Assumption (confirm):** the Improved pages' tabs (History, Discover, Profile) plus the lecturer's "Home at the very left" combine into these four tabs.
- **Start workout** is no longer a tab: Home carries **Empty workout** and **My programs**.

### 9.4 Screens
**Designed in `Atomic_Fit_Improved_App_Pages.pdf` (primary layout reference):** Login · Register · Home (calendar, Continue last workout, Empty workout, My programs) · Quiz prompt ("Let's restart at your pace") · Quiz question (n/10) · "Why we changed your program" · Adjusted program (Accept / Keep my old program) · My programs · Active workout (elapsed time, sets done, Add set, inline rest bar) · Rest timer · Rest timer lock-screen concept · Empty workout · Add exercise (search; All/Push/Pull/Legs) · Workout complete · History (All/Full/Micro filter) · Workout detail · Discover · Profile · Settings.
**No design yet — create from the MVP text using the same tokens:** Auto-count live counter (SCR-19) · Voice confirmation card (SCR-20) · Exit sheet (SCR-22) · Micro-session card + Resume (SCR-23) · Stitching selection + preview (SCR-24) · Stitched card + unstitch dialog (SCR-25).
SRS screen IDs (SCR-01…25) remain the traceability keys.

### 9.5 Elements in the Improved pages that are NOT yet in the requirements
Do **not** build these until the human approves them (backlog; ask first):

| Element | Why it is held |
|---|---|
| Units toggle (Metric/Imperial, kg/lbs) | Conflicts with I-20 (kg only in MVP) |
| Target weight field in Profile | Not in SRS profile fields |
| Personal records, total volume, volume-by-muscle chart on Workout complete | Not in SRS summary (FR-040 shows time and sets only) |
| Workout tags such as "Hypertrophy focus", "Active recovery" | Not in SRS |
| Settings toggles: Rest timer sound, Inactivity quiz reminder | Sound = TBD-27; reminder must not become a push notification (ASM-22) |
| Discover library with muscle groups and categories | SRS catalogue is minimal (TBD-20) |

---

## 10. Testing and verification
- Every FR has an acceptance criterion (AC-nnn). Implement them as tests: **Unit** (Vitest) for detector/parser/rule table/progression/inactivity/event schema; **Integration** (fake-indexeddb) for persistence, Save-Set, idempotency, atomic stitch/unstitch, migrations, time zones, termination; **E2E** (Playwright, mobile viewports); **Accessibility** (axe-core + manual quiz screen-reader pass); **Field tests** on real devices for rep accuracy, lock screen, noisy voice.
- Shared fixtures in `tests/fixtures/`: time-zone, offline, app-termination, recorded sensor signals, voice phrases, rule-table cases. Reuse them across features (NFR-044).
- Edge cases that must have tests: midnight-spanning sessions, time-zone changes, duplicate saves, force-close mid-set, storage-full error (message + keep data in memory, NFR-034), stitching eligibility/rollback, unstitch cleanup.

---

## 11. Known conflicts and open decisions (ask the human; do not decide silently)

### 11.1 Conflicts between sources and how they were settled

| # | Topic | Status | Decision / working default |
|---|---|---|---|
| C-1 | Inactivity threshold (7 vs 14 days) | **Resolved 2026-10-18** | **7 days** (config constant) |
| C-2 | Quiz length/content | **Resolved, partly open** | **Short MVP quiz, 10 questions**; Q1 and Q10 fixed; Q2–Q9 wording TBD-10 |
| C-3 | Quiz name | Settled by rule I-10 | User-facing "Quiz"/"Restart quiz" + non-diagnostic statement |
| C-4 | Ease-in amount | **Resolved 2026-10-18** | **10–20% lower weights**; mapping and weekly ramp TBD-11 |
| C-5 | Navigation order | **Resolved 2026-10-18** | **Home \| History \| Discover \| Profile** (Improved pages + lecturer; confirm) |
| C-6 | Settings entry | Settled (BA-003) | Three-dots next to the bell |
| C-7 | Auto-pause after 15 min idle | Open (default chosen) | **Exit-intercept only**; 15-min auto-pause = backlog |
| C-8 | Smartwatch | Settled | Out of MVP (ASM-22) |
| C-9 | Selected problem | Settled | `Problems_Detailed_Markdown.md` says the group chose the AI Validity Checker; all later work is AtomFit. **AtomFit is the product**; that file is background only |
| C-10 | Name | Settled | **AtomFit** (ASM-01) |
| C-11 | Delivery form | **Resolved 2026-10-18** | **PWA only** (I-09); lock-screen limits in 8.3 |
| C-12 | Improved pages vs SRS extras | Open | Section 9.5 items are held until approved |

### 11.2 TBD register (full list in SRS §4.3)
TBD-01 is an account needed at all? · TBD-02 forgot-password behavior · TBD-05 lock-screen feasibility/"+1 set" meaning · TBD-06 speech-to-text engine/offline · TBD-07 voice grammar + phrase list · TBD-08 supported auto-count exercises · TBD-09 reference device · TBD-10 wording of quiz Q2–Q9 (Q1 and Q10 fixed) · TBD-11 quiz rule table, safety limits · TBD-12 re-prompt rule · TBD-13 revert window · TBD-15 exit triggers / "continue" with nothing unfinished · TBD-16 streak behavior · TBD-17 stitching eligibility · TBD-18 progression policy · TBD-19 program content/edits · TBD-20 exercise catalogue · TBD-23 analytics dashboard · TBD-24 encryption feasibility · TBD-25 data-protection/retention · TBD-26 About/Personalization content · TBD-27 timer sound.

---

## 12. BEHAVIOR ADDENDA (human-extensible)

> **How to extend:** Add a new subsection at the end of this section using the template below. Addenda are *binding* once `Status: Approved`. An addendum may refine or add behavior but may **not** contradict Section 3; if it needs to, add a note to Section 14 and have the team update Section 3 deliberately.
> Agents: treat `Approved` addenda as higher priority than Sections 4–11. Treat `Proposed` addenda as hints only; ask before implementing.

### Template (copy this)

```markdown
### BA-XXX — <Short title>
- **Status:** Proposed | Approved | Superseded by BA-YYY
- **Date / Author:** YYYY-MM-DD / <name>
- **Area:** <screen, feature, or module>   **Related:** <US/FR/SCR/I-xx IDs>
- **Behavior:** <what the app must do, in testable "shall" sentences>
- **Acceptance criteria:** <Given / When / Then>
- **Out of scope / notes:** <optional>
```

### BA-001 — Navigation: Home | History | Discover | Profile, Home locked when active
- **Status:** Approved (tab combination is an assumption — confirm)
- **Date / Author:** 2026-10-18 / team (sources: IT lecturer feedback; decision to follow `Atomic_Fit_Improved_App_Pages.pdf`)
- **Area:** Bottom navigation, Home   **Related:** FR-015, FR-021, SCR-03, SCR-08, SCR-16
- **Behavior:** The bottom navigation shall list **Home, History, Discover, Profile** in that order, with **Home at the very left**. On the Home screen, Home shall be **highlighted and unclickable**. On other tabs, the current tab is highlighted and the others navigate normally. *Start workout* is not a tab; Home provides **Empty workout** and **My programs**.
- **Acceptance criteria:** Given the Home screen, then Home is first, highlighted, `aria-current="page"`, and tapping it does nothing. Given any other tab, then Home is first and tappable.
- **Out of scope / notes:** Supersedes the nav order in the prototypes and SRS FR-015/FR-021; the SRS needs a matching update.

### BA-002 — Gender field in registration and profile
- **Status:** Approved (option list is an assumption — confirm)
- **Date / Author:** 2026-10-18 / team (sources: IT lecturer feedback; team decision "both")
- **Area:** Register, Profile   **Related:** FR-001, FR-004, FR-008, FR-009, SCR-02, SCR-04
- **Behavior:** Both the **Register** screen and the **Profile** screen shall include a **gender** field. Assumption: single choice **Male, Female, Prefer not to say**; on Register it is optional (default "Prefer not to say"); stored with the account/profile; shown and editable on Profile.
- **Acceptance criteria:** Given a registration with a gender chosen, then it is stored and shown on Profile. Given an edit on Profile and Update Profile, then it persists and "Profile updated" is displayed.
- **Out of scope / notes:** Gender must **not** influence quiz rules, program adjustments, analytics logic, or any other behavior unless a future addendum says so.

### BA-003 — System settings as a three-dots menu next to the bell
- **Status:** Approved
- **Date / Author:** 2026-10-18 / team (source: IT lecturer feedback)
- **Area:** Top bar (Home, Quiz)   **Related:** FR-011, SCR-03, SCR-05, SCR-06
- **Behavior:** The top bar shall show a **three-dots (⋮) control for system settings directly next to the notification (bell) icon**. Selecting it opens Settings (Display, Personalization, About app). The gear icon shall not be used.
- **Acceptance criteria:** Given the Home screen, then ⋮ is adjacent to the bell and opens Settings.
- **Out of scope / notes:** The bell's behavior is TBD-29 (decoration in prototypes). Do not build notifications.

### BA-004 — Quiz parameters: 7 days, 10 questions, 10–20% ease-in
- **Status:** Approved (Q2–Q9 wording and mapping pending)
- **Date / Author:** 2026-10-18 / team
- **Area:** Re-engagement quiz   **Related:** US-004, FR-074–FR-089, TBD-10, TBD-11
- **Behavior:** (1) A user is inactive at **7 or more** local calendar days. (2) The quiz has **10 questions**; Q1 (fitness target) and Q10 ("Do you still want to push?") are fixed. (3) When the rule table applies a weight reduction it shall be **between 10% and 20%** of the last load. (4) The flow is Q10 → "Why we changed your program" → Adjusted program → Accept program / Keep my old program.
- **Acceptance criteria:** Given a last workout 7 days ago → quiz prompt; 6 days → none. Given any rule-table row that reduces weight, the result is within 10–20%. Given a completed quiz, the preview appears before anything is applied.
- **Out of scope / notes:** Whether sets also decrease and whether weights ramp back weekly are still open (TBD-11).

### BA-005 — PWA only; lock-screen quick-add is best-effort
- **Status:** Approved
- **Date / Author:** 2026-10-18 / team
- **Area:** Platform, US-003   **Related:** I-09, FR-069–FR-073, NFR-029, NFR-045
- **Behavior:** AtomFit ships as a PWA with no native wrapper. US-003 is delivered as an **in-app quick-add bar** plus a **best-effort service-worker notification with action buttons** where supported (feasibility spike first), as described in Section 8.3.
- **Acceptance criteria:** FR-070–FR-072 pass through the in-app control; the notification path is documented as supported / unsupported per browser after the spike.
- **Out of scope / notes:** No Capacitor, no Swift/Kotlin. If the team later wants a real lock-screen widget, that is a Section 3 change (I-09) made by a human.

### BA-006 — Branding: tagline and placeholder logo
- **Status:** Approved
- **Date / Author:** 2026-10-18 / team
- **Area:** Login, header, app manifest   **Related:** SCR-01, Section 9.1
- **Behavior:** The tagline is **"Log it. Keep going."** The **panda** is a **placeholder logo** until the team provides the final one. The logo is rendered by one `Logo` component / one asset path so replacement is a single change.
- **Acceptance criteria:** Given the Login screen, the tagline text matches exactly and the logo comes from the single replaceable asset.

<!-- ADD NEW ADDENDA BELOW THIS LINE, KEEP IDs SEQUENTIAL -->

---

## 13. When this file is not enough — the `Context/` folder

This file is deliberately condensed. If you need more detail than is here — exact acceptance criteria, rationale, research quotes, wireframe contents, prototype behavior — **read the `Context/` folder in the project root** (same level as this file) *before guessing*. Start with `Context/INDEX.md`, which describes every file and when to read it.

| Need | Read |
|---|---|
| Exact requirement wording, ACs, traceability | `Context/01-requirements/SOFTWARE_REQUIREMENTS_SPECIFICATION.md` |
| MVP story rationale, dev responsibilities per story | `Context/01-requirements/Comprehensive_Explanation_of_the_MVP.md`, `mvp_breakdown.md` |
| Full research, personas, journeys, items to reconcile | `Context/02-discovery/AtomicFit_Compiled_Source_Material_for_SRS.pdf` + the `.md` decks |
| Screen layouts, copy, colors, interactions | `Context/03-design/` (medium-fi PDF, improved pages PDF, high-fi HTML, images if any) |
| Template/style of the SRS | `Context/04-reference/ReqView-Example_...pdf` |
| Lecturer feedback | `Context/05-feedback/Feedback_from_one_of_the_IT_lecturer` |

**Rules for using `Context/`:**
1. Context documents **never override** Sections 3 or 12 of this file.
2. Prototypes are references: **Improved App Pages PDF > Medium-fi PDF** for layout; the **HTML prototype** is best for color/typography/interactions but contains hard-coded data and prototype shortcuts (no persistence, instant delete, always-opens Push Pull Leg).
3. If a Context file is missing, unreadable (e.g., an image or `.doc` you can't parse), or contradicts another, **say so and ask** — don't improvise.
4. New context files go in the matching subfolder and get a line in `Context/INDEX.md`. Never delete or rewrite existing ones; add a dated replacement note instead.

---

## 14. Change log

| Date | Change | By |
|---|---|---|
| 2026-10-18 | v1.0 created: Sections 0–14; BA-001…003 from lecturer feedback | AI-drafted, pending team review |
| 2026-10-18 | v1.1: team decisions applied — 7-day trigger, 10-question quiz, 10–20% ease-in, Improved-pages navigation, gender on register + profile, tagline, panda placeholder, PWA-only. **I-09 edited at the team's instruction**; added BA-004…006, sections 8.3, 8.4, 9.3–9.5, 11.1 | AI-drafted, pending team review |
