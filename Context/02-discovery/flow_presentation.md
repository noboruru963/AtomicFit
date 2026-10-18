# Flow: The Gym Bros
**Presented By:** Jonathan Gouw, Alexander Marchiano, Luiesrelio

## AtomicFit Core Flow
1. **Check In**
   * No-Judgment Diagnostic Question after a long break.
   * Gives users control over expectations.
2. **Calibration**
   * Prevents DOMS (Delayed Onset Muscle Soreness).
   * Triggers Smart Ease-In to prevent injuries.
3. **Instant Stop / Validation Net**
   * Micro-Session Auto Classifier logs short exercise sessions as "power blasts".
   * Dumps completed reps in the weekly volume bucket.

## Implemented Features
### 1. Fundamental Features
* **Manual Logging:** The ability to log exercises, sets, reps, and the weight used.
* **Activity Recording:** For cardio-related activities, recording metrics like distance, pace, and elevation.
* **Charts and Graphs:** Visual representations of progress over time (strength gains, volume trends, body weight changes).
* **Exercise Database:** A large library of exercises with demonstration videos or animations to ensure correct form.
* **Adaptive Programming:** Adjusts future workouts based on logged performance and recovery.

### 2. Core Unique Features
* **Auto-Ramp-Down:** Reduces target weight after a long break.
* **No-Judgment Diagnostic Quiz:** Quick question about energy levels to create a short workout based on condition.
* **Micro-Session Auto-Classifier:** Adjusts goals if a workout is cut short so it can still be marked as successful, avoiding the feeling of failure.

### 3. Extra Features
* **Voice Quick Log:** "3 sets of 10 squats" automatically records the workout (useful for sweaty hands/distance).
* **Lock Screen Quick Add:** Add reps or sets without unlocking the phone.
* **"Save Point" Resume Card:** Saves exactly where the user stopped (e.g., "Set 3, stopped at rep 6") to continue later with one tap.
* **Weekly Rep/Distance Bucket:** Shows all reps or running distance completed during the week.
* **Asynchronous Set Stitching:** Combines sets completed at different times into one workout.

---

## User Journeys

### 1. On-the-Go Mom
**Needs:** A way to keep her place when pulled away mid-set because a paused set feels like failing, turning stress relief into a stressor.
* **Flow:** Opens App -> Saved workout exists? -> (Yes) Starts saved plan / (No) Starts quick default plan -> Log sets -> Interrupted Mid-set? 
  * If No: Finished and saves.
  * If Yes: Auto-saved pause point -> Resumes same day? -> (Yes) Continues workout / (No) Counted as achieved (Auto-classifier).

### 2. The Fit Undergrad
**Needs:** A way to log reps without touching anything because typing breaks his rhythm and one lost count makes the session feel wasted.
* **Flow:** Start workout, sets phone down -> Using smartwatch? 
  * If Yes: Hands-free logging, voice or tap.
  * If No: Manual phone logging.
  * *Proceeds to:* Lifts sets -> Loses count? -> (Yes) Taps smartwatch to log reps/sets / (No) Keeps counting time -> Finished, auto-saves.

### 3. The 9-5 Gym Bro
**Needs:** A way to restart after a break without feeling like he is starting over because he expects the next attempt to end in guilt.
* **Flow:** Opens app after hiatus -> Hiatus over 14 days? 
  * If No: Skips Quiz -> Regular weight.
  * If Yes: No-Judgement Quiz -> Energy Levels? -> (High) Regular weight / (Low/Medium) Light ramp down.
  * *Proceeds to:* Completed Session -> Finished feeling content.

### 4. High Schooler Newbie
**Needs:** To know what to do next without a trainer because YouTube gives no structure/count, causing weeks of stopped progress.
* **Flow:** Opens app, unsure what to do -> First workout? 
  * If Yes: Onboarding Tour, explains sections.
  * If No: Suggests next exercise.
  * *Proceeds to:* Knows how to do the exercise? -> (No) Checks GIF Demo, mimics move, logs reps / (Yes) Performs directly, logs reps -> Session cut short? -> (Yes) Auto Classifier caches partial / (No) Fully completed -> Saved to history.