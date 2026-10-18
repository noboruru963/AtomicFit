# PROTOTYPE_BRIEF.md — AtomFit Flutter prototype

Status: v2.1 (2026-10-18). Read `../../AGENTS.md` first; this file expands Sections 5.5 and 8 of it and never overrides Sections 3 or 12.

## 1. Goal
Build a **clickable, believable Flutter prototype** of AtomFit that a lecturer or stakeholder can run on an Android emulator or phone and walk through end to end. It replaces the earlier plan of a working TypeScript PWA.

"Prototype" here means:
- The **UI matches the Improved App Pages design** (layout, copy, tokens, navigation).
- **Domain logic that is cheap and valuable is real and unit-tested** (quiz rules, inactivity, micro sessions, stitching, rep detection on recorded signals, voice phrase parsing).
- **Hardware is simulated by default** (motion sensors, microphone, lock screen), clearly labelled in code and optionally in the UI.
- **Data is stored locally and kept after restart; no backend, no network, no analytics SDK.** A Firebase database is planned later; design for it, do not build it.

It is **not** a production release, so security hardening, store packaging, and full accessibility audits are out of scope.

## 2. Audience and success criteria
Audience: course lecturers and the team (SRE coursework demo).
The prototype succeeds when a viewer can complete the **demo script (Section 4)** without hitting a dead end, and every screen in `SCREEN_MAP.md` marked P0 or P1 exists and is reachable.

## 3. Scope tiers
| Tier | Meaning | Contents |
|---|---|---|
| **P0 — must demo** | Needed for the story to make sense | Login/Register (mock, validated) · Home (derived calendar, monthly count, Continue last workout, Empty workout, My programs) · Quiz prompt + 10-question quiz + "Why we changed your program" + Adjusted program (Accept / Keep old) · My programs + program detail · Active workout with manual logging (weight, reps, Add set, Add exercise, Finish) · Rest timer · Workout complete · History (All/Full/Micro filter, search, detail, delete with confirm) · Discover · Profile (incl. gender) · Settings (theme) · Bottom nav Home\|History\|Discover\|Profile with Home locked on Home · three-dots menu next to the bell · **data stored locally and kept after restart** |
| **P1 — should demo** | The differentiating MVP stories | Exit sheet + **micro session** save/discard/resume · **Set stitching** (select two, preview, confirm, expandable card, unstitch) · **Auto-count** screen driven by a simulated signal (tap "Simulate rep" or replay a recorded fixture) with +1/−1 and editable final count · **Voice logging** with phrase input (typed or tap-a-sample) → parser → confirmation card · In-app **quick-add bar** (+1 rep / +1 set) |
| **S — stretch** (needs approval) | Real-device behavior | Real `sensors_plus` capture feeding the same rep detector · real `speech_to_text` · Android notification with +1 rep / +1 set actions (`flutter_local_notifications`) |

## 4. Demo script (acceptance walk-through)
1. Launch → Login screen shows the panda placeholder logo and the tagline "Log it. Keep going." → log in as the seeded user **Joe123**.
2. Home → "Welcome back!", calendar derived from seeded history, **Home tab highlighted and not tappable**, bell with the **⋮ menu** next to it.
3. Because the seeded last workout is 13 days old at first launch (see `SEED_DATA.md`), the **quiz prompt** "Let's restart at your pace" appears → **Start quiz**.
4. Answer all **10 questions** (progress n/10, Next disabled until answered, non-diagnostic footer on each) → **See what changed**.
5. "Why we changed your program" (shows a 10–20% reduction example) → **Adjusted program** preview → **Accept program**. Program version is created; "Keep my old program" and later revert keep the old one.
6. My programs → start the adjusted program → active workout → log sets, use the rest timer, **Add exercise** from Discover-style picker.
7. Use **auto-count** (simulated) for one set and **voice logging** (sample phrase "10 reps squat") for another; both end on a correctable confirmation and save through the one Save-Set path.
8. Press Back mid-workout → **exit sheet** → **Save as micro session**.
9. History → entry shows the **Micro badge** → open it → **Resume**.
10. History selection mode → pick two sessions → **preview** → confirm → one **expandable stitched card** → **Unstitch** → both sessions return and totals match the pre-stitch totals.
11. Settings via ⋮ → switch to dark theme; every screen stays readable.
12. Profile → edit gender/weight/height → Update Profile → "Profile updated".
13. Force-close the app and reopen it → the new workout, the accepted program, and the profile changes are still there.

## 5. Real vs simulated matrix
| Capability | Real (pure Dart, tested) | Simulated / stubbed default | Stretch (real) |
|---|---|---|---|
| Quiz rule engine, ease-in, inactivity | ✔ | | |
| Program versions, accept/revert | ✔ | | |
| Save-Set service, idempotent IDs | ✔ | | |
| Micro sessions, resume | ✔ | | |
| Stitching, unstitch, no double count | ✔ | | |
| Rep detector (smoothing + peak + min interval) | ✔ on recorded fixtures | Motion input: tap "Simulate rep" or replay fixture | `sensors_plus` live stream |
| Voice phrase parser | ✔ | Speech input: typed text / sample chips | `speech_to_text` |
| Lock-screen quick add | In-app quick-add bar ✔ | Lock-screen concept card (UI only) | Android notification actions |
| Auth | Validation + local accounts (salted hash) ✔ | Seeded demo user Joe123 | Firebase Auth later |
| Persistence | Repositories + sembast, survives restart ✔ | Seeded once on first launch | Firebase later (not built) |

## 6. Definition of done for a screen
- Matches the Improved-pages layout and design tokens in light and dark themes.
- No hard-coded demo values inside widgets (data comes from state/seed).
- No RenderFlex overflow at 360 dp width; touch targets ≥ 48 dp.
- All strings come from `strings.dart`; icon buttons have tooltips/semantics.
- Has at least one widget test for its key interaction (P0/P1 screens) or is covered by a flow test.

## 7. Out of scope for the prototype
Firebase or any real backend, cloud, social, wearables, payments, push notifications, store builds, localization beyond English, units toggle, PRs/volume charts (held items in AGENTS.md 9.5), and any native Kotlin/Swift code unless a stretch addendum approves it.
