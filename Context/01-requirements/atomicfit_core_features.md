# AtomicFit: Core Features
**Presented By:** Alexander Marchiano, Jonathan Gouw, Luiesrelio

## 1. Rep Tracker
**Why it is essential:**
For users who hate typing mid-set, standard text inputs break their rhythm. This feature strips away typing overhead while keeping logging instant and dependable.

**What it gives to the user:**
*   **Rhythm Preservation:** No navigating sub-menus or on-screen keyboards while out of breath.
*   **Instant Validation:** Tapping a single button gives immediate visual feedback, locking in effort.
*   **Low Cognitive Load:** The app anticipates actions based on past data; zero mental energy spent remembering numbers.

**How it helps the user:**
Turns a tedious data-entry chore into a single-tap ritual, keeping momentum high and preventing mid-session tracking abandonment.

**Bare Concept:**
*   **Pre-Populated Fields:** Weight/rep inputs auto-filled in gray text with values from the last session (or Diagnostic Quiz calibrations).
*   **One-Tap Log:** Tap a large green [DONE] button to instantly log the set.
*   **Quick Adjustment:** [+] and [-] steppers to adjust counts with single taps instead of a keypad.

---

## 2. Save Feature
**Why it is essential:**
Life is unpredictable (interruptions from children, classes, lack of time). Traditional apps mark these as "Incomplete", triggering a "didn't count" mindset. A persistent Save Feature protects user psychology.

**What it gives to the user:**
*   **Asynchronous Workout Support:** Workouts can happen in pieces across an entire day.
*   **Guilt Elimination:** Progress is safely stored like a video game save state, avoiding feelings of failure.
*   **Frictionless Re-Entry:** Opening the app brings the user right back to where they stopped.

**How it helps the user:**
Shifts the app from rigid taskmaster to flexible partner. Proves every rep counts, even if a 45-minute workout is chopped into sessions.

**Bare Concept:**
1.  **Background Cache:** Active state (Exercise ID, Set Number, Reps, Timestamp) cached locally in real-time.
2.  **Auto-Pause Detection:** Transitions into a Save Point if backgrounded/idle for >15 minutes.
3.  **Resume Widget:** Prominent home screen widget: "Paused at Set 3, Rep 6. [Resume] or [Bank Completed Reps]."

---

## 3. Diagnostic Quiz
**Why it is essential:**
Returning after a multi-week break brings guilt (broken streaks) and physical failure (losing conditioning). This intercepts barriers before the user steps onto the gym floor.

**What it gives to the user:**
*   **Psychological Clean Slate:** Suppresses shaming notifications/missed badges upon returning.
*   **Personalized Expectation Setting:** Direct control over how hard the session should be based on actual feelings.
*   **Preventative Safety:** Automatically scales down volume/intensity to prevent severe soreness (DOMS).

**How it helps the user:**
Breaks the start-chore-stop-guilt cycle, replacing judgment with a supportive check-in.

**Bare Concept:**
1.  **Hiatus Trigger:** Automatically triggers if `days_since_last_workout` is $\ge$ 14 days.
2.  **2-Tap Assessment:** "Welcome back! How is your energy level today?" Options: [Low] [Medium] [Ready to Push].
3.  **Smart Calibration (Auto-Ramp-Down):** Scales back target weights by 15-20% and reduces sets for Low/Medium inputs. Frames this as "Optimal Re-Entry Load".
4.  **Immediate Action:** Transitions to a short, manageable workout plan built on the input.

---

### Links & References
*   **Low Fidelity Prototype:** https://canva.link/d9iu24e0001errr
*   **Medium Fidelity Prototype:** https://canva.link/tv7pm54ruo6r7oq