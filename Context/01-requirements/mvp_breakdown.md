# AtomicFit MVP Presentation
**Presented By:** Alex, Jonathan, Luies

## How We Break Down Tasks
We looked at the proposed solution and assigned components to: **Design, Frontend, Sensor/Voice logic, Backend, Data, Analytics, and QA.**

**Task Workflow:**
*   **Design** comes first.
*   **Sensor Logic & Backend** run in parallel (no inter-dependencies).
*   **Frontend & Backend** run in parallel (sharing only the API contract).
*   **Data Modeling** happens alongside the backend.
*   **Analytics** is layered on once the core flow exists.
*   **QA** comes last, but test cases are written early.

**Component Reuse to Avoid Duplication:**
1.  One "save a set" API for rep counting, voice logging, and lock-screen add.
2.  One session data model for Micro Sessions & Set Stitching.
3.  One preview/confirm UI pattern for Quiz & Stitch.
4.  One analytics event schema / shared QA cases.

---

## EPIC: Easy Exercise Tracking and Re-engagement
**Goal:** Track via hands-free/voice/lock-screen controls to preserve rhythm. Re-engage via non-diagnostic quizzes, micro-sessions, and set stitching to prevent guilt.

### Story 1: Automatic Rep Counting
*As a lifter, I want the app to count my reps automatically so I don't have to touch my phone mid-set.*
*   **Design:** Workout screen, live counter, start/stop states, error states.
*   **Frontend:** Live counter component, manual +/- buttons.
*   **Sensors:** Accelerometer/gyroscope data, smoothing filter, peak counting.
*   **Backend:** API (save a set), offline save/sync.
*   **QA:** Compare auto count vs real count across 5 exercises.

### Story 2: Voice Logging
*As a lifter, I want to log reps by voice so I can record a set while my hands are busy.*
*   **Design:** Mic button, listening indicator, confirm card.
*   **Frontend:** Permission request, confirm/edit card.
*   **Voice Logic:** Speech-to-text, phrase parsing (e.g., "10 reps squat"), retry handling.
*   **Backend:** Reuse "save set" API.
*   **QA:** Test in noisy gym with different accents.

### Story 3: Lock Screen Quick-Add
*As a lifter, I want to add a rep or set from my lock screen so I never need to unlock my phone.*
*   **Design:** Lock screen widget layout.
*   **Frontend:** Widget with +1 rep/set, live count sync.
*   **Backend:** Immediate save to prevent data loss.
*   **QA:** Close app mid-set and verify count survives.

### Story 4: Non-Diagnostic Quiz
*As a busy lifter, I can take a short non-diagnostic quiz about my target, energy, and motivation so the app can adjust my program.*
*   **Design:** Prompt, question screens, preview screen.
*   **Frontend:** Modal/banner, quiz flow, program preview UI.
*   **Backend:** 7-day Inactivity trigger, rule engine for adjustment.
*   **Data/Analytics:** Quiz attempt tracking, funnel dashboards.
*   **QA:** Rule matrix logic, accessibility testing.

### Story 5: Micro-Sessions
*As a lifter who needs to leave mid-workout, I want the completed portion saved as a micro-session.*
*   **Design:** Bottom sheet exit intercept, micro-session badge.
*   **Frontend:** Exit interception, History UI update, Resume UI.
*   **Backend:** Session state tracking, Micro session save/resume APIs.
*   **Data/Analytics:** Session type enum, save/discard rates.
*   **QA:** Background app kill, offline sync, streak edge cases.

### Story 6: Set Stitching
*As a lifter, I want to combine multiple sessions into one stitched session.*
*   **Design:** Selection mode, preview card, stitched card.
*   **Frontend:** Multi-select history, Preview/Unstitch UI.
*   **Backend:** Eligibility service, Stitch preview/service/unstitch APIs.
*   **Data/Analytics:** `stitched_session` table, parent/child IDs.
*   **QA:** Cross-midnight tests, prevent stats double-counting.

---

### Why These Stories for the MVP?
The MVP tackles the two main reasons users drop out:
1.  **In-workout friction:** Addressed by Auto-rep counting, Voice logging, and Lock-screen quick-add.
2.  **Post-lapse guilt:** Addressed by the Non-judgment quiz, Micro sessions, and Set stitching.