# Comprehensive Explanation of the MVP Presentation

The presentation explains the Minimum Viable Product (MVP) for a fitness application called Atomic Fit. The application is designed to make workout tracking easier and help users remain consistent with exercise, even when they have limited time, miss several days of training, or need to stop a workout before completing it.

The main idea behind the MVP is that people may stop using fitness applications for two major reasons: tracking workouts requires too much effort, and incomplete workouts can make users feel that their efforts do not count. Atomic Fit addresses these problems through six user stories grouped under one major epic: Easy Exercise Tracking and Re-engagement. The proposed features aim to reduce the effort required to record exercise while helping users return to their workout routines without unnecessary guilt or pressure.&#x20;

MVP.pdf



## 1. How the Development Tasks Are Organized

Before developing the application, the team breaks the proposed solution into smaller tasks based on the responsibilities of different development areas. This approach helps clarify which team members are responsible for each component and how their work connects.

The presentation identifies seven major areas of responsibility:

1. Design: Defines the layout, interface, interaction patterns, and visual presentation of the application.
2. Frontend: Implements the interface users interact with, including buttons, counters, forms, workout screens, and history pages.
3. Sensor and voice logic: Processes smartphone motion data to count repetitions and interprets voice commands to record exercise.
4. Backend: Implements the application's server-side logic, APIs, session management, and data-saving operations.
5. Data: Defines the database structures required to store workout sets, sessions, quiz responses, and other information.
6. Analytics: Tracks user interactions and application outcomes to evaluate whether the features are effective.
7. Quality Assurance (QA): Tests the application to identify errors, verify functionality, and ensure that information remains accurate under different conditions.

Each development area has a specific responsibility, but the components must work together to deliver a complete feature.

For example, automatic repetition counting requires the sensor component to detect movement, the frontend to display the current count, the backend to save the completed set, and QA to verify whether the count matches the actual number of repetitions.

### Development sequence and dependencies

The team also considers the order in which tasks should be completed. Design generally comes first because the frontend, sensor logic, and backend need a shared understanding of the intended behavior.

After the initial design is established, several tasks can proceed simultaneously:

- Sensor logic and backend development can happen in parallel because they are not directly dependent on each other.
- Frontend and backend development can also happen in parallel, provided that both follow an agreed API contract.
- Data modeling proceeds alongside backend development because the database structure depends on the application's business logic.
- Analytics is added once the main application flow exists, allowing meaningful user interactions to be measured.
- QA testing takes place throughout development, although final integration and comprehensive testing happen after the core features have been implemented.

Importantly, writing test cases should begin early rather than waiting until development is finished. This allows the team to identify potential edge cases and design problems before they become more expensive to fix.

The development sequence therefore balances two goals: establishing dependencies in the correct order and allowing independent tasks to progress in parallel.&#x20;

MVP.pdf



### Reusing shared components

The presentation also emphasizes reusing common components instead of implementing similar functionality separately for every feature.

For example, automatic repetition counting, voice logging, and lock-screen quick-add all use the same API for saving a workout set. Similarly, micro sessions and stitched sessions reuse common session-data concepts and save-session patterns.

The quiz and session-stitching features also use a shared preview-and-confirm interface pattern. In analytics, events follow a common schema, while QA reuses test cases for issues such as time zones, offline synchronization, and application termination.

This reuse reduces duplicated work, makes development more consistent, and simplifies maintenance. It also allows the team to divide work into smaller, testable tasks that can be assigned to individual team members.

## 2. The Main Epic: Easy Exercise Tracking and Re-engagement

In software development, an epic is a broad objective that contains several related user stories. A user story describes a feature from the perspective of the person who will use it, explaining what they want to do and why it matters.

The main epic of Atomic Fit is Easy Exercise Tracking and Re-engagement. It contains six user stories, divided into two groups.

A. Easy Exercise Tracking

Reducing the effort required to record exercise during a workout.

1. Automatic repetition counting using smartphone sensors.
2. Voice-based workout logging.
3. Quick repetition and set logging from the lock screen.

B. Re-engagement

Helping users return to exercise and preserve the value of incomplete workouts.

4. A short, non-diagnostic quiz after a period of inactivity.
5. Saving an incomplete workout as a micro session.
6. Combining fragmented workouts into one stitched session.

The distinction between these groups is important. The first group focuses on making workout tracking easier in the moment, while the second addresses situations that can interrupt long-term consistency.

Together, the six stories cover different stages of a user's workout experience: recording exercises, adapting a routine after inactivity, preserving partial progress, and combining fragmented sessions.

## 3. Story 1: Automatic Repetition Counting

The first user story states that a lifter wants the application to count repetitions automatically so that they do not need to touch their phone during a set.

### Purpose and functionality

Manually recording repetitions requires the user to interact with their phone while exercising. This can interrupt their concentration, rhythm, or rest periods and may discourage them from tracking their workouts altogether.

Atomic Fit proposes using the smartphone's built-in accelerometer and gyroscope to detect movement during exercise. The accelerometer measures changes in acceleration, while the gyroscope measures rotational movement. By processing these sensor readings, the application attempts to identify the movement patterns associated with individual repetitions.

The proposed workflow is as follows:

1. The user selects an exercise and starts a set.
2. The application reads movement data from the smartphone's sensors.
3. A smoothing filter reduces noise in the sensor readings.
4. A repetition-detection algorithm identifies movement cycles through peak counting, using a minimum time interval between repetitions.
5. The live counter updates as repetitions are detected.
6. The user stops the set and can correct the final count manually if necessary.
7. The application saves the completed set.

The minimum time interval helps prevent a single movement from being counted multiple times because of small fluctuations in the sensor data. However, the algorithm must be tuned for different exercises, such as squats, bench presses, and curls, because their movement patterns differ.

### Development responsibilities

- Design: Creates the workout screen, large live repetition counter, start and stop states, and error messages when repetitions cannot be detected.
- Frontend: Implements the live counter, set controls, and manual +1 and -1 correction buttons.
- Sensor logic: Reads accelerometer and gyroscope data, filters noise, detects repetitions, and supports exercise-specific settings.
- Backend: Provides an API to save a set containing the exercise, repetition count, weight, and time. It also stores sets and supports offline saving followed by synchronization when the device reconnects.
- QA: Compares automatically detected repetitions against actual counts across five exercises.

The central challenge is accuracy. A counter that frequently misses repetitions or counts movements incorrectly would undermine user trust. Manual corrections provide a fallback, while testing across multiple exercises helps determine whether the detection logic is reliable.

This feature represents the first major improvement in the application: users can record their workout with less manual interaction.&#x20;

MVP.pdf



## 4. Story 2: Voice-Based Workout Logging

The second user story describes a lifter who wants to record repetitions through voice commands because their hands are busy.

### Purpose and functionality

Automatic counting may not work equally well in every situation. A user might be performing an exercise for which sensor-based counting is difficult, or they may simply want to record a completed set without touching their phone.

Voice logging provides an alternative. The user speaks a command, and the application converts it into structured workout information.

For example, the user might say, "10 reps squat." The application then attempts to interpret the phrase as an exercise name and repetition count, along with weight if provided.

The process involves several steps:

1. The user taps the microphone button and grants microphone permission if necessary.
2. The application displays a listening indicator.
3. Speech-to-text converts the spoken command into text.
4. A parser identifies relevant information, such as the exercise, repetitions, and weight.
5. A confirmation card displays what the application understood.
6. The user confirms or edits the information.
7. The application saves the set using the same save-set API used by automatic repetition counting.

If the application cannot interpret the command, it displays a retry message rather than silently saving incorrect information.

### Development responsibilities

- Design: Defines the microphone button, listening indicator, and confirmation interface.
- Frontend: Implements microphone interaction, permission requests, and the confirmation-and-edit card.
- Voice logic: Integrates speech-to-text, parses commands into workout data, and handles unknown or ambiguous phrases.
- Backend: Reuses the existing save-set API rather than creating a separate system for storing voice-recorded sets.
- QA: Tests recognition in noisy gym environments and with different accents.

The main challenge is interpreting speech correctly in a noisy environment. Even if speech-to-text produces a transcription, the application must still identify what the user intends to record.

The confirmation card is therefore an important safeguard. It allows users to verify the interpreted information before it becomes part of their workout history.

Reusing the save-set API also demonstrates the benefit of shared components: voice logging introduces new input methods without duplicating the underlying workout-saving functionality.

## 5. Story 3: Lock-Screen Quick Logging

The third user story describes a lifter who wants to add a repetition or set from their phone's lock screen without unlocking the device.

### Purpose and functionality

Even when a user wants to record only a single repetition or set, unlocking the phone, opening the application, and navigating to the correct screen can create unnecessary friction.

Atomic Fit proposes a persistent lock-screen widget that allows the user to update their workout with a single tap.

The proposed interface includes controls for adding one repetition or one set. The displayed count should synchronize with the main application, while each change is saved immediately so that the information is not lost if the application closes.

The intended workflow is:

1. The user begins a workout.
2. They access the lock-screen widget.
3. They tap the appropriate control to add a repetition or set.
4. The application saves the update immediately.
5. The count synchronizes with the main application.
6. If the application is closed during the workout, the saved information remains available.

### Development responsibilities

- Design: Defines the layout of the lock-screen widget.
- Frontend: Implements the widget, its +1 repetition and +1 set controls, and synchronization with the application.
- Backend: Saves every count immediately.
- QA: Closes the application during a set and verifies that the recorded count survives.

This feature focuses on minimizing the number of steps needed to record exercise. Unlike voice logging, which requires speech recognition, lock-screen logging relies on simple, direct controls.

An important implementation consideration is that lock-screen functionality depends on the operating system's capabilities and permissions. The presentation describes the intended feature but does not specify its platform-specific implementation.

The feature's overall purpose is to make recording a workout as immediate as possible, even when the main application is not open.&#x20;

MVP.pdf



## 6. Story 4: A Non-Diagnostic Quiz After Inactivity

The fourth user story describes a busy lifter who wants to take a short quiz about their target, energy, and motivation so the application can adjust their workout program to their current circumstances.

### Purpose and functionality

When people stop exercising for several days, returning to their previous routine may feel difficult. They might be unsure whether they should resume their normal workload, reduce the duration of their sessions, or change their training frequency.

Atomic Fit proposes a short quiz that appears after at least seven days of inactivity. The quiz is designed to help the user restart with a more suitable program rather than requiring them to work out exactly as they did before.

The quiz asks about three areas:

- Target: What the user currently wants to achieve.
- Energy: How much energy they currently have available for training.
- Motivation: How motivated they feel to exercise.

The application uses these answers to adjust three aspects of the workout program:

1. Session length: How long a workout should take.
2. Intensity: How demanding the workout should be.
3. Frequency: How often the user should train.

The application then displays a preview of the adjusted program. The user can accept the proposed changes or revert them, keeping the user in control of their training plan.

The quiz is explicitly described as non-diagnostic. Its purpose is to support workout planning, not to assess or diagnose a medical or psychological condition. The presentation also specifies that the feature should work without complex AI.

### Development responsibilities

- Backend: Detects inactivity, stores quiz attempts and answers, applies the program-adjustment rules, and manages program updates.
- Design: Creates the quiz prompt, question screens, preview screen, and non-diagnostic explanatory text.
- Frontend: Implements the quiz prompt with "Start quiz" and "Not now" options, the quiz flow, and the program preview with accept and revert controls.
- Data: Defines models for `quiz_attempt`, `quiz_answer`, `program_version`, and `user_program_adjustment`.
- Analytics: Records events such as the prompt being shown, quiz initiation, quiz completion, program acceptance, and the next workout being started. It also supports dashboard measurements of the quiz funnel and seven-day return rate.
- QA: Tests inactivity thresholds, the rule matrix, program versioning, the complete quiz flow, program adjustments, acceptance and reversal, accessibility, and localization.

### Why a rule engine is used

A rule engine applies predefined conditions to determine how a program should change.

For example, different combinations of the user's target, energy, and motivation can map to different workout adjustments. The presentation also mentions defining mappings for targets, energy, and motivation, establishing precedence when rules conflict, and applying safety limits.

This makes the adjustment process more predictable and testable than an unspecified automated decision-making system. However, the exact quiz questions, mapping rules, and adjustment values are not provided in the presentation.

The main purpose is to reduce the difficulty of returning after inactivity by offering a manageable starting point instead of making the user feel that they must immediately resume their previous routine.&#x20;

MVP.pdf



## 7. Story 5: Micro Sessions for Incomplete Workouts

The fifth user story describes a lifter who needs to leave during a workout and wants the completed portion to be saved as a legitimate micro session that appears in their history and can be resumed later.

### Purpose and functionality

Traditional workout tracking may encourage an all-or-nothing mindset. If a user planned to complete an entire workout but had to leave early, they might discard the entire session because it was incomplete.

Atomic Fit addresses this problem by allowing users to save the portion they completed.

A micro session is a saved, incomplete workout that preserves the work already performed. It is distinguished from a full session through a session-type field and related completion information.

The proposed workflow is:

1. The application detects that the user is exiting a workout early.
2. It displays an option to save the completed portion as a micro session.
3. The application calculates and stores the work completed so far.
4. The saved session appears in workout history with a micro-session badge.
5. The user can review the completed exercise summary.
6. The user can resume the micro session later, loading it back into an active workout.

The user can also choose to discard the incomplete workout. The feature is intended to recognize completed work without forcing the user to finish the entire planned session.

### Development responsibilities

- Backend: Tracks session states, provides a micro-session save API and a resume-session API, and manages offline synchronization.
- Design: Creates the exit bottom sheet, micro-session badge, history card, and resume screen.
- Frontend: Implements the early-exit prompt, history interface, completed-exercise summary, and resume workflow.
- Data: Defines fields such as `session.type` with `full` and `micro` values, `completion_status`, and a micro-session record.
- Analytics: Records when users quit, save a micro session, or discard it. It also tracks whether they start another workout within 48 hours and supports dashboards for save rates, discard rates, and retention.
- QA: Tests backgrounding, application termination, offline synchronization, calendar and streak edge cases, resuming after a restart, time-zone behavior, and duplicate synchronization.

### Why offline synchronization and state management matter

A saved micro session must remain reliable even if the user closes the application or loses their internet connection. The application therefore needs to preserve the session state locally when necessary and synchronize it when connectivity returns.

Duplicate synchronization is another important issue. If the same saved session is uploaded twice, the user's history or statistics could become inaccurate. QA must verify that repeated synchronization does not create duplicate records.

The session also needs a clear distinction between the completed portion and the remaining work. This is important when the user resumes the workout because the application must load the appropriate state rather than treating the entire original workout as newly completed.

The intended outcome is to make partial progress visible and useful, reducing the likelihood that a user abandons workout tracking simply because a session was interrupted.&#x20;

MVP.pdf



## 8. Story 6: Set Stitching for Fragmented Workouts

The sixth user story describes a lifter who cannot always afford long workout sessions and wants to combine multiple sessions into one visible record while preserving accurate future progression.

### Purpose and functionality

Some users divide their workouts into separate periods because of time constraints. For example, someone might complete part of a workout, leave, and perform the remaining work in a later session.

Without a suitable way to combine these records, the user's history may display multiple small sessions instead of one combined effort. The user might also feel that neither session was substantial enough to count.

Atomic Fit proposes set stitching, which allows a user to combine two eligible sessions into one parent session while preserving the original sessions as separate child records.

The proposed workflow is:

1. The user opens workout history and selects two eligible sessions.
2. The application checks whether both sessions satisfy the eligibility rules.
3. The user previews the combined session metrics.
4. The application displays the combined result for confirmation.
5. Once confirmed, the application creates a parent stitched session that references the original sessions.
6. The history displays one expandable stitched-session card.
7. If necessary, the user can unstitch the sessions to reverse the combination.

The central requirement is that combining the presentation of workout records must not corrupt the original session data or double-count the user's progress.

### Development responsibilities

- Backend: Implements eligibility checks, the stitching preview and confirmation process, the unstitch API, and progression policies.
- Design: Creates session-selection mode, the preview card, the stitched-session card, and the unstitch confirmation interface.
- Frontend: Implements multi-selection in workout history, eligibility indicators, the stitching action, the combined-session preview, and the resulting history display.
- Data: Defines a `stitched_session` table or equivalent parent-child relationship, including child-session identifiers and combined metrics.
- Analytics: Records when stitching begins, when the preview appears, when stitching is confirmed or reversed, and whether the user starts another workout within 48 hours. It also measures feature usage, unstitch rates, and retention.
- QA: Tests same-day sessions, sessions spanning midnight, time-zone differences, micro and full sessions, and combinations of two full sessions. It also checks statistics, workout streaks, transaction rollback, and cleanup after unstitching.

### Why the parent-child data relationship matters

Suppose a user has two completed session records. If the application simply adds their metrics together and saves a new record without preserving the relationship to the originals, the same workout effort could be counted multiple times.

Instead, the stitched session acts as a parent record that references its original child sessions. The application can then present the combined metrics while retaining the underlying data.

The presentation also calls for a progression policy service. Its purpose is to ensure that combining sessions for display does not unintentionally change how future workout progression is calculated. The precise progression rules are not specified, but preserving accurate progression is a core requirement.

The ability to unstitch sessions is equally important. If the user reverses the operation, the application must restore the original history correctly without leaving duplicate statistics or inconsistent relationships.

Set stitching therefore addresses fragmented workout schedules while maintaining data integrity.&#x20;

MVP.pdf



## 9. How the Six Stories Work Together

Although the six features address different problems, they share a common objective: helping users track their exercise consistently without imposing unnecessary effort or discouraging them when their routines are interrupted.

During a workout

Automatic counting, voice logging, and lock-screen controls offer different ways to record repetitions and sets. The user can choose the method that best suits the situation.

After missing several days

The quiz helps the user restart with a workout program adjusted to their current target, energy, and motivation.

When a workout is interrupted

Micro sessions preserve the work already completed and allow the user to resume later.

When workouts are fragmented

Set stitching presents eligible sessions together while retaining their original records and protecting progression accuracy.

The features also share technical infrastructure. The save-set API supports multiple logging methods, session data structures support both micro sessions and stitching, and common analytics and QA practices reduce duplicated development effort.

This is an important aspect of the proposed MVP: it is not simply a collection of unrelated features. It is a connected system built around reducing friction and preserving workout progress.

## 10. Why These Features Were Chosen for the MVP

The final substantive section of the presentation explains the reasoning behind the feature selection.

An MVP is a version of a product that contains the essential features needed to deliver and evaluate its core value. The goal is not to implement every possible functionality immediately, but to focus development on the most important user problems.

For Atomic Fit, the team identifies two primary failure points.

### Problem A: Friction during workouts

Manual logging interrupts the workout experience. When recording an exercise becomes inconvenient, users may stop tracking altogether.

The team selects three features to address this issue:

- Automatic repetition counting: Uses existing smartphone sensors to reduce the need to touch the phone during a set. It does not require additional hardware.
- Voice logging: Allows users to record a set when their hands are busy or the phone is out of reach. It also reuses the existing save-set backend, limiting the additional work primarily to speech recognition and parsing.
- Lock-screen quick-add: Allows users to record repetitions and sets without unlocking the phone. Immediate saving helps prevent data loss.

These three features cover different circumstances in which manual interaction is inconvenient. Together, they provide multiple ways to track a workout instead of requiring every user to follow the same recording method.

### Problem B: Guilt and disengagement after interruptions

The second problem occurs when users miss several days, leave a workout early, or divide a workout into multiple sessions. If the application treats these situations as failures or makes the completed work difficult to preserve, users may feel that their efforts are not worthwhile.

The team selects three features to address this issue:

- The non-judgment quiz: Targets users who have been inactive for seven days. It helps them restart by adjusting session length, intensity, and frequency according to their current circumstances.
- Micro sessions: Allow users to save incomplete workouts as legitimate activity instead of choosing only between finishing the entire workout and discarding their progress.
- Set stitching: Allows users to combine two eligible sessions into one visible effort while retaining the original records and preserving accurate progression.

Each feature addresses a distinct situation: returning after inactivity, leaving during a workout, and exercising in fragmented sessions.

The selection is therefore based on how directly each feature addresses the identified user problems. The presentation does not provide numerical prioritization scores or comparative cost estimates, so it would be inaccurate to claim that the team selected these stories through a quantified ranking process.&#x20;

MVP.pdf



## 11. Analytics and Quality Assurance Across the MVP

Analytics and QA are not separate product features for the user, but they are essential to determining whether the proposed solution works as intended.

### Analytics: Measuring whether the features help

The presentation proposes tracking specific events for each feature. Examples include:

- Whether users start and complete the inactivity quiz.
- Whether they accept an adjusted workout program.
- Whether they save or discard a micro session.
- Whether they use set stitching or reverse it.
- Whether they return to another workout within 48 hours.
- Whether users return after the seven-day inactivity trigger.

These events can help the team understand where users engage with a feature and where they abandon the process.

For example, if many users see the quiz prompt but few complete it, the team may need to investigate the quiz experience. If users frequently save micro sessions but rarely return to resume them, the team may need to examine the resumption flow.

These are examples of how the proposed measurements could be interpreted; the presentation does not report actual analytics results because it describes the planned MVP rather than measured outcomes.

### QA: Protecting accuracy and reliability

The presentation identifies several recurring risks across the features:

- Data loss: Workout information should survive application closure and interruptions.
- Offline synchronization: Data saved without a connection should synchronize reliably when connectivity returns.
- Duplicate records: Repeated synchronization must not create duplicate sessions or distort statistics.
- Time-zone and calendar issues: Sessions crossing midnight or time zones must be represented correctly.
- Data integrity: Combining and reversing sessions must not double-count workout metrics.
- Usability and accessibility: The quiz and other interfaces should remain understandable and accessible.
- Algorithm accuracy: Automatic repetition counts must be compared with actual repetitions across different exercises.

These tests are particularly important because the application handles workout history and progression. Even small data errors can reduce user confidence if the application displays incorrect repetitions, sessions, or statistics.

The overall testing strategy combines unit tests for individual rules, integration tests for complete workflows, and edge-case tests for situations that might otherwise be overlooked.

## 12. Overall Conclusion

Atomic Fit's MVP is built around a specific product philosophy: make exercise tracking easier and make incomplete or interrupted workouts feel worthwhile rather than treating them as failures.

The first three user stories reduce the effort required to record exercise. Automatic repetition counting uses smartphone motion sensors, voice logging interprets spoken workout commands, and lock-screen quick-add provides immediate controls without requiring the user to open the main application.

The remaining three stories support re-engagement. A short quiz helps users return after inactivity, micro sessions preserve the work completed before an early exit, and set stitching combines eligible fragmented sessions into a single visible record while protecting the original data.

These features are supported by shared APIs, reusable interface patterns, structured data models, analytics events, and a QA strategy that emphasizes reliability and data integrity. The development plan divides work among design, frontend, sensor and voice logic, backend, data, analytics, and QA, while allowing independent tasks to proceed in parallel.

Ultimately, the MVP aims to address two connected problems: the difficulty of tracking workouts consistently and the tendency to disengage when real-life circumstances prevent a person from following the planned routine.

Rather than assuming that every user can always complete a perfect workout, Atomic Fit is designed to make tracking more convenient, recognize partial progress, and provide practical ways to return to exercise. That is the central value proposition connecting all six user stories in the presentation.