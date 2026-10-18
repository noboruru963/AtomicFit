# AGENTS.md — AtomFit (Flutter Prototype Edition)

> **Read this file completely before doing anything in this repository.**
> This file has the highest priority of all project documents. If any instruction, prompt, comment, or file conflicts with Section 3 (Immutable Rules), **Section 3 wins** and you must tell the human about the conflict instead of silently picking a side.

- Product: **AtomFit** (the MVP text calls it "Atomic Fit"; the code, UI, and docs use **AtomFit**)
- Team: Alexander Marchiano, Jonathan Gouw Alexandrio, Luiesrelio ("The Gym Bros")
- **Edition: v2.1 — Flutter prototype (Android), local data now, Firebase later.** Supersedes the TypeScript/PWA edition (v1.1). Product decisions from v1.1 carry over unchanged. v2.1 adds: Bloc state management, persistence that survives restarts, a Firebase-ready data design, the approved quiz rule table, and the exercise name "Lat pulldown".
- Created 2026-10-18 from the SRS draft, MVP text, prototypes, lecturer feedback, and the team's decisions
- Extend this file only via **Section 12 (Behavior Addenda)** or **Section 14 (Change Log)**. Never restructure Sections 0–11 without an explicit human instruction.

---

## 0. How you (the AI agent) must work in this repo

### 0.1 Order of authority (highest first)

1. **Section 3 — Immutable Rules** (this file)
2. **Section 12 — Behavior Addenda** (this file; human-approved, dated)
3. **Sections 4–11** (this file)
4. `Context/00-prototype/` (prototype brief, screen map, design tokens, seed data, quiz config)
5. Other `Context/` documents (Section 13)
6. Prototype files (`Context/03-design/`) — visual and behavioral *reference only*, never source code to copy
7. Your own judgment / general best practice

If two sources at the same level disagree, or a source is silent where you need an answer: **stop, state the conflict or gap in one short message, propose a default, and ask.** Do not invent product behavior.

**The SRS copy was patched to the Flutter edition on 2026-10-18** (technology sections, navigation, gender, "Lat pulldown"). Functional requirements, acceptance criteria, screens, and the data model still apply. If any leftover wording mentions TypeScript, React, Vite, Dexie/IndexedDB, Zod, Playwright, PWA, service workers, or Capacitor, **ignore it; this file wins.** The Flutter stack is in Sections 3 and 6.

### 0.2 Mandatory working protocol

1. **Before building a screen or feature**, read its row in `Context/00-prototype/SCREEN_MAP.md`, its entry in Section 8, and its FR/AC IDs in the SRS (`Context/01-requirements/`). Acceptance criteria equal the FR number (FR-053 → AC-053); NFR criteria are 100 + the NFR number.
2. **Domain code first, with tests.** Write or update tests alongside logic in `lib/domain/` (acceptance criteria are the first test cases).
3. **Mark assumptions** with `// ASSUMPTION:` (one-line reason), simulations with `// SIMULATED:`, placeholders with `// PLACEHOLDER (TBD-nn):`, and invented seed data with `// SEED PLACEHOLDER`. List them in your final message.
4. **Small, reviewable changes.** One screen or one concern at a time. No unrelated refactors.
5. **Never edit Section 3**, and never delete anything under `Context/`. If you think a rule must change, propose it in your reply; a human edits the file.
6. **Do not run `/init` or any command that regenerates AGENTS.md.**
7. **Before reporting, run:** `dart format .` · `flutter analyze` · `flutter test`. If the Flutter SDK or a device is unavailable in your environment, say so; **never claim checks passed that you did not run.**
8. **Finish with a short report:** what changed, which screens/FR/AC IDs are covered, tests added, assumptions, simulations, open questions.

### 0.3 Things you must never do

- Add a backend, network call, cloud service, analytics/crash SDK, or any Firebase package or config file (F-02, F-33).
- Add a package that is not on the allow-list in Section 6.1 without asking.
- Put business logic in widgets, or import Flutter/plugins into `lib/domain/` (F-03).
- Hard-code demo values (calendar days, counts, history) inside widgets (F-08).
- Present simulated hardware or invented data as real (F-09).
- Write medical, diagnostic, shaming, or guilt-inducing copy (F-10, F-11).
- Copy code from the HTML prototype (it is a throwaway, in-memory demo with hard-coded data).
- Invent exercises, quiz wording, rule tables, or eligibility rules marked **TBD**; implement the smallest replaceable config, mark it, and ask.

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

Each rule has an ID. Cite the ID in code comments or reports when a decision depends on it. SRS references in parentheses show where a rule comes from.

### 3.1 Platform and architecture

| ID | Rule |
|---|---|
| **F-01** | **Flutter (stable channel) with Dart 3 and sound null safety.** All app code is Dart. `analysis_options.yaml` enables `flutter_lints` plus `strict-casts`, `strict-inference`, and `strict-raw-types`. `flutter analyze` must report **zero issues**. No Kotlin/Swift/platform-channel code unless a Section 12 addendum approves it. |
| **F-02** | **Local-only for now; Firebase later.** No backend, no network calls, no cloud, no analytics/crash SDK, and **no Firebase packages or config files** in this edition. If a stretch plugin such as speech recognition may use the network on some devices, it stays behind a flag that is off by default. (FR-116, NFR-037) |
| **F-03** | **Layered architecture.** `lib/domain/` is **pure Dart: no `package:flutter` and no plugin imports.** `lib/data/` implements the repository/source interfaces defined in domain. `lib/features/` holds UI. Dependency direction: `features → domain`; `data → domain`; `app` wires everything; **`domain → nothing`**. Enforce with `test/architecture_test.dart`, which scans imports and fails on violations. |
| **F-04** | **One Save-Set service.** Manual entry, (simulated or real) auto-count, voice logging, and quick-add all persist sets through the single `SaveSetService`. No other code path creates or mutates set records. (FR-118) |
| **F-05** | **State and navigation:** `flutter_bloc` (Cubit for simple state, Bloc for event-driven flows) with `equatable`; `go_router` for navigation. State classes are **immutable**. `setState` is allowed only for ephemeral widget-local UI state (focus, animation, text controllers). Blocs depend on domain services and repositories, never on `lib/data/`. |
| **F-06** | **Local persistence behind interfaces.** Repositories and data sources are interfaces in `lib/domain/`. The implementation in `lib/data/local/` uses **sembast** (`path_provider` for the file location) and **data survives app restarts**. The first launch seeds demo data once from `lib/data/seed/`. Nothing outside `lib/data/local/` may import sembast. See `Context/00-prototype/STORAGE_AND_FIREBASE.md`. |
| **F-07** | **Idempotent IDs and all-or-nothing operations.** Every set and session has a client-generated UUID; saving an existing ID again does not duplicate. Save session, micro-save, stitch, unstitch, and apply program version are computed by pure domain functions and written in **one store transaction**; a failure leaves no partial change. (FR-098, FR-107, FR-119, NFR-019) |
| **F-08** | **No hard-coded data in widgets.** Calendar marks, counts, history rows, totals, and elapsed times are **derived from state**. Demo values exist only in `lib/data/seed/` (see `Context/00-prototype/SEED_DATA.md`). |
| **F-09** | **Simulations are honest.** Anything that fakes hardware or intelligence (motion sensor, microphone/speech, lock screen) sits behind a domain interface with a `Simulated*`/`Replay*`/`Typed*` implementation, is marked `// SIMULATED:`, and is listed in the report. Screens using a simulation show a small "Demo" label, controlled by one constant (`kShowDemoLabels`, default `true`). Never present simulated results as real sensing. |
| **F-33** | **Firebase-ready, Firebase-free.** Every stored record is user-scoped and has `id` (UUID), `userId`, `createdAtUtc`, `updatedAtUtc`, and optional `deletedAtUtc` (soft delete). Stored maps use plain JSON types only, with handwritten `toMap`/`fromMap`. Relationships are IDs, not joins. Multi-record operations stay small. A future `lib/data/firebase/` must be able to implement the same repository interfaces with no domain or UI change. |
| **F-34** | **Seed, version, reset.** Seed once on first launch (never overwrite existing data); store `schemaVersion` and `seedVersion` and run a documented migration when they change; a **Reset demo data** action exists **only in debug builds** (`kDebugMode`) and asks for confirmation (F-17). |

### 3.2 Product behavior

| ID | Rule |
|---|---|
| **F-10** | **The quiz is non-diagnostic.** It supports workout planning only, never a medical/psychological assessment. Every quiz screen shows: *"Non-diagnostic quiz · used only to adjust your workouts."* Never use words like "diagnose", "assessment of your health", "disorder". The user-facing name is **"Quiz"** or **"Restart quiz"**, never "Diagnostic Quiz". (FR-088) |
| **F-11** | **Zero-guilt language.** Never shame or nag; never frame partial work as "failed", "missed", "broken streak", or "incomplete" in user-facing text. Partial work is legitimate ("Micro session", "Saved"). |
| **F-12** | **Quiz adjustment is a deterministic, documented rule table.** No machine learning, no network, no randomness. Conflicts resolved by documented precedence; limits enforced. (FR-083, FR-084) |
| **F-13** | **The user stays in control of program changes.** A quiz adjustment is shown as a **preview**; applied only on **Accept** as a **new program version**; the previous version is retained and **revertable**. Nothing changes the Current program silently. (FR-085–087) |
| **F-14** | **Exactly one Current program per user.** (FR-026) |
| **F-15** | **Micro sessions are first-class.** A saved partial workout is a real session (`type = micro`, `completion_status = incomplete`), counts for the calendar, monthly count, and the inactivity rule, and can be resumed. (FR-092, FR-099) |
| **F-16** | **Stitching never double-counts and never mutates children.** A stitched session is a *parent* referencing exactly two *child* sessions; children keep their own data; each child's metrics count once in all totals; unstitch restores both children and prior totals; progression results are identical stitched or not. (FR-103, FR-105, FR-106, FR-108) |
| **F-17** | **Destructive actions need confirmation** (discard workout, delete session, unstitch, delete all data). (NFR-008) |
| **F-18** | **Auto-count and voice results are always correctable before saving.** Auto-count shows an editable final count plus +1/−1; voice shows a confirmation card (confirm/edit/cancel). Unparseable voice input shows a retry message and **saves nothing**. (FR-056, FR-057, FR-065, FR-066) |
| **F-19** | **Graceful degradation.** If a sensor, microphone, or notification capability is unavailable or permission is denied, show a clear message and keep **manual logging fully available**. (FR-050, FR-059, FR-061) |

### 3.3 Data and privacy

| ID | Rule |
|---|---|
| **F-20** | **Units:** weight in **kg** (decimal, 0–999.9, one decimal), reps whole 0–999, duration whole **seconds**, height **cm**. No unit selector. (ASM-07, ASM-08, NFR-021) |
| **F-21** | **Time:** timestamps stored as **UTC plus an IANA zone id**; a session belongs to the calendar day of its start in the stored zone. All "now" and zone lookups go through an injectable `Clock` (`SystemClock` in the app, `FixedClock` in tests). Seed dates are relative to the first-launch date. (FR-120, ASM-19) |
| **F-22** | **Raw sensor samples and raw audio are processed in memory only, never persisted.** (NFR-040) |
| **F-23** | **Local accounts only (Firebase Auth later).** Accounts live on the device behind an `AuthRepository` interface. Passwords are stored only as per-user salted hashes (prototype-grade, using `crypto`; this does not meet the slow-KDF requirement NFR-036, which Firebase Auth replaces); never plain text, never logged. The seeded demo user Joe123 is the only account that accepts any non-empty password (`// SEED PLACEHOLDER`). |
| **F-24** | **User text is plain text.** Never interpret user-entered text as markup or code. (NFR-035) |
| **F-25** | **Explain permissions before the OS prompt** (motion sensors, microphone, notifications). (NFR-041) |

### 3.4 UI and quality

| ID | Rule |
|---|---|
| **F-26** | **Theme-only styling.** Colors, typography, radii come from `ThemeData` built from the tokens in `Context/00-prototype/DESIGN_TOKENS.md`. **No `Color(0x…)` literals in widgets.** Light and dark themes both fully supported; contrast ≥ 4.5:1 (WCAG 2.2 AA). |
| **F-27** | **Mobile-first layout.** Primary target is a portrait phone 360–430 dp wide: **no RenderFlex overflow at 360 dp**, touch targets ≥ 48×48 dp. On wider screens, content is centered in a column of max width 430 dp. (NFR-002, NFR-005) |
| **F-28** | **All user-facing strings live in `lib/app/strings.dart`** (typed constants keyed by ID). English only; no hard-coded UI text in widgets. (NFR-007) |
| **F-29** | **Accessibility basics.** Icon-only buttons have tooltips/`Semantics` labels; the whole quiz flow is operable with a screen reader; selected states are exposed via `Semantics`. (NFR-004) |
| **F-30** | **Visual fidelity.** Screens must match the Improved App Pages layout and design tokens. Deviations need approval. Elements held in Section 9.5 are not built until approved. |
| **F-31** | **Do not invent requirements.** Where the SRS or this file says **TBD** or **Assumption**, implement the smallest replaceable thing behind typed config, mark it `// TBD-nn`, and report it. |
| **F-32** | **Quality gates.** `dart format` clean, `flutter analyze` zero issues, `flutter test` green. Domain logic (`lib/domain/`) targets ≥ 80% line coverage. (NFR-028, NFR-042) |

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
| **US-003** | Lock-screen quick add (+1 rep, +1 set) — prototype: in-app quick-add + concept screen, see 8.3 |

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
Firebase or any real backend (planned after the prototype: design for it, do not build it), native Kotlin/Swift code (unless a stretch addendum approves it), a guaranteed OS-level lock-screen widget, cloud sync, social features, wearable/smartwatch integration, nutrition tracking, payments/subscriptions, push notifications, administrator role, analytics dashboards (events are recorded locally; dashboards are Future), data export (JSON/CSV is Future), profile-picture change (Future), password-reset email (impossible locally), Personalization settings (shows "Coming soon").

### 5.3 Ideas from research that are **not** MVP (backlog only; do not implement without an Addendum)
Weekly Rep/Volume Bucket, "Save Point" resume widget (partially covered by US-005), Seasons / "Welcome Back" framing, "Pause" history log, charts/graphs, exercise demo videos/GIFs, cardio recording, onboarding tour, peer support.

### 5.4 MoSCoW totals (from SRS §4.1)
Must: 78 FR / 15 NFR in MVP. Should: 44 FR / 29 NFR. Could: 3 FR / 1 NFR in MVP (+ Future items). Won't: FR-014.

### 5.5 What "prototype" means in this edition
The deliverable is a **clickable Flutter prototype** that demonstrates the whole MVP story, not a production app. **Real:** UI, navigation, state, and all domain logic that is cheap to build and test (quiz engine, inactivity, program versions, micro sessions, stitching, rep detection on recorded signals, voice phrase parsing, Save-Set). **Simulated by default:** motion sensor, microphone, lock screen. **Persisted:** data is stored locally on the device and survives restarts. **Stretch (needs approval):** real sensors, real speech recognition, Android notification quick-add. Tiers and the demo script are in `Context/00-prototype/PROTOTYPE_BRIEF.md`.

---

## 6. Architecture (binding)

### 6.1 Layers and allowed packages

| Layer | Responsibility | Technology | Status |
|---|---|---|---|
| App shell | Router, theme, strings, bottom nav, top bar, dependency wiring | `go_router`, `flutter_bloc` (providers), `ThemeData` from tokens | Fixed |
| Features (UI) | Screens, widgets, and one Bloc/Cubit per feature | Flutter, Material 3, `flutter_bloc`, `equatable` | Fixed |
| **Domain** | Models, services, rules, repository/source **interfaces**, `Clock` | **Pure Dart** (no Flutter, no plugins) | **Fixed (F-03)** |
| Data | Local repositories (sembast), seed data, simulated/replay sources | Dart, `sembast`, `path_provider` | Fixed |
| Testing | Unit, bloc, widget, flow, architecture tests | `flutter_test`, `bloc_test`, `integration_test` (SDK) | Fixed |

**Package allow-list (do not add others without asking; pin versions in `pubspec.lock`):**
- Runtime: `flutter_bloc`, `bloc`, `equatable`, `go_router`, `uuid`, `intl`, `sembast`, `path_provider`, `crypto` (salted hashing for local accounts), `flutter_timezone` (IANA zone id on Android)
- Stretch only: `sensors_plus`, `speech_to_text`, `flutter_local_notifications`
- Dev: `flutter_lints`, `flutter_test`, `bloc_test`, `integration_test`
- **Not allowed without approval:** Firebase packages (`firebase_*`, `cloud_firestore`), code generators (`freezed`, `json_serializable`, `build_runner`, `drift`), analytics/crash SDKs, networking packages. Write immutable classes by hand (`final` fields, `copyWith`, `toMap`/`fromMap`).
- Fonts: bundle Plus Jakarta Sans under `assets/fonts/`; do not fetch fonts at runtime.

### 6.2 Project structure

```
atomfit/                       (Flutter project root; AGENTS.md and Context/ live here)
├─ AGENTS.md
├─ Context/
├─ pubspec.yaml
├─ analysis_options.yaml
├─ assets/
│  ├─ fonts/                   (Plus Jakarta Sans)
│  └─ images/                  (logo placeholder: panda)
├─ lib/
│  ├─ main.dart
│  ├─ app/                     (app.dart, router.dart, strings.dart, theme/, shell/)
│  ├─ domain/
│  │  ├─ models/               (User, Program, ProgramVersion, Exercise, Session, SetLog, QuizAttempt, …)
│  │  ├─ services/             (SaveSetService, SessionService, StitchingService, InactivityService,
│  │  │                         ProgramVersionService, ProgressionPolicy, AnalyticsLog)
│  │  ├─ rules/                (quiz_questions.dart, ease_in_table.dart, QuizRuleEngine, RepDetector, VoiceParser)
│  │  ├─ sources/              (MotionSource, SpeechSource interfaces)
│  │  ├─ repositories/         (interfaces)
│  │  └─ clock.dart
│  ├─ data/
│  │  ├─ local/                 (sembast repository implementations)
│  │  ├─ seed/                 (all demo data)
│  │  └─ simulated/            (SimulatedMotionSource, ReplayMotionSource, TypedSpeechSource)
│  └─ features/                (auth, home, quiz, programs, workout, rest_timer, history, discover,
│                               profile, settings, microsession, stitching, autocount, voice, lockscreen)
└─ test/
   ├─ architecture_test.dart
   ├─ domain/                  (unit tests, one file per service/rule)
   ├─ features/                (widget tests for key interactions)
   └─ fixtures/                (signals/, voice phrases, rule-table cases, clock/zone cases)
```
Screen-to-file mapping lives in `Context/00-prototype/SCREEN_MAP.md`; keep both in sync.

### 6.3 Implementation rules of thumb
- Widgets read state through `BlocBuilder`/`BlocListener`/`context.select` and send events to Blocs; they never touch repositories or sources directly.
- Blocs/Cubits hold immutable state and delegate decisions to domain services. Services are plain Dart, constructed with their dependencies, and trivially testable with fakes. Use `bloc_test` for Bloc tests.
- **Rep detection:** `MotionSource` stream → smoothing filter → peak detection (threshold + minimum interval) → count. Parameters are **per-exercise config objects**. Default source is simulated/replay; the detector itself is real and tested on fixtures.
- **Voice:** `SpeechSource` text → `VoiceParser` → `ParsedSet {exercise, reps, weight?}` or `ParseError` → confirmation card → `SaveSetService`.
- **Quiz:** answers → `QuizRuleEngine` (table + precedence + safety limits) → `Adjustment` → preview → Accept → new `ProgramVersion`. Questions and ease-in table are typed config (`Context/00-prototype/QUIZ_CONFIG.md`).
- **Rest timer:** compute remaining time from a stored end `DateTime` using the injected clock, not by counting ticks, so it stays correct when the app is backgrounded. Vibration (300 ms) is optional/best-effort.
- One **preview-and-confirm** pattern widget is shared by Quiz and Stitch (NFR-044 spirit: reuse).
- Prefer pure functions; inject `Clock` and zone for testability; never call `DateTime.now()` outside `SystemClock`.

### 6.4 Prototype quality targets (relaxed from the SRS; ASM-13)
Smooth scrolling on an emulator (no visible jank in lists of ≤ 100 items); screen transitions feel instant; Save-Set and rule-engine calls are fast on local data; live counter updates immediately on each simulated rep; rest timer error ≤ 1 s over 120 s; auto-count accuracy is tested on **fixtures** (clean 10-rep signal counts 10; double peak inside the minimum interval counts once). Real-device accuracy (NFR-018) applies only if the sensor stretch is approved.

---

## 7. Data model (informative; attribute names are proposals)

> Prototype note: model these as plain immutable Dart classes in `lib/domain/models/`. Persist them through repository interfaces into sembast stores (key = UUID); add `userId`, `createdAtUtc`, `updatedAtUtc`, and optional `deletedAtUtc` to every record (F-33). Ignore database-specific wording in the SRS (IndexedDB, Dexie). Details: `Context/00-prototype/STORAGE_AND_FIREBASE.md`.

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
| `set_log` | id (client UUID), session_id, exercise_id, set_no, weight_kg, reps, rest_s, input_method (manual/sensor/voice/lockscreen), logged_at_utc | **Written only via Save-Set (F-04)** |
| `stitched_session` | parent_session_id, child_session_ids (2), combined_sets/reps/volume_kg/duration_s | Children keep their own `set_log` rows |
| `quiz_attempt` | id, user_id, started_at_utc, status (complete/incomplete) | |
| `quiz_answer` | id, quiz_attempt_id, question_key, answer_key | |
| `user_program_adjustment` | id, quiz_attempt_id, program_version_from/to, session_length, intensity, frequency, accepted, reverted | |
| `analytics_event` | id, name, timestamp_utc, anon_user_id, session_id, properties(JSON) | Local only |

**Definitions:** Volume = Σ(weight × reps) over completed sets. A *completed set* on the summary screen = a set with ≥ 1 rep. Inactive user = most recent completed workout (full or micro) started ≥ 7 local calendar days ago. Every record carries created/updated UTC timestamps.

---

## 8. Feature behavior spec (condensed; full detail in the SRS)

> **Behavior** → key FR/AC IDs. Fidelity: **Real** = real logic; **Sim** = simulated input; **UI** = interface only. **TBD** needs a human decision (Section 11).

### 8.0 Fidelity summary

| Feature | Fidelity |
|---|---|
| Quiz, program versions, inactivity | Real |
| Manual logging, rest timer, history, discover, profile, settings | Real (persisted locally) |
| Micro sessions, stitching | Real |
| Auto-count | Real detector, **Sim** motion input (stretch: real sensors) |
| Voice logging | Real parser, **Sim** speech input (stretch: real speech) |
| Lock-screen quick add | Real in-app bar + **UI** concept screen (stretch: Android notification) |
| Auth | UI + validation, local accounts (Firebase Auth later) |

### 8.1 Automatic repetition counting (US-001, FR-049–059)
- Start set for a selected exercise → live counter at 0 → each detected rep updates the counter; stop → editable final count; **+1/−1** steppers (never below 0); save through Save-Set.
- **Prototype input:** a "Simulate rep" button and "Replay sample signal" (fixture) feed the real `RepDetector`. Label the screen with the Demo chip (F-09).
- Permission explanation shown before any real sensor request (F-25); on denial or when sensors are unavailable, or 0 reps counted → error message + manual entry (F-19).
- Counter text ≥ 48 sp, visible with controls without scrolling at 360×640 dp (NFR-009).
- Proposed supported exercises (ASM-11, TBD-08): squat, bench/chest press, dumbbell curl, dumbbell shoulder press, tricep raise.

### 8.2 Voice logging (US-002, FR-060–068)
- Mic button on the active workout → (explain permission) → listening indicator → text → **parser** → **confirmation card** (exercise, reps, optional weight; confirm / edit / cancel).
- **Prototype input:** a text field plus sample chips ("10 reps squat", "squat 10 reps 60 kilos", "hello there"). Real speech recognition is stretch.
- Examples: "10 reps squat" → squat, 10, no weight; "squat 10 reps 60 kilos" → weight 60 kg. Full grammar TBD-07. English only.
- Unparseable → retry message, **nothing saved**.

### 8.3 Quick add and lock screen (US-003, FR-069–073)
- **Real:** an in-app **quick-add bar** on the active workout with large **+1 rep** and **+1 set**; each tap saves immediately via Save-Set; the displayed count matches; counts survive leaving the screen and app restarts.
- **UI:** a lock-screen **concept screen** (from the Improved pages) shown as a mock; label it as a concept. The rest timer's "Show on lock screen" is the same concept.
- **Stretch:** Android persistent notification with +1 rep / +1 set actions via `flutter_local_notifications`; iOS Live Activity requires native Swift and is **out** unless approved.
- FR-069's criterion (control visible while the device is locked) is **not met** in the default prototype; report it as concept-only. Meaning of "+1 set" is TBD-05.

### 8.4 Re-engagement quiz (US-004, FR-074–089, BA-004)
- **Trigger:** on Home when inactive **7 or more local calendar days** (`INACTIVITY_THRESHOLD_DAYS = 7`), evaluated with the injected clock. Prompt: **"Let's restart at your pace"** with **Start quiz** / **Not now** ("Not now" re-prompt rule TBD-12). Dev-only flag may also show it for new accounts; off by default.
- **10 questions**, one per screen, "n/10", **Next question** disabled until answered, Back from Q2. **Q1 fixed** (target) and **Q10 fixed** ("Do you still want to push?", button **See what changed**). **Q2–Q9 wording is TBD-10:** use the marked candidates/placeholders in `QUIZ_CONFIG.md`.
- **Flow:** Q10 → **"Why we changed your program"** → **Adjusted program** preview → **Accept program** or **Keep my old program**. Revert later restores the previous version (F-13).
- **Ease-in (decided; rule table approved 2026-10-18):** when a reduction applies it is **10–20%** below last load, using the approved table in `QUIZ_CONFIG.md` (Low energy 20%, Normal 15%, High 10%, only when the user answers *No, reduced intensity*; the other Q10 answers apply 0%). By approving the table as written, the prototype applies **no set reduction and no weekly ramp-back**; flag this assumption and ask before adding either (TBD-11). Keep the table as typed config clamped to 10–20%.
- Every screen shows the non-diagnostic footer (F-10). Every attempt is stored (`incomplete` if abandoned).

### 8.5 Micro sessions (US-005, FR-090–099)
- Leaving an active workout with unfinished planned sets → **exit sheet**: **Save as micro session** / **Discard** (with confirm) / **Continue workout**.
- Saved micro session stores completed sets, reps, volume, duration; History shows a **Micro badge**; opening shows the completed summary; **Resume** loads completed + remaining sets into an active workout.
- Repeating the same save command creates one record (F-07). Counts as a completed workout for calendar, monthly count, inactivity. Streaks TBD-16.

### 8.6 Set stitching (US-006, FR-100–108)
- History **selection mode**: exactly two sessions; eligibility rules (TBD-17; draft default: both sessions complete or micro and started on the same local calendar day) → disabled with reason if ineligible; **preview** of combined metrics; **confirm** creates the parent; History shows **one expandable card** with the two children; **Unstitch** (confirm) restores both children and prior totals.
- Atomic (F-07); metrics counted once (F-16); progression policy (TBD-18) is identity in the prototype and must return identical output stitched or not. Deleting a child referenced by a parent is rejected with a message naming the parent (NFR-020).

### 8.7 Foundation behaviors (EP-002)
- **Navigation/layout:** follows the Improved pages (BA-001). The SRS's separate *Start workout* screen (FR-021) is superseded: its actions map to **Home** (Empty workout, My programs incl. Adjusted program), **Discover** (Explore exercise), and **Add exercise** inside an active workout.
- **Login/Register:** email + password; register fields: username, email, password, confirm password, date of birth, **gender (BA-002)**, terms checkbox. Messages: "Passwords do not match", "Please accept the terms", "Incorrect email or password". Local accounts stored on the device (seeded demo user Joe123); "Forgot password?" is visible with behavior TBD-02; Firebase Auth replaces this later.
- **Home:** "Welcome back!" + username; current-month calendar derived from sessions with today highlighted; monthly count; **Continue last workout** (most recent unfinished workout; none-exists behavior TBD-15); **Empty workout**; **My programs**; quiz prompt when inactive.
- **Programs:** 3 built-ins (Upper Lower, Push Pull Leg, Gorilla Training); Push Pull Leg = Dumbbell curl, Chest press, Tricep raise, Lat pulldown, 3 sets × 10 kg, 2:00 rest. Edits require **Confirm edit?**.
- **Discover / Add exercise:** exercise cards with name, muscles, short description, add (+); from an active workout, adding returns to the workout. Initial catalogue ≥ the seven exercises in `SEED_DATA.md`.
- **Active workout:** table with editable weight/reps, **Add set** (copies previous weight/rest), **Add exercise**, **Finish** → full session stored → **Workout complete** (Total Time mm:ss, Total Sets) → home.
- **Rest timer:** preset to planned rest; −15 s/+15 s (min 15 s) before start; Set timer; Pause/Resume/Skip; at 0:00 return to workout; Cancel before start.
- **History:** reverse-chronological; filter All/Full/Micro; case-insensitive search by name; "No workouts found"; detail read-only; delete with confirmation; date format `YYYY-MM-DD HH:mm`; session named after its program or "Empty workout".
- **Profile:** username, email, date of birth, **gender**, weight, height; **Update profile** → "Profile updated"; **Log out**.
- **Settings** (via ⋮): Appearance light/dark, Personalization ("Coming soon"), About app (name + version). **Debug builds only:** Reset demo data (with confirmation).
- **Persistence:** all data survives app restarts (sembast; see `Context/00-prototype/STORAGE_AND_FIREBASE.md`); the first launch seeds demo data once.
- **Analytics:** optional locally stored event log using the common schema (FR-125–128); no transmission; dashboards are Future.

---

## 9. UI and design system

> The Improved App Pages PDF is the **layout** reference; the HTML prototype supplies **tokens/typography**. Reproduce the look in Flutter, not the code. Full token tables and a theme starting point are in `Context/00-prototype/DESIGN_TOKENS.md`.

### 9.1 Identity
- Name **AtomFit**. Final tagline: **"Log it. Keep going."** (BA-006).
- Logo: the **panda** is a **placeholder** until the team provides the final logo. Render it through one `AtomLogo` widget reading one asset path; do not use the "AF" monogram.
- Tone: supportive, short, encouraging, never judgmental (F-11).

### 9.2 Design tokens (summary)

| Token | Light | Dark |
|---|---|---|
| primary | `#2563EB` | `#3B82F6` |
| primaryDark | `#1D4ED8` | `#2563EB` |
| primaryLight | `#DBEAFE` | `#1E3A8A` |
| background | `#F4F7FE` | `#0B1220` |
| card/surface | `#FFFFFF` | `#131C2E` |
| text | `#0F172A` | `#E8EEFC` |
| muted | `#64748B` | `#94A3B8` |
| line | `#E2E8F0` | `#24304A` |
| danger | `#DC2626` | `#DC2626` |

Font **Plus Jakarta Sans** (400/600/800, bundled). Cards radius ≈ 18 dp; buttons/inputs ≈ 12–14 dp; header = gradient `primary → primaryDark` with white text; primary buttons full width; secondary outlined; destructive outlined in danger. Honor the system light/dark setting, with a manual override in Settings (FR-012).

### 9.3 Navigation and global chrome (Improved pages + lecturer feedback — BA-001, BA-003)
- **Bottom navigation:** `Home | History | Discover | Profile`. **Home is leftmost.** On the Home screen, Home is **highlighted and not tappable** (`Semantics(selected: true)`, no navigation). Elsewhere the current tab is highlighted and the others navigate.
- **Top bar (Home):** title/clock area, **notification bell**, and a **three-dots (⋮) menu placed next to the bell** that opens Settings. No gear icon, no profile icon (Profile is a tab). The bell is decoration (TBD-29); build no notifications feature.
- **Assumption (confirm):** the Improved pages' tabs plus the lecturer's "Home at the very left" combine into these four tabs. *Start workout* is not a tab.

### 9.4 Screens
All routes, files, sources, and tiers are in `Context/00-prototype/SCREEN_MAP.md`. **Designed in the Improved pages:** Login · Register · Home · Quiz prompt · Quiz question (n/10) · "Why we changed your program" · Adjusted program · My programs · Active workout · Rest timer · Rest timer lock-screen concept · Empty workout · Add exercise · Workout complete · History · Workout detail · Discover · Profile · Settings. **No design yet (create from the MVP text with the same tokens):** auto-count live counter, voice confirmation card, exit sheet, micro-session detail/resume, stitching selection + preview, stitched card + unstitch dialog.

### 9.5 Elements in the Improved pages that are NOT yet in the requirements
Do **not** build these until the human approves them:

| Element | Why it is held |
|---|---|
| Units toggle (Metric/Imperial) | Conflicts with F-20 (kg only) |
| Target weight in Profile | Not in SRS profile fields |
| Personal records, total volume, volume-by-muscle chart on Workout complete | Not in SRS summary (FR-040 shows time and sets only) |
| Workout tags such as "Hypertrophy focus", "Active recovery" | Not in SRS |
| Settings toggles: rest-timer sound, inactivity-quiz reminder | Sound = TBD-27; reminder must not become a push notification (ASM-22) |
| Discover library with richer categories | SRS catalogue is minimal (TBD-20) |

---

## 10. Testing and verification
- **Unit tests (`test/domain/`, required):** inactivity (6 vs 7 days, midnight, zone), quiz rule table rows and 10–20% bound, program accept/revert, Save-Set idempotency, micro-session save/resume/duplicate save, stitch/unstitch (totals unchanged, children unmodified, rollback on failure), rep detector on fixtures (clean, noisy, double-peak), voice parser (samples and "hello there"), volume math.
- **Architecture test:** `test/architecture_test.dart` fails if `lib/domain/` imports Flutter or any plugin, or if `features/` imports `data/` directly.
- **Bloc tests (`bloc_test`):** quiz flow (answer gating, result, accept/revert), active workout (add set, save via Save-Set), history (filter, select two, stitch, unstitch), auth (validation, wrong password).
- **Persistence tests:** repository contract tests against a temporary/in-memory sembast database: idempotent save, soft-delete exclusion, forced-failure rollback for stitch/unstitch, **data present after reopening the database**, seed runs once, migration path, local auth stores a salt and hash and no plain text.
- **Widget tests (P0/P1 screens):** Home tab is highlighted and not tappable on Home; quiz Next disabled until answered; non-diagnostic footer present on quiz screens; exit sheet options; History filter and delete confirmation; voice confirmation card; auto-count +1/−1 floor at 0; gender field on Register and Profile.
- **Flow test (optional, `integration_test`):** the demo script from `PROTOTYPE_BRIEF.md`.
- **Layout checks:** key screens pump at 360 dp wide in light and dark themes without overflow.
- **Fixtures** in `test/fixtures/` (signals, phrases, rule cases, clock/zone cases); reuse across features.

---

## 11. Known conflicts and open decisions (ask the human; do not decide silently)

### 11.1 Conflicts between sources and how they were settled

| # | Topic | Status | Decision / working default |
|---|---|---|---|
| C-1 | Inactivity threshold | **Resolved** | **7 days** (config constant) |
| C-2 | Quiz length/content | **Resolved, partly open** | **10-question short quiz**; Q1, Q10 fixed; Q2–Q9 wording TBD-10 |
| C-3 | Quiz name | Settled (F-10) | User-facing "Quiz"/"Restart quiz" + non-diagnostic statement |
| C-4 | Ease-in amount | **Resolved** | **10–20% lower weights**; mapping and weekly ramp TBD-11 |
| C-5 | Navigation order | **Resolved** | **Home \| History \| Discover \| Profile** (Improved pages + lecturer; confirm) |
| C-6 | Settings entry | Settled (BA-003) | Three-dots next to the bell |
| C-7 | Auto-pause after 15 min idle | Open (default chosen) | **Exit-intercept only**; 15-min auto-pause = backlog |
| C-8 | Smartwatch | Settled | Out of scope (ASM-22) |
| C-9 | Selected problem | Settled | `Problems_Detailed_Markdown.md` says the group chose the AI Validity Checker; all later work is AtomFit. **AtomFit is the product** |
| C-10 | Name | Settled | **AtomFit** (ASM-01) |
| C-11 | Delivery form | **Resolved (v2)** | **Flutter prototype** replaces the TypeScript/PWA plan (BA-007) |
| C-12 | Improved pages vs SRS extras | Open | Section 9.5 items held until approved |
| C-13 | SRS technology sections | **Updated** | The SRS copy in `Context/01-requirements/` was patched to the Flutter edition; where leftover wording conflicts, this file wins |
| C-14 | Backend | Settled (BA-009) | Local data now; Firebase planned later (design for it, do not build it) |
| C-15 | Exercise name | Settled (BA-011) | **Lat pulldown** (not Lateral pushdown) |

### 11.2 Prototype decisions the agent assumed (confirm with the human)
| # | Assumption | Default used |
|---|---|---|
| P-1 | State management and routing | **`flutter_bloc` (decided)**; `go_router` for navigation (assumed) |
| P-2 | Persistence | **Local, survives restarts (decided)**; **sembast** chosen by the agent — confirm |
| P-3 | Target platform | **Android phone (decided)**; iOS and web are not targeted |
| P-4 | Hardware | Simulated by default; a real Android phone is available, so real sensors/speech/notifications are feasible stretch items — ask before promoting any |
| P-5 | Package policy | Allow-list in 6.1; no code generation; no Firebase packages |
| P-6 | Clock and seed dates | `SystemClock`; seed dates relative to first launch (see SEED_DATA.md) |

### 11.3 TBD register (full list in SRS §4.3)
TBD-01 is an account needed at all? · TBD-02 forgot-password behavior · TBD-05 meaning of "+1 set" / lock-screen approach · TBD-06 speech engine (stretch only) · TBD-07 voice grammar + phrase list · TBD-08 supported auto-count exercises · TBD-10 wording of quiz Q2–Q9 (Q1 and Q10 fixed) · TBD-11 weekly ramp-back and set reduction (rule table approved, BA-010) · TBD-12 re-prompt rule · TBD-13 revert window · TBD-15 exit triggers / "continue" with nothing unfinished · TBD-16 streak behavior · TBD-17 stitching eligibility · TBD-18 progression policy · TBD-19 program content/edits · TBD-20 exercise catalogue · TBD-26 About/Personalization content · TBD-27 timer sound · TBD-29 bell behavior.

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

### BA-005 — PWA-only decision (SUPERSEDED)
- **Status:** Superseded by BA-007 (2026-10-18)
- **Notes:** The v1.1 decision "PWA only; no native wrapper; lock-screen quick-add best-effort via service worker" no longer applies because the project now targets a Flutter prototype. Do not implement service workers, PWA manifests, or web-notification flows. The lock-screen handling for this edition is in Section 8.3.

### BA-006 — Branding: tagline and placeholder logo
- **Status:** Approved
- **Date / Author:** 2026-10-18 / team
- **Area:** Login, header, launcher icon   **Related:** SCR-01, Section 9.1
- **Behavior:** The tagline is **"Log it. Keep going."** The **panda** is a **placeholder logo** until the team provides the final one. The logo is rendered by one `Logo` component / one asset path so replacement is a single change.
- **Acceptance criteria:** Given the Login screen, the tagline text matches exactly and the logo comes from the single replaceable asset.

### BA-007 — Delivery pivot: Flutter prototype instead of a working TypeScript app
- **Status:** Approved
- **Date / Author:** 2026-10-18 / team
- **Area:** Platform, scope   **Related:** F-01…F-09, Section 5.5, `Context/00-prototype/`
- **Behavior:** The deliverable is a **Flutter prototype** (clickable, with real domain logic where cheap and simulated hardware by default), not a working TypeScript/React PWA. The TypeScript stack, repo layout, and PWA/Capacitor decisions from v1.x are retired. Product behavior, personas, quiz decisions, navigation, and branding carry over.
- **Acceptance criteria:** Given the demo script in `PROTOTYPE_BRIEF.md`, a viewer completes it on an Android emulator or phone with no dead ends; `flutter analyze` reports zero issues and `flutter test` passes.
- **Out of scope / notes:** The SRS needs a technology-section update (C-13). If the team later wants a production app, that is a new addendum.

### BA-008 — Prototype fidelity rules (Real vs Simulated)
- **Status:** Approved
- **Date / Author:** 2026-10-18 / team
- **Area:** Auto-count, voice, lock screen, auth, persistence   **Related:** F-08, F-09, `PROTOTYPE_BRIEF.md` §5
- **Behavior:** Auto-count motion input, voice/speech input, and lock-screen behavior are **simulated** by default behind domain interfaces; auth is a local-account mock (Firebase Auth later); data is persisted locally and seeded once on first launch. Domain logic (rep detector on fixtures, voice parser, quiz engine, micro sessions, stitching, Save-Set) is **real** and unit-tested. Simulated screens show a "Demo" label (`kShowDemoLabels`).
- **Acceptance criteria:** Given a simulated screen, the Demo label is visible and the code carries a `// SIMULATED:` marker; given the architecture test, no domain file imports Flutter or plugins.
- **Out of scope / notes:** Real sensors, speech recognition, and Android notification actions are stretch items that require explicit approval.

### BA-009 — Local persistence now, Firebase later
- **Status:** Approved
- **Date / Author:** 2026-10-18 / team
- **Area:** Data layer, auth   **Related:** F-02, F-06, F-33, F-34, `Context/00-prototype/STORAGE_AND_FIREBASE.md`
- **Behavior:** Data is stored locally (sembast) and **persists across app restarts**. A Firebase backend (Authentication and database) is planned **later**. The data layer is built behind repository interfaces so a Firebase implementation can replace it with no domain or UI change. No Firebase code, packages, or config files now.
- **Acceptance criteria:** Given sets, sessions, and an accepted program version saved, when the app is force-closed and reopened, then they are still present. Given a first launch, the seed runs once. Given the architecture test, only `lib/data/local/` imports sembast.
- **Out of scope / notes:** Sync, conflict resolution, security rules, and migration of local data to a signed-in account belong to the later Firebase phase.

### BA-010 — Quiz rule table approved
- **Status:** Approved (Q2–Q9 wording still open, TBD-10)
- **Date / Author:** 2026-10-18 / team
- **Area:** Re-engagement quiz   **Related:** BA-004, F-12, F-13, `Context/00-prototype/QUIZ_CONFIG.md`, TBD-11
- **Behavior:** The rule table in `QUIZ_CONFIG.md` Section 3 is approved. Precedence: *Yes, progress the weight* → 0% reduction, intensity progress; *No, same program as last* → 0%, same; *No, reduced intensity* → energy-based reduction (Low 20%, Normal 15%, High 10%), intensity lighter. Frequency comes from days per week, capped at 5. Session length is short when energy is Low or motivation is lowest. Progress step defaults to +2.5 kg. Weights round to the nearest 0.5 kg. **Assumptions made by approving as written:** no set reduction and no weekly ramp-back.
- **Acceptance criteria:** Each table row yields the expected adjustment; any reduction is within 10–20%; preview never changes the Current program; Accept creates a new version and keeps the old one.
- **Out of scope / notes:** Weekly ramp-back and set reduction need a new addendum.

### BA-011 — Exercise name: "Lat pulldown"
- **Status:** Approved
- **Date / Author:** 2026-10-18 / team
- **Area:** Exercise catalogue, programs   **Related:** FR-022, FR-028, `SEED_DATA.md`
- **Behavior:** The back exercise is named **"Lat pulldown"** everywhere (catalogue, Push Pull Leg program, pickers). "Lateral pushdown" in the SRS is replaced.
- **Acceptance criteria:** Given the Push Pull Leg program, its exercises are Dumbbell curl, Chest press, Tricep raise, Lat pulldown.

<!-- ADD NEW ADDENDA BELOW THIS LINE, KEEP IDs SEQUENTIAL -->

---

## 13. When this file is not enough — the `Context/` folder

This file is deliberately condensed. If you need more detail than is here — exact acceptance criteria, rationale, research, wireframe contents, prototype behavior — **read the `Context/` folder in the project root** (same level as this file) *before guessing*. Start with `Context/INDEX.md`.

| Need | Read |
|---|---|
| What the prototype must demonstrate, scope tiers, demo script, real vs simulated | `Context/00-prototype/PROTOTYPE_BRIEF.md` |
| Routes, files, sources, and tier per screen | `Context/00-prototype/SCREEN_MAP.md` |
| Colors, typography, shapes, Flutter theme starting point | `Context/00-prototype/DESIGN_TOKENS.md` |
| Demo data, demo clock, fixtures for simulations | `Context/00-prototype/SEED_DATA.md` |
| Quiz questions, placeholder wording, draft rule table | `Context/00-prototype/QUIZ_CONFIG.md` |
| Exact requirement wording, ACs, traceability (technology sections superseded) | `Context/01-requirements/SOFTWARE_REQUIREMENTS_SPECIFICATION.md` |
| MVP story rationale | `Context/01-requirements/Comprehensive_Explanation_of_the_MVP.md`, `mvp_breakdown.md` |
| Research, personas, journeys, items to reconcile | `Context/02-discovery/` |
| Screen layouts, copy, colors, interactions | `Context/03-design/` (Improved pages PDF first) |
| SRS template style | `Context/04-reference/` |
| Lecturer feedback | `Context/05-feedback/` |

**Rules for using `Context/`:**
1. Context documents **never override** Sections 3 or 12 of this file.
2. Layout: **Improved App Pages PDF > Medium-fi PDF**. Tokens: HTML prototype. Prototypes are references: the HTML has hard-coded data and shortcuts (no persistence, instant delete, always-opens Push Pull Leg).
3. If a Context file is missing, unreadable (e.g., an image you can't parse), or contradicts another, **say so and ask**; don't improvise.
4. New context files go in the matching subfolder and get a line in `Context/INDEX.md`. Never delete or rewrite existing ones; add a dated replacement note instead.

---

## 14. Change log

| Date | Change | By |
|---|---|---|
| 2026-10-18 | v1.0–v1.1 (TypeScript/PWA edition): Sections 0–14, BA-001…006 | AI-drafted, pending team review |
| 2026-10-18 | **v2.0 (Flutter prototype edition):** replaced TypeScript/PWA rules with F-01…F-32, new architecture (Section 6), fidelity-based feature spec (Section 8), prototype context pack (`Context/00-prototype/`), BA-005 superseded, BA-007 and BA-008 added | AI-drafted, pending team review |
| 2026-10-18 | **v2.1:** Bloc state management, local persistence that survives restarts (sembast), Firebase-ready design (F-33, F-34, BA-009), approved quiz rule table (BA-010), "Lat pulldown" (BA-011), Android phone target; SRS copy patched to the Flutter edition | AI-drafted, pending team review |
