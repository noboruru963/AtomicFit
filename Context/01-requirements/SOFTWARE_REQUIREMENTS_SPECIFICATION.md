SOFTWARE REQUIREMENTS SPECIFICATION
AtomFit: Workout Tracking and Re-engagement Application

Project: ATOMFIT
Document: SRS
Author: Alexander Marchiano, Jonathan Gouw Alexandrio, Luiesrelio
Published on: October 14, 2026
Primary implementation language: Dart (Flutter)
Product type: Local-first Flutter mobile prototype (Android)
Edition note (2026-10-18): Flutter edition. Technology sections (ASM-02, ASM-03, 1.3.1, 1.3.4, 1.6, 2.6.1, NFR-025, NFR-028, NFR-029, NFR-031, NFR-039, NFR-045, NFR-046, DEP-03) were rewritten for a Flutter (Dart) Android prototype with local persistence and a later Firebase backend. Navigation (FR-015, FR-021), gender (FR-001, FR-008) and the exercise name (Lat pulldown) were updated. Other tables (screen list, traceability) may still use earlier wording; AGENTS.md Section 12 holds the approved behavior addenda and takes precedence.



 Table of Contents
1. Introduction	4
1.1 Purpose	4
1.2 Scope	4
1.3 Product Perspective	5
1.3.1 System Interfaces	5
1.3.2 User Interfaces	5
1.3.3 Hardware Interfaces	5
1.3.4 Software Interfaces	6
1.3.5 Communications Interfaces	6
1.3.6 Memory Constraints	6
1.3.7 Operations	6
1.3.8 Site Adaptation Requirements	6
1.3.9 Interfaces with Services	6
1.4 Product Functions	6
1.5 User Characteristics	9
1.6 Limitations	9
1.7 Assumptions and Dependencies	10
1.7.1 Assumptions	10
1.7.2 Dependencies	11
1.8 Definitions	12
1.9 Acronyms and Abbreviations	13
2. Requirements	14
2.1 External Interfaces	14
2.1.1 User Interfaces	14
2.1.2 Hardware Interfaces	16
2.1.3 Software Interfaces	16
2.1.4 Communications Interfaces	16
2.2 Functions	17
2.2.1 Account and Profile	17
2.2.2 Home and Navigation	19
2.2.3 Programs and Exercise Exploration	21
2.2.4 Manual Workout Logging	23
2.2.5 Rest Timer	25
2.2.6 Automatic Repetition Counting (US-001)	26
2.2.7 Voice-Based Workout Logging (US-002)	28
2.2.8 Lock-Screen Quick Logging (US-003)	30
2.2.9 Re-engagement Quiz (US-004)	31
2.2.10 Micro Sessions (US-005)	34
2.2.11 Set Stitching (US-006)	36
2.2.12 Workout History	38
2.2.13 Data Persistence and Local Storage	39
2.2.14 Analytics Events	41
2.3 Usability Requirements	43
2.4 Performance Requirements	44
2.5 Logical Database Requirements	46
2.5.1 Logical Data Model (informative)	47
2.6 Design Constraints	49
2.6.1 Flutter Stack Proposal and System Architecture (Assumption)	50
2.7 Standards Compliance	52
2.8 Software System Attributes	52
3. Verification	55
3.1 Verification Approach	55
3.2 Acceptance Criteria	55
3.3 Traceability Matrix	55
3.3.1 Epic to Story to Requirement Summary	55
3.3.2 Detailed Matrix: Functional Requirements	57
3.3.3 Non-Functional Requirements	60
4. Supporting Information	63
4.1 MVP Scope and Future Scope	63
5. References	65
Appendix A. Mapping of the Template and of the Requested Sections	66
Appendix B. Source Legend	68
Appendix C. Prototype Observations	69
Appendix D. Reuse of the Template Requirements	70


1. INTRODUCTION
1.1 Purpose
This document specifies the software requirements of AtomFit, a workout-tracking application. The MVP text calls the product ‘Atomic Fit’; this document uses ‘AtomFit’, the name in the high-fidelity prototype (CF-01). The product is a local-first Flutter (Dart) mobile prototype for Android phones.
The intended readers are the developers, designers, testers and the product owner of the project, and the reviewers of the coursework. The document follows the structure and requirement style of the attached example SRS (ReqView, based on ISO/IEC/IEEE 29148:2018). It is a draft: where the sources are silent or in conflict, the text says TBD or Assumption instead of inventing a requirement.
Four sources were analysed. They are cited by the following codes throughout the document: S1 the SRS template (ReqView example), S2 the medium-fidelity prototype PDF, S3 the epic, user-story and MVP text, and S4 the high-fidelity prototype HTML. The code PC means a constraint from the project brief (Flutter, local product), and ASM means an assumption made in this draft.
1.2 Scope
AtomFit helps people record workouts with little effort and return to training without guilt after interruptions. The MVP, defined by epic EP-001 and six user stories, lets the user:
•	count repetitions automatically with the motion sensors of the device (US-001);
•	log a set by voice command (US-002);
•	add a repetition or a set from the lock screen (US-003);
•	take a short, non-diagnostic quiz after at least 7 days of inactivity and receive an adjusted program (US-004);
•	save an unfinished workout as a micro session and resume it later (US-005);
•	stitch two sessions into one visible record and unstitch them (US-006).
Supporting capabilities shown in the prototypes (registration, login, profile, settings, programs, manual workout logging, rest timer and history) are in epic EP-002 and are treated as part of the MVP foundation (ASM-06). The application stores all data on the device and works without a server.
Not in the MVP (ASM-22): cloud synchronisation, social features, wearable integration, nutrition tracking, payments, push notifications and an administrator role. Requirements with scope ‘Future’ are listed in Section 4.1.
1.3 Product Perspective
AtomFit is a self-contained product. It does not depend on a project-owned server. The Flutter application runs on an Android phone and stores its data on the device (ASM-02). A Firebase backend is planned after the prototype and is outside the MVP. The prototypes use a mobile frame of at most 430 CSS pixels width with a bottom navigation bar and a blue primary colour with a light and a dark theme.
1.3.1 System Interfaces
The application runs on Android phones (NFR-045, TBD-04).
1.3.2 User Interfaces
The graphical interface is touch-operated and follows the 25 screens listed in Section 2.1.1. Seventeen screens exist in the prototypes; eight are required by the MVP text and have no prototype yet.
1.3.3 Hardware Interfaces
The application uses the accelerometer and gyroscope (US-001), the microphone (US-002), the vibration motor (rest timer) and the touch screen. A lock-screen control (US-003) needs operating-system support (TBD-05).
1.3.4 Software Interfaces
The application uses Flutter plugins for the motion sensors, microphone and speech recognition (engine TBD-06), vibration and local notifications, and stores data in an on-device document store (sembast). Data may be exported as JSON or CSV (Future).
1.3.5 Communications Interfaces
None are required in the MVP. All functions work offline, except speech-to-text if the chosen engine needs a network (TBD-06).
1.3.6 Memory Constraints
TBD. The sources specify no memory limit. The browser storage quota is the practical limit; the capacity target is 5000 stored sessions (NFR in 2.4, ASM-13).
1.3.7 Operations
The user starts every operation. The application needs no administration, no back-up service and no scheduled job. Inactivity is evaluated when the application is opened (FR in 2.2.9). Data back-up is limited to the Future export functions.
1.3.8 Site Adaptation Requirements
The application ships with three built-in programs and an initial exercise catalogue (FR in 2.2.3). The unit is kilograms and the language is English in the MVP (ASM-07, ASM-09). No other site adaptation is specified.
1.3.9 Interfaces with Services
None in the MVP. A speech-to-text service may be needed (TBD-06). Cloud services are Future.
1.4 Product Functions
The product functions are summarised as two epics and eighteen user stories. Epic EP-001 comes from the MVP text and is divided into group A, ‘Easy Exercise Tracking’ (US-001 to US-003), and group B, ‘Re-engagement’ (US-004 to US-006). Epic EP-002 is derived from the prototypes and the template. Priorities use the MoSCoW scale: Must, Should, Could and Won’t.
Epic ID	Name and description	Scope	Source	Stories
EP-001	Easy Exercise Tracking and Re-engagement. Reduce the effort of recording exercise (stories US-001 to US-003, group A) and help users return to training without guilt after interruptions (stories US-004 to US-006, group B).	MVP	S3	US-001–US-006
EP-002	Foundation: Account, Programs, Manual Tracking, History and Data. Capabilities visible in the prototypes or required by the template that the MVP text does not list but on which the six MVP stories depend (Assumption ASM-06).	MVP	S1; S2; S4; ASM	US-007–US-018

Story ID	Epic	User story	Priority	Scope	Source
US-001	EP-001	As a lifter, I want the application to count my repetitions automatically, so that I do not need to touch my phone during a set.	Must	MVP	S3
US-002	EP-001	As a lifter, I want to record repetitions with voice commands, so that I can log a set when my hands are busy.	Must	MVP	S3
US-003	EP-001	As a lifter, I want to add a repetition or a set from the lock screen without unlocking my phone, so that logging takes a single tap.	Must	MVP	S3
US-004	EP-001	As a busy lifter, I want to take a short quiz about my target, energy and motivation, so that my workout program is adjusted to my current circumstances.	Must	MVP	S3; S2; S4
US-005	EP-001	As a lifter who has to leave during a workout, I want the completed portion saved as a legitimate micro session that I can resume later, so that my effort still counts.	Must	MVP	S3
US-006	EP-001	As a lifter who cannot afford long sessions, I want to combine multiple sessions into one visible record, so that my history stays clear and my future progression stays accurate.	Must	MVP	S3
US-007	EP-002	As a new user, I want to register an account, so that I can start using the application.	Should	MVP	S2; S4
US-008	EP-002	As a registered user, I want to log in and log out, so that my data is accessed only by me.	Should	MVP	S2; S4
US-009	EP-002	As a user, I want a home screen that shows my monthly activity and a shortcut to my last workout, so that I can resume training quickly.	Should	MVP	S2; S4
US-010	EP-002	As a user, I want to view and update my profile, so that my personal data is correct.	Should	MVP	S2; S4
US-011	EP-002	As a user, I want to change display settings such as the light or dark theme, so that the application is comfortable to read.	Should	MVP	S2; S4
US-012	EP-002	As a user, I want to browse, view and edit workout programs, so that I can follow a routine.	Should	MVP	S2; S4
US-013	EP-002	As a user, I want to explore exercises and add them to a program or workout, so that I can build my routine.	Should	MVP	S2; S4
US-014	EP-002	As a lifter, I want to log a workout manually (weights, repetitions, sets, exercises) and see a summary when I finish, so that I have a complete record.	Must	MVP	S2; S4
US-015	EP-002	As a lifter, I want a rest timer between sets, so that I rest for the planned time.	Should	MVP	S2; S4
US-016	EP-002	As a user, I want to review, search and delete past workouts, so that I can track my history.	Must	MVP	S2; S4
US-017	EP-002	As a user, I want my data stored on my device and never lost when the application closes, so that I can trust the records.	Must	MVP	S1; S3
US-018	EP-002	As a product team member, I want usage events recorded for the quiz, micro sessions and stitching, so that we can evaluate whether the features work.	Must	MVP	S3

1.5 User Characteristics
The sources describe the users only briefly. Age, language and technical expertise are TBD (TBD-03). The following user classes are derived from the MVP text and the prototypes.
ID	User class	Characteristics	Source
UC-01	Recreational lifter	Trains regularly with dumbbells, barbells or machines; wants quick logging during a workout. Primary user of EP-001 group A.	S3
UC-02	Returning user	Has not trained for 7 or more days; wants to restart without guilt and with a suitable program. Primary user of the quiz.	S3
UC-03	Time-constrained user	Often leaves a workout early or splits it across sessions; wants partial work to count. Primary user of micro sessions and stitching.	S3
UC-04	Beginner	Unfamiliar with exercises; the Explore exercise screen warns that some exercises are not recommended for beginners.	S2; S4

1.6 Limitations
The following limitations apply to the product and to this draft:
•	The primary programming language is Dart with Flutter (PC; NFR in 2.6).
•	The product is local: it uses no project-owned server and stores data on the device (PC; S1; S3).
•	Automatic counting and voice logging need a phone with motion sensors and a microphone and the user’s permission (S3).
•	A true lock-screen control needs native code or an Android notification; the prototype provides an in-app quick-add bar (TBD-05).
•	Operating environment: Android phones; screens of 360 to 430 dp width are the design target (S4, ASM-02).
•	The quiz must work without complex artificial intelligence (S3).
•	Stitching must never double-count progress or corrupt the original session data (S3).
1.7 Assumptions and Dependencies
1.7.1 Assumptions
ID	Assumption
ASM-01	The product name is ‘AtomFit’ (prototype title); the MVP text uses ‘Atomic Fit’ (CF-01).
ASM-02	Delivery form: a local-first Flutter (Dart) mobile application for Android phones, built as a clickable prototype with real domain logic and simulated hardware by default; data is stored on the device and persists across restarts; a Firebase backend (authentication and database) is planned after the prototype and is outside the MVP (decided 2026-10-18; supersedes the earlier TypeScript web/PWA plan).
ASM-03	Proposed technology: Flutter stable, Dart 3, flutter_bloc (Bloc and Cubit), equatable, go_router, sembast with path_provider for local storage, uuid, intl, flutter_test, bloc_test, integration_test, flutter_lints (Section 2.6.1).
ASM-04	‘Backend’ in the MVP text means a local service layer inside the application. No remote server and no cloud synchronisation exist in the MVP; ‘offline synchronisation’ is implemented as durable local persistence plus idempotent writes (CF-03).
ASM-05	Accounts are local profiles on one device. Several local accounts may exist. No password reset by email is possible (TBD-01, TBD-02).
ASM-06	Epic EP-002 and stories US-007 to US-018 are derived from the prototypes and the template; they are treated as MVP-supporting and are not part of the MVP text.
ASM-07	Weights are in kilograms, heights in centimetres and durations in seconds. Unit selection is outside the MVP.
ASM-08	Input ranges: weight 0 to 999.9 kg (one decimal), repetitions 0 to 999.
ASM-09	English is the only MVP language; all text is externalised for later localisation.
ASM-10	Inactivity is counted in local calendar days from the most recent completed workout; micro sessions count as completed workouts.
ASM-11	The initial five exercises supported by automatic counting are: squat, bench or chest press, dumbbell curl, dumbbell shoulder press and tricep raise (proposal combining the MVP text and the prototypes; CF-11, TBD-08).
ASM-12	For automatic counting the phone is held in the hand or strapped to the moving limb or the bar; a phone in a pocket or lying on the floor is not supported (TBD-08).
ASM-13	All numeric performance, accuracy, coverage and usability thresholds are proposals to be confirmed by the team.
ASM-14	Training volume is the sum of weight multiplied by repetitions over all completed sets.
ASM-15	‘Continue last workout?’ reopens the most recent unfinished workout, including a micro session.
ASM-16	Destructive actions require confirmation, although the high-fidelity prototype deletes History entries immediately (CF-14).
ASM-17	Analytics events are stored on the device only; dashboards are outside the MVP (CF-17).
ASM-18	Child sessions of a stitched session are shown only inside the stitched card while the stitch exists.
ASM-19	Timestamps are stored in UTC with the IANA time-zone identifier; a session belongs to the calendar day of its start in that zone.
ASM-20	Exactly one Current program exists per user at any time.
ASM-21	Raw sensor samples and raw audio are never persisted.
ASM-22	The following are outside the MVP because no source mentions them: cloud sync, social features, wearable integration, nutrition tracking, payments, push notifications and an administrator role.

1.7.2 Dependencies
ID	Dependency	Needed for
DEP-01	Browser or platform motion-sensor interface (device motion or generic sensor) on the target phones.	US-001
DEP-02	A speech-to-text component (browser speech recognition or an on-device model); engine and offline behaviour TBD (TBD-06).	US-002
DEP-03	An Android notification with actions (via a Flutter plugin), or a native lock-screen mechanism, if the lock-screen feature is kept beyond the in-app quick-add bar (TBD-05).	US-003
DEP-04	Approved quiz rule table, safety limits and progression policy from the product owner (TBD-11, TBD-18).	US-004, US-006
DEP-05	Stitching eligibility rules (TBD-17).	US-006
DEP-06	Exercise catalogue content and program descriptions (TBD-19, TBD-20); the PDF contains placeholder text.	US-012, US-013
DEP-07	Test devices and test participants for the accuracy and usability tests (TBD-09).	NFR tests
DEP-08	Open-source packages named in Section 2.6.1 and their licences.	All
DEP-09	Design assets from the prototypes (logo, colour palette, icons).	All screens

1.8 Definitions
Term	Definition
Epic	A broad objective that groups related user stories.
User story	A requirement written from the user’s perspective: who wants what and why.
MVP	Minimum Viable Product: the smallest release that delivers and evaluates the core value.
Repetition (rep)	One complete execution of an exercise movement.
Set	A group of consecutive repetitions of one exercise, recorded with a weight.
Session	One recorded workout, of type full, micro or stitched.
Micro session	A saved, incomplete workout that preserves the work already done and can be resumed.
Stitched session	A parent session that references two child sessions and presents their combined metrics.
Program	A named plan of exercises with sets, planned weights and rest times.
Current program	The program that the user currently follows; exactly one per user (ASM-20).
Adjusted program	A program changed by the quiz rule engine and stored as a new program version.
Rule engine	A component that applies predefined, documented conditions to produce program adjustments.
Save-Set service	The single service that stores a set, used by every input method.
Inactive user	A user whose most recent completed workout started at least 7 local calendar days ago.
Local-first	A design in which all data is stored on the device and all functions work without a network.
Progression	The rule by which weights or repetitions of future workouts are increased, kept or reduced.
Volume	The sum of weight multiplied by repetitions over completed sets (ASM-14).
TBD	To be determined: information missing from the sources, registered in Section 4.3.

1.9 Acronyms and Abbreviations
Acronym	Meaning
AC	Acceptance Criterion
API	Application Programming Interface
ASM	Assumption
CSV	Comma-Separated Values
E2E	End to end
EP	Epic
FR	Functional Requirement
GUI	Graphical User Interface
IANA	Internet Assigned Numbers Authority
JSON	JavaScript Object Notation
MVP	Minimum Viable Product
NFR	Non-Functional Requirement
PDF	Portable Document Format
PWA	Progressive Web App
QA	Quality Assurance
SRS	Software Requirements Specification
TBD	To Be Determined
UI	User Interface
US	User Story
UTC	Coordinated Universal Time
WCAG	Web Content Accessibility Guidelines

2. REQUIREMENTS
2.1 External Interfaces
2.1.1 User Interfaces
The table lists every screen. Screens SCR-01 to SCR-17 exist in the prototypes (S2 and S4). Screens SCR-18 to SCR-25 are required by the MVP text but are missing from both prototypes and must be designed.
ID	Screen	Key elements	Source	Related FR
SCR-01	Login	Logo, email, password, ‘Forgot password?’, Login, ‘Register here’	S2; S4	FR-005, FR-007
SCR-02	Register	Username, email, password, confirm password, date of birth, terms checkbox, Register, Back	S2; S4	FR-001–FR-004
SCR-03	Home	Welcome text, username, month calendar, monthly count, ‘Continue last workout?’, quiz control, bottom navigation	S2; S4	FR-015–FR-020
SCR-04	Profile	Picture, username, email, date of birth, weight, height, Update Profile, Log Out Account	S2; S4	FR-006, FR-008–FR-010
SCR-05	Settings	Display, Personalization, About app	S2; S4	FR-011–FR-014
SCR-06	Quiz question	Progress indicator, question, answer options, ‘Next question’ or ‘See my program’, Back	S2; S4	FR-077–FR-082, FR-088
SCR-07	Quiz program preview	‘This is your adjusted current program!’, exercise table, Accept	S2; S4	FR-085–FR-087
SCR-08	Start workout	Start empty program, Current program, All program, Adjusted program, Explore exercise	S2; S4	FR-021, FR-027
SCR-09	All programs	Program cards with name and description	S2; S4	FR-023
SCR-10	Program detail	Exercise table, Edit program, ‘Confirm edit?’ dialog	S2; S4	FR-024, FR-025
SCR-11	Explore exercise	Exercise cards, add control, ‘Add to which program?’ sheet	S2; S4	FR-029–FR-031
SCR-12	Active workout (program)	Exercise table with editable weight and reps, rest-time links, Finish	S2; S4	FR-033–FR-036, FR-039
SCR-13	Active workout (empty)	‘Pick…’ control, ‘Add more set?’, ‘Add another exercise?’, Finish	S2; S4	FR-032, FR-037, FR-038
SCR-14	Rest timer	Time display, −15s, +15s, Set timer, Cancel, Pause, Resume, Skip	S2; S4	FR-043–FR-048
SCR-15	Workout completed	Total Time, Total Set, ‘Go to home page’	S2; S4	FR-040, FR-041
SCR-16	History list	Search field, dated entries, delete control	S2; S4	FR-109–FR-111, FR-113
SCR-17	History detail	Date, name, read-only exercise table	S2; S4	FR-112
SCR-18	Quiz prompt	‘Start quiz’, ‘Not now’	S3 (no prototype)	FR-075, FR-076
SCR-19	Auto-count live counter	Large counter, Start set, Stop, +1, −1, error message	S3 (no prototype)	FR-049, FR-055–FR-057, FR-059
SCR-20	Voice confirmation card	Microphone button, listening indicator, interpreted values, confirm, edit, cancel, retry message	S3 (no prototype)	FR-060, FR-062, FR-065, FR-066
SCR-21	Lock-screen control	‘+1 repetition’, ‘+1 set’, current count	S3 (no prototype)	FR-069, FR-071
SCR-22	Exit sheet	‘Save as micro session’, ‘Discard’, ‘Continue workout’	S3 (no prototype)	FR-090, FR-091, FR-097
SCR-23	Micro-session history card and resume screen	Micro badge, completed summary, Resume	S3 (no prototype)	FR-094–FR-096
SCR-24	Stitching selection and preview	Selection mode, eligibility indicators, combined-metrics preview, confirm	S3 (no prototype)	FR-100–FR-102
SCR-25	Stitched session card and unstitch dialog	Expandable parent card, Unstitch, confirmation	S3 (no prototype)	FR-104, FR-106

2.1.2 Hardware Interfaces
•	Accelerometer and gyroscope: read during an active automatic-counting set (FR in 2.2.6); sampling limits are in 2.4.
•	Microphone: used for voice logging after permission (FR in 2.2.7).
•	Vibration motor: 300 ms signal at the end of the rest timer where supported (FR in 2.2.5).
•	Touch screen: minimum touch target 44 × 44 CSS pixels (NFR in 2.3).
2.1.3 Software Interfaces
•	Local database: IndexedDB through a typed repository layer (2.5, 2.6.1).
•	Speech recognition: engine TBD-06.
•	Lock-screen control: platform plug-in TBD-05.
•	Export files: JSON and CSV (Future).
2.1.4 Communications Interfaces
None in the MVP (Section 1.3.5). 
2.2 Functions
Each functional requirement has an identifier FR-nnn, a priority (Must, Should, Could, Won’t), a scope (MVP or Future), a source code (S1 to S4, PC, ASM), an acceptance criterion AC-nnn whose number equals the FR number, and its related user stories and dependencies. Statements use ‘shall’. Items that depend on an unanswered question point to the TBD register in Section 4.3.
2.2.1 Account and Profile
These requirements are derived from the login, registration, profile and settings screens of the prototypes. Because the product is local, accounts are local profiles (ASM-05). Whether an account is needed at all is open (TBD-01).
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
FR-001	The system shall allow a new user to create a local account by submitting a username, an email address, a password, a password confirmation, a date of birth and a gender.	Should	MVP	S2; S4	AC-001: Given the Register screen, when the user submits valid values in all six fields and selects the terms checkbox, then an account record is stored and the Login screen is displayed.	US-007
FR-002	The system shall reject a registration and display the message ‘Passwords do not match’ when the password and the password confirmation differ.	Should	MVP	S4	AC-002: Given different values in Password and Confirm Password, when Register is selected, then no account is stored and the message is displayed.	US-007
Dep: FR-001
FR-003	The system shall reject a registration and display the message ‘Please accept the terms’ when the terms and conditions checkbox is not selected.	Should	MVP	S2; S4	AC-003: Given the checkbox is cleared, when Register is selected, then no account is stored and the message is displayed.	US-007
Dep: FR-001
FR-004	The system shall reject a registration when a required field is empty, when the email address is not in a valid format, when the email address already belongs to a local account, or when the date of birth is not a valid calendar date in the past.	Should	MVP	ASM	AC-004: Given each of the four invalid inputs in turn, when Register is selected, then no account is stored and an error message names the invalid field.	US-007
Dep: FR-001
FR-005	The system shall authenticate a user by comparing the entered email address and password with the stored account credentials and shall display the Home screen only when they match.	Should	MVP	S2; S4	AC-005: Given a registered account, when matching credentials are submitted, then Home is displayed; when non-matching credentials are submitted, then the message ‘Incorrect email or password’ is displayed and Home is not displayed.	US-008
Dep: FR-001
FR-006	The system shall allow a signed-in user to log out from the Profile screen and shall then display the Login screen.	Should	MVP	S2; S4	AC-006: Given a signed-in user on Profile, when Log Out Account is selected, then the Login screen is displayed and Home cannot be reached without logging in again.	US-008
FR-007	The system shall display a ‘Forgot password?’ link on the Login screen.	Could	Future	S2; S4	AC-007: Given the Login screen, then the link is visible; the behaviour of the link is TBD (TBD-02) because a local product cannot send a reset email.	US-008
FR-008	The system shall display the username, email address, date of birth, gender, weight in kilograms and height in centimetres of the signed-in user on the Profile screen.	Should	MVP	S2; S4	AC-008: Given a signed-in user with stored values, when Profile is opened, then the six values are displayed.	US-010
FR-009	The system shall store the edited username, email address, date of birth, weight and height when the user selects Update Profile, and shall display the message ‘Profile updated’.	Should	MVP	S2; S4	AC-009: Given edited values, when Update Profile is selected, then the values are stored, remain after restart and the message is displayed.	US-010
Dep: FR-008
FR-010	The system shall allow the user to change the profile picture.	Could	Future	S2; S4	AC-010: Given an image selected by the user, when it is confirmed, then it replaces the default avatar and remains after restart.	US-010
FR-011	The system shall provide a Settings screen that lists three entries: Display, Personalization and About app, each with a one-line description.	Should	MVP	S2; S4	AC-011: Given the Settings screen, then the three entries and their descriptions are visible.	US-011
FR-012	The system shall switch between a light theme and a dark theme when the user selects the Display entry and shall store the choice.	Should	MVP	S4	AC-012: Given the light theme, when Display is selected, then the dark theme is applied on all screens and is still applied after restart.	US-011
Dep: FR-011
FR-013	The system shall display the application name and version number when the About app entry is selected.	Could	MVP	S2; S4	AC-013: Given the Settings screen, when About app is selected, then the name ‘AtomFit’ and the version number are displayed. Developer information content is TBD (TBD-26).	US-011
Dep: FR-011
FR-014	The system shall provide user-configurable personalization options (content TBD).	Won't	Future	S2; S4	AC-014: Not applicable to the MVP; the Personalization entry displays ‘Coming soon’ until TBD-26 is resolved.	US-011
Dep: FR-011

2.2.2 Home and Navigation
These requirements are derived from the Home screen and bottom navigation shown in the prototypes.
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
FR-015	The system shall display a bottom navigation bar with the destinations Home, History, Discover and Profile (Home leftmost) on the main screens and shall highlight the current destination; while Home is the current destination, the Home item shall be unclickable.	Must	MVP	S2; S4; lecturer feedback	AC-015: Given any main screen, then the bar shows four destinations in the order Home, History, Discover, Profile, the current one is highlighted, each other destination opens its screen, and Home does nothing while it is current.	US-009
FR-016	The system shall display the text ‘Welcome back!’ and the username on the Home screen.	Should	MVP	S2; S4	AC-016: Given a signed-in user ‘Joe123’, when Home is opened, then ‘Welcome back!’ and ‘Joe123’ are displayed.	US-009
FR-017	The system shall display a calendar of the current month on the Home screen, mark each day on which at least one workout was completed and highlight today.	Should	MVP	S4	AC-017: Given workouts completed on 1, 3 and 5 of the month, when Home is opened, then days 1, 3 and 5 are marked and today is highlighted.	US-009
Dep: FR-039
FR-018	The system shall display the number of workouts completed in the current month on the Home screen.	Should	MVP	S4	AC-018: Given three workouts completed this month, when Home is opened, then the count shown is 3.	US-009
Dep: FR-039
FR-019	The system shall provide a ‘Continue last workout?’ control on the Home screen that reopens the most recent unfinished workout with all entered data.	Must	MVP	S2; S3; S4	AC-019: Given an unfinished workout with 2 recorded sets, when the control is selected, then the workout screen opens with those 2 sets present. The control behaviour when no unfinished workout exists is TBD (TBD-15).	US-009
Dep: FR-117
FR-020	The system shall provide a quiz control on the Home screen that opens question 1 of the quiz.	Must	MVP	S2; S4	AC-020: Given the Home screen, when the quiz control is selected, then question 1 is displayed.	US-009
Dep: FR-077

2.2.3 Programs and Exercise Exploration
These requirements are derived from the Start workout, All programs, program detail and Explore exercise screens of the prototypes.
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
FR-021	The system shall provide, on the Home screen, an Empty workout action and a My programs list (Current program, other programs, Adjusted program), and shall provide Explore exercise on the Discover screen.	Must	MVP	S2; S4	AC-021: Given the Home screen, then Empty workout and My programs are visible and each opens its target screen; given the Discover screen, then exercises can be explored.	US-014
FR-022	The system shall provide three built-in programs at first start: Upper Lower, Push Pull Leg and Gorilla Training, where Push Pull Leg contains Dumbbell curl, Chest press, Tricep raise and Lat pulldown, each with 3 sets of 10 kg and a 2:00 rest time.	Should	MVP	S2; S4	AC-022: Given a new installation, when programs are listed, then three programs exist and the Push Pull Leg content equals the stated values. The content of the other two programs is TBD (TBD-19).	US-012
FR-023	The system shall list the available programs, each with its name and a description, on the All programs screen.	Should	MVP	S2; S4	AC-023: Given the three built-in programs, when All programs is opened, then each is listed with a non-empty description.	US-012
Dep: FR-022
FR-024	The system shall display, for a selected program, each exercise with its set numbers, planned weight in kilograms and planned rest time.	Should	MVP	S2; S4	AC-024: Given Push Pull Leg, when it is opened, then 4 exercises with 3 sets each are displayed with weight and rest values.	US-012
Dep: FR-022
FR-025	The system shall apply an edit to a program only after the user selects ‘Yes’ on a ‘Confirm edit?’ dialog and shall discard the edit when the user selects ‘Cancel’.	Should	MVP	S2; S4	AC-025: Given a modified program, when Cancel is selected, then the stored program is unchanged; when Yes is selected, then the stored program equals the modified program. The editable attributes are TBD (TBD-19).	US-012
Dep: FR-024
FR-026	The system shall maintain exactly one Current program for each user.	Should	MVP	ASM	AC-026: Given any user account, when the Current program is requested, then exactly one program is returned. How the user selects it is TBD (TBD-19).	US-012
FR-027	The system shall open the most recent quiz-adjusted program preview from the Adjusted program action, or display the message ‘No adjusted program yet’ when none exists.	Should	MVP	S2; S4; ASM	AC-027: Given no completed quiz, when Adjusted program is selected, then the message is displayed; given a completed quiz, then the preview is displayed.	US-012
Dep: FR-085
FR-028	The system shall provide an initial exercise catalogue containing at least Barbell shoulder press, Dumbbell shoulder press, Inverted plank, Dumbbell curl, Chest press, Tricep raise and Lat pulldown.	Should	MVP	S2; S4	AC-028: Given a new installation, when the exercise catalogue is queried, then the seven named exercises are returned. The full catalogue is TBD (TBD-20).	US-013
FR-029	The system shall display on the Explore exercise screen a list of exercises, each with a name, a short description and an add control.	Should	MVP	S2; S4	AC-029: Given the Explore exercise screen, then each exercise shows a name, a description and an add control.	US-013
Dep: FR-028
FR-030	When the user selects the add control of an exercise opened from the Start workout screen, the system shall display an ‘Add to which program?’ list and shall add the exercise to the program the user selects.	Should	MVP	S2; S4	AC-030: Given Barbell shoulder press and the program Upper lower selected, then the Upper lower program contains the exercise afterwards.	US-013
Dep: FR-029
FR-031	When the user selects the add control of an exercise opened from an active workout, the system shall add the exercise to that workout and return to the workout screen.	Must	MVP	S2; S4	AC-031: Given an active empty workout, when Dumbbell curl is added, then the workout table contains Dumbbell curl and the workout screen is displayed.	US-013; US-014
Dep: FR-029

2.2.4 Manual Workout Logging
Manual logging is the foundation on which the three tracking stories (US-001 to US-003) and the micro-session story (US-005) build; all of them reuse the Save-Set service (FR-118).
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
FR-032	The system shall start an empty workout containing one blank set row and a ‘Pick…’ control for choosing the exercise.	Must	MVP	S2; S4	AC-032: Given the Start workout screen, when Start empty program is selected, then a workout screen with one blank set row and a ‘Pick…’ control is displayed.	US-014
FR-033	The system shall start a workout pre-populated from the Current program, a selected program or the adjusted program when the user selects the corresponding Start workout action.	Must	MVP	S2; S4	AC-033: Given the Current program Push Pull Leg, when Current program is selected, then the workout table contains its 4 exercises and 12 sets.	US-014
Dep: FR-022
FR-034	The system shall display an active workout as a table with the columns Exercise, Set, Reps and Rest time and shall display the weight in kilograms beside each set number.	Must	MVP	S2; S4	AC-034: Given an active workout, then the four columns are displayed and every set row shows its weight in kg.	US-014
FR-035	The system shall allow the user to edit the weight of each set of an active workout as a number from 0 to 999.9 kg with at most one decimal place.	Should	MVP	S4; ASM	AC-035: Given a set, when 12.5 is entered, then 12.5 is stored; when 1000 or -1 is entered, then the value is rejected with an error message.	US-014
Dep: FR-034
FR-036	The system shall allow the user to enter the repetitions of each set of an active workout as a whole number from 0 to 999.	Must	MVP	S2; S4; ASM	AC-036: Given a set, when 10 is entered, then 10 is stored; when 10.5, -1 or 1000 is entered, then the value is rejected with an error message.	US-014
Dep: FR-034
FR-037	When the user selects ‘Add more set?’, the system shall append a set to the last exercise using the weight and rest time of the previous set.	Must	MVP	S2; S4	AC-037: Given a last exercise whose final set is 10 kg with 2:00 rest, when the control is selected, then a new blank-rep set with 10 kg and 2:00 is appended.	US-014
Dep: FR-034
FR-038	When the user selects ‘Add another exercise?’, the system shall open the Explore exercise screen and, after an exercise is selected, shall append it to the workout with one blank set.	Must	MVP	S2; S4	AC-038: Given an active workout, when the control is selected and Inverted plank is chosen, then the workout contains Inverted plank with one set.	US-014
Dep: FR-031
FR-039	When the user selects Finish, the system shall store the workout as a full session in History with its start date and time, program name and all sets, and shall display the Workout Completed screen.	Must	MVP	S2; S4	AC-039: Given an active workout with recorded sets, when Finish is selected, then a session of type ‘full’ exists in History and the Workout Completed screen is displayed.	US-014
Dep: FR-034; FR-118
FR-040	The system shall display on the Workout Completed screen the total elapsed time in mm:ss and the total number of completed sets, where a completed set is a set with at least 1 repetition recorded.	Should	MVP	S2; S4; ASM	AC-040: Given a workout of 76 minutes 6 seconds with 13 sets that have at least 1 repetition, then the screen shows Total Time 76:06 and Total Set 13.	US-014
Dep: FR-039
FR-041	The system shall display the Home screen when the user selects ‘Go to home page’ on the Workout Completed screen.	Should	MVP	S2; S4	AC-041: Given the Workout Completed screen, when the control is selected, then Home is displayed.	US-014
Dep: FR-040
FR-042	The system shall express weights in kilograms and shall not offer another unit in the MVP.	Should	MVP	S2; S4; ASM	AC-042: Given any screen that displays a weight, then the unit label is kg and no unit selector exists.	US-014

2.2.5 Rest Timer
These requirements are derived from the Rest Timer screens of the prototypes.
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
FR-043	The system shall open the Rest Timer screen, preset to the planned rest time of the set, when the user selects the rest time of a set in an active workout.	Should	MVP	S2; S4	AC-043: Given a set with rest 2:00, when its rest time is selected, then the timer screen shows 2:00.	US-015
FR-044	Before the countdown starts, the system shall allow the user to decrease or increase the duration in steps of 15 seconds, with a minimum of 15 seconds.	Should	MVP	S4	AC-044: Given a preset of 0:30, when −15s is selected twice, then the duration is 0:15; when +15s is selected once, then it is 0:30.	US-015
Dep: FR-043
FR-045	The system shall start the countdown when the user selects ‘Set timer’ and shall display the remaining time in mm:ss, updated every second.	Should	MVP	S2; S4	AC-045: Given a preset of 0:10, when Set timer is selected, then the display shows 0:09 after 1 second (± 0.5 s).	US-015
Dep: FR-043
FR-046	While the countdown runs, the system shall provide Pause, Resume and Skip controls, where Skip ends the countdown and returns to the workout.	Should	MVP	S2; S4	AC-046: Given a running countdown, when Pause is selected, then the time stops changing; when Resume is selected, then it continues; when Skip is selected, then the workout screen is displayed.	US-015
Dep: FR-045
FR-047	When the countdown reaches 0:00, the system shall return to the active workout and shall vibrate the device for 300 ms where the platform supports vibration.	Should	MVP	S4	AC-047: Given a countdown that reaches 0:00 on a device that supports vibration, then the workout screen is displayed and a 300 ms vibration is requested. Sound alerts are TBD (TBD-27).	US-015
Dep: FR-045
FR-048	When the user selects Cancel before the countdown starts, the system shall return to the active workout without changing any set.	Should	MVP	S4	AC-048: Given a timer screen that has not started, when Cancel is selected, then the workout screen is displayed and no stored value has changed.	US-015
Dep: FR-043

2.2.6 Automatic Repetition Counting (US-001)
Source: MVP text, Story 1. The prototypes contain no automatic-counting screen, so the screen elements below come from the MVP text only (design notes: large live counter, start and stop states, error messages).
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
FR-049	The system shall allow the user to start a set for a selected exercise from the active workout screen, which activates automatic repetition counting.	Must	MVP	S3	AC-049: Given an active workout and a selected exercise, when Start set is selected, then the live counter shows 0 and sensor capture starts.	US-001
Dep: FR-034
FR-050	Where the platform requires user permission to read motion sensors, the system shall request it before the first automatic-counting set and shall offer manual entry if the user denies it.	Must	MVP	ASM	AC-050: Given a platform that requires permission, when the user denies it, then no sensor capture starts and manual rep entry is available.	US-001
Dep: FR-049
FR-051	While a set is active, the system shall read accelerometer and gyroscope samples from the device and shall stop reading them when the set ends.	Must	MVP	S3	AC-051: Given a simulated sensor stream, when a set is started, then samples are received; when the set is stopped, then no further samples are received.	US-001
Dep: FR-049
FR-052	The system shall apply a smoothing filter to the sensor signal before repetition detection.	Must	MVP	S3	AC-052: Given a recorded fixture signal with added noise, then the variance of the filtered signal is lower than that of the raw signal.	US-001
Dep: FR-051
FR-053	The system shall count one repetition for each peak of the filtered signal that exceeds the peak threshold and occurs at least the minimum interval after the previous counted peak.	Must	MVP	S3	AC-053: Given a fixture of 10 repetitions, then the count is 10; given a fixture with a second peak inside the minimum interval, then that peak is not counted.	US-001
Dep: FR-052
FR-054	The system shall use exercise-specific detection parameters (minimum interval and peak threshold) for each exercise supported by automatic counting.	Must	MVP	S3; ASM	AC-054: Given each supported exercise, then a parameter set exists, and changing the selected exercise changes the parameters used. The supported exercises are TBD (TBD-08).	US-001
Dep: FR-053
FR-055	The system shall update the displayed live repetition counter each time a repetition is counted.	Must	MVP	S3	AC-055: Given a simulated stream of 5 repetitions, then the displayed counter reads 1, 2, 3, 4 and 5 in turn. The latency limit is in the performance requirements.	US-001
Dep: FR-053
FR-056	The system shall provide +1 and −1 controls that change the displayed repetition count by one and shall not allow the count to fall below 0.	Must	MVP	S3	AC-056: Given a count of 0, when −1 is selected, then the count remains 0; given a count of 7, when +1 is selected, then the count is 8.	US-001
Dep: FR-055
FR-057	When the user stops the set, the system shall display the final count as an editable value.	Must	MVP	S3	AC-057: Given a counted set of 9, when Stop is selected, then 9 is displayed in an editable field.	US-001
Dep: FR-055
FR-058	The system shall save the completed set, with exercise, repetitions, weight and timestamp, through the Save-Set service.	Must	MVP	S3	AC-058: Given a stopped set of 9 repetitions at 20 kg, when the user confirms, then one set record with those values exists.	US-001
Dep: FR-057; FR-118
FR-059	The system shall display an error message and offer manual entry when the sensors are unavailable or when no repetition was counted during a set.	Must	MVP	S3	AC-059: Given an unavailable sensor, when a set is started, then an error message and manual entry are displayed; given a set that ends with 0 counted repetitions, then the same message is displayed.	US-001
Dep: FR-049

2.2.7 Voice-Based Workout Logging (US-002)
Source: MVP text, Story 2. The prototypes contain no voice screen. The speech-to-text engine and its offline behaviour are open (TBD-06).
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
FR-060	The system shall provide a microphone button on the active workout screen that starts voice logging.	Must	MVP	S3	AC-060: Given an active workout, when the microphone button is selected, then voice capture starts.	US-002
Dep: FR-034
FR-061	The system shall request microphone permission on first use and, if the user denies it, shall display a message and keep manual logging available.	Must	MVP	S3	AC-061: Given a first use, when permission is denied, then a message is displayed and no audio is captured.	US-002
Dep: FR-060
FR-062	While audio is being captured, the system shall display a listening indicator.	Must	MVP	S3	AC-062: Given active capture, then the indicator is visible; when capture ends, then the indicator is hidden.	US-002
Dep: FR-060
FR-063	The system shall convert captured speech to text using a speech-to-text component.	Must	MVP	S3	AC-063: Given a recorded sample phrase ‘ten reps squat’, then the component returns text that contains ‘squat’ and a number for the repetitions.	US-002
Dep: FR-062
FR-064	The system shall parse transcribed text into an exercise name, a repetition count and an optional weight.	Must	MVP	S3	AC-064: Given the text ‘10 reps squat’, then the result is exercise ‘squat’, repetitions 10 and no weight; given ‘squat 10 reps 60 kilos’, then the weight is 60 kg. The full grammar is TBD (TBD-07).	US-002
Dep: FR-063
FR-065	The system shall display a confirmation card showing the interpreted exercise, repetitions and weight, with controls to confirm, edit and cancel.	Must	MVP	S3	AC-065: Given a parsed result, then the card shows the three values and the three controls; when Cancel is selected, then nothing is saved.	US-002
Dep: FR-064
FR-066	If the transcribed text cannot be parsed into at least an exercise and a repetition count, the system shall display a retry message and shall not save any set.	Must	MVP	S3	AC-066: Given the text ‘hello there’, then a retry message is displayed and the number of stored sets is unchanged.	US-002
Dep: FR-064
FR-067	When the user confirms the card, the system shall save the set through the same Save-Set service that automatic counting uses.	Must	MVP	S3	AC-067: Given a confirmed card, then exactly one set record is created through the Save-Set service.	US-002
Dep: FR-065; FR-118
FR-068	The system shall recognise voice commands spoken in English in the MVP.	Should	MVP	ASM	AC-068: Given 20 English test phrases from the agreed phrase list, then at least 18 are parsed correctly. The agreed phrase list is TBD (TBD-07).	US-002
Dep: FR-064

2.2.8 Lock-Screen Quick Logging (US-003)
Source: MVP text, Story 3. A lock-screen control depends on operating-system capabilities that a Flutter application cannot fully provide; feasibility and platform are open (TBD-05, CF-02).
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
FR-069	While a workout is active, the system shall provide a persistent lock-screen control with a ‘+1 repetition’ action and a ‘+1 set’ action.	Must	MVP	S3	AC-069: Given an active workout on a supported device, when the device is locked, then the control with both actions is visible. The exact meaning of ‘+1 set’ is TBD (TBD-05).	US-003
FR-070	The system shall save each lock-screen action immediately through the Save-Set service.	Must	MVP	S3	AC-070: Given one tap on ‘+1 repetition’, then the stored repetition count has increased by one before the next tap is accepted.	US-003
Dep: FR-069; FR-118
FR-071	The system shall show in the application the same count as the lock-screen control after each lock-screen action.	Must	MVP	S3	AC-071: Given three taps on ‘+1 repetition’, when the application is opened, then the displayed repetition count is 3.	US-003
Dep: FR-070
FR-072	If the application is closed during a set, the system shall retain every count saved before closure and display it when the application is next opened.	Must	MVP	S3	AC-072: Given a count of 4 and the application force-closed, when it is reopened, then the count is 4.	US-003
Dep: FR-070
FR-073	The system shall remove the lock-screen control when the workout is finished or discarded.	Should	MVP	ASM	AC-073: Given an active workout, when Finish or Discard is selected, then the control is no longer displayed.	US-003
Dep: FR-069

2.2.9 Re-engagement Quiz (US-004)
Sources: MVP text Story 4; medium-fidelity PDF (question 1 and question 10); high-fidelity HTML (four questions). The sources conflict on the name, length and content of the quiz (CF-04, CF-05, CF-06, CF-07, CF-08). The requirements below follow the MVP text and add prototype behaviour that does not contradict it.
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
FR-074	The system shall classify a user as inactive when the most recent completed workout, full or micro, started on a local calendar day that is at least 7 days before today.	Must	MVP	S3; ASM	AC-074: Given a last workout 7 days ago, then the user is inactive; given 6 days ago, then the user is not inactive.	US-004
Dep: FR-039
FR-075	When an inactive user opens the application, the system shall display a quiz prompt with the options ‘Start quiz’ and ‘Not now’.	Must	MVP	S3	AC-075: Given an inactive user, when the application is opened, then the prompt with both options is displayed.	US-004
Dep: FR-074
FR-076	When the user selects ‘Not now’, the system shall dismiss the prompt and shall not display it again until a re-prompt rule is satisfied.	Must	MVP	S3; ASM	AC-076: Given a dismissed prompt, when the application is reopened within the re-prompt period, then no prompt is displayed. The re-prompt rule is TBD (TBD-12).	US-004
Dep: FR-075
FR-077	The system shall present the quiz one question per screen with a progress indicator, a ‘Next question’ control that is disabled until an answer is selected, and a Back control from question 2 onward, and shall label the last control ‘See my program’.	Must	MVP	S2; S4	AC-077: Given question 1 with no answer, then ‘Next question’ is disabled; after an answer is selected, then it is enabled; on the last question the control reads ‘See my program’.	US-004
FR-078	The system shall ask ‘What is your current fitness target?’ with the answer options Muscle gain, Staying healthy, Look fit and No target.	Must	MVP	S2; S3; S4	AC-078: Given the quiz, then question 1 shows the stated text and exactly four options.	US-004
Dep: FR-077
FR-079	The system shall ask the user for current energy with the answer options High, Normal and Low.	Must	MVP	S3; S4	AC-079: Given the quiz, then an energy question with exactly three options is displayed. The final wording is TBD (TBD-10).	US-004
Dep: FR-077
FR-080	The system shall ask the user for current motivation to exercise.	Must	MVP	S3	AC-080: Given the quiz, then a motivation question is displayed. The wording and options are TBD (TBD-10) because the prototypes do not contain this question.	US-004
Dep: FR-077
FR-081	The system shall ask how many days per week the user can train with the answer options 2 days, 3 days, 4 days and 5+ days.	Should	MVP	S4	AC-081: Given the quiz, then the days-per-week question with four options is displayed. Inclusion in the MVP is TBD (TBD-10).	US-004
Dep: FR-077
FR-082	The system shall ask ‘Do you still want to push?’ with the answer options ‘Yes, progress the weight’, ‘No, same program as last’ and ‘No, reduced intensity’.	Should	MVP	S2; S4	AC-082: Given the quiz, then the question is displayed with exactly the three options.	US-004
Dep: FR-077
FR-083	The system shall derive the adjusted session length, intensity and training frequency from the quiz answers using a deterministic, documented rule table and shall not use machine-learning components.	Must	MVP	S3	AC-083: Given each row of the approved rule table, then the computed adjustment equals the expected values, and no network request is made during computation. The rule table is TBD (TBD-11).	US-004
Dep: FR-078; FR-079; FR-080
FR-084	When more than one rule applies, the system shall resolve the conflict using a documented precedence order and shall not exceed documented safety limits for load, volume and frequency.	Must	MVP	S3	AC-084: Given an answer set that triggers two conflicting rules, then the result follows the documented precedence and stays within the limits. Limits are TBD (TBD-11).	US-004
Dep: FR-083
FR-085	The system shall display the adjusted program, with exercises, sets, weights and rest times, as a preview before it is applied.	Must	MVP	S2; S3; S4	AC-085: Given completed answers, when ‘See my program’ is selected, then the preview is displayed and the stored Current program is unchanged.	US-004
Dep: FR-083
FR-086	When the user selects Accept on the preview, the system shall store the adjusted program as a new program version and make it the Current program.	Must	MVP	S2; S3; S4	AC-086: Given a preview, when Accept is selected, then a new program version exists, it is the Current program, and the previous version is retained.	US-004
Dep: FR-085; FR-026
FR-087	The system shall allow the user to revert to the previous program version after the preview or after acceptance.	Must	MVP	S3	AC-087: Given an accepted adjustment, when Revert is selected, then the previous program version is the Current program. The revert window is TBD (TBD-13); the prototypes contain no revert control.	US-004
Dep: FR-086
FR-088	The system shall display on the quiz screens a statement that the quiz supports workout planning and is not a medical or psychological diagnosis.	Must	MVP	S3	AC-088: Given any quiz screen, then the statement is visible. The wording is TBD (TBD-14).	US-004
Dep: FR-077
FR-089	The system shall store every quiz attempt with its answers, completion status and timestamp.	Must	MVP	S3	AC-089: Given a completed quiz, then one attempt record and one answer record per question exist; given an abandoned quiz, then the attempt is stored with status ‘incomplete’.	US-004
Dep: FR-077

2.2.10 Micro Sessions (US-005)
Source: MVP text, Story 5. The prototypes show a Finish button but no early-exit flow, badge or resume screen; these elements are missing from the prototypes and must be designed.
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
FR-090	When the user attempts to leave an active workout that still has unfinished planned sets, the system shall display an exit sheet.	Must	MVP	S3	AC-090: Given an active workout with 1 recorded set and 3 unrecorded sets, when the user selects the Back control, then the exit sheet is displayed. The set of exit triggers is TBD (TBD-15).	US-005
Dep: FR-034
FR-091	The exit sheet shall offer the options ‘Save as micro session’, ‘Discard’ and ‘Continue workout’.	Must	MVP	S3; ASM	AC-091: Given the exit sheet, then the three options are displayed and ‘Continue workout’ closes the sheet without changes.	US-005
Dep: FR-090
FR-092	When the user selects ‘Save as micro session’, the system shall store the completed sets with session type ‘micro’ and completion status ‘incomplete’.	Must	MVP	S3	AC-092: Given 2 completed sets, when the option is selected, then a session with type ‘micro’, status ‘incomplete’ and those 2 sets exists.	US-005
Dep: FR-091; FR-118
FR-093	The system shall calculate and store, for each micro session, the number of completed sets, the total repetitions, the total volume (sum of weight multiplied by repetitions) and the elapsed duration.	Must	MVP	S3; ASM	AC-093: Given sets of 10 kg × 10 and 10 kg × 7, then the stored volume is 170 kg, repetitions 17 and sets 2.	US-005
Dep: FR-092
FR-094	The system shall display a micro-session badge on the History entry of every session of type ‘micro’.	Must	MVP	S3	AC-094: Given a micro session and a full session in History, then only the micro session shows the badge.	US-005
Dep: FR-092; FR-109
FR-095	The system shall display the completed exercise summary when the user opens a micro session from History.	Must	MVP	S3	AC-095: Given a micro session, when it is opened, then each completed exercise with its sets, weights and repetitions is displayed.	US-005
Dep: FR-094
FR-096	The system shall allow the user to resume a micro session, loading its completed sets and its remaining planned sets into an active workout.	Must	MVP	S3	AC-096: Given a micro session with 2 completed and 10 remaining sets, when Resume is selected, then an active workout shows 2 completed and 10 remaining sets.	US-005
Dep: FR-092
FR-097	When the user selects ‘Discard’ and confirms, the system shall delete the incomplete workout and shall create no session record.	Must	MVP	S3; ASM	AC-097: Given an incomplete workout, when Discard and then Confirm are selected, then the number of stored sessions is unchanged.	US-005
Dep: FR-091
FR-098	The system shall not create more than one session record when the same micro-session save is executed more than once.	Must	MVP	S3	AC-098: Given the same save command executed twice with the same identifier, then exactly one session record exists.	US-005
Dep: FR-092; FR-119
FR-099	The system shall count a micro session as a completed workout for the Home calendar, the monthly workout count and the inactivity rule.	Should	MVP	ASM	AC-099: Given only a micro session completed today, then today is marked on the calendar and the user is not classified as inactive. Streak behaviour is TBD (TBD-16).	US-005
Dep: FR-092; FR-017; FR-074

2.2.11 Set Stitching (US-006)
Source: MVP text, Story 6. The prototypes contain no stitching screens. The eligibility rules and the progression policy are not specified in the sources (TBD-17, TBD-18).
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
FR-100	The system shall provide a selection mode in History that allows the user to select exactly two sessions.	Must	MVP	S3	AC-100: Given History in selection mode, when a third session is selected, then the selection is rejected and two remain selected.	US-006
Dep: FR-109
FR-101	The system shall evaluate the two selected sessions against documented eligibility rules and shall display the reason when they are ineligible.	Must	MVP	S3	AC-101: Given an ineligible pair, then the stitch action is disabled and a reason is displayed; given an eligible pair, then it is enabled. The rules are TBD (TBD-17).	US-006
Dep: FR-100
FR-102	The system shall display a preview of the combined session metrics before the stitch is confirmed.	Must	MVP	S3	AC-102: Given an eligible pair of 10 and 12 sets, then the preview shows 22 sets and the combined repetitions, volume and duration.	US-006
Dep: FR-101
FR-103	When the user confirms, the system shall create a parent stitched session that references both child sessions by identifier and shall leave the sets, repetitions and weights of the child sessions unchanged.	Must	MVP	S3	AC-103: Given a confirmed stitch, then one parent record references two child identifiers and the child data is identical to its data before the stitch.	US-006
Dep: FR-102
FR-104	The system shall display a stitched session in History as one expandable card that shows its two child sessions when expanded.	Must	MVP	S3; ASM	AC-104: Given a stitched session, then History shows one card; when expanded, then both children are shown; the children are not listed separately at top level.	US-006
Dep: FR-103
FR-105	The system shall count the metrics of each child session exactly once in all totals and statistics.	Must	MVP	S3	AC-105: Given two sessions of 10 sets each that are stitched, then the total set count for the period is 20, not 40.	US-006
Dep: FR-103
FR-106	When the user confirms an unstitch, the system shall delete the parent record and restore both child sessions as separate top-level History entries.	Must	MVP	S3	AC-106: Given a stitched session, when Unstitch and then Confirm are selected, then the parent no longer exists, both children are listed and totals equal those before the stitch.	US-006
Dep: FR-103
FR-107	The system shall execute each stitch and each unstitch as one atomic operation that leaves no partial change when it fails.	Must	MVP	S3	AC-107: Given a forced failure during a stitch, then no parent record exists and both children are unchanged; the same holds for unstitch.	US-006
Dep: FR-103; FR-106
FR-108	The system shall compute future progression with a documented progression policy that returns the same result whether two eligible sessions are stitched or not.	Must	MVP	S3	AC-108: Given a fixture of two sessions, then the progression output before the stitch equals the output after the stitch. The policy is TBD (TBD-18).	US-006
Dep: FR-103

2.2.12 Workout History
These requirements are derived from the History screens of the prototypes and from the template search requirements.
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
FR-109	The system shall list stored sessions in reverse chronological order, each with its start date and time and its program name.	Must	MVP	S2; S4	AC-109: Given sessions started on 2026-10-15, 2026-10-29 and 2026-11-01, then the list order is 2026-11-01, 2026-10-29, 2026-10-15.	US-016
FR-110	The system shall filter the History list to sessions whose program name contains the entered text, ignoring letter case, and shall update the list after each keystroke.	Should	MVP	S1; S4	AC-110: Given sessions named ‘Push pull leg’ and ‘Empty program’, when ‘PUSH’ is entered, then only ‘Push pull leg’ is listed.	US-016
Dep: FR-109
FR-111	The system shall display the message ‘No workouts found’ when no session matches the entered text.	Should	MVP	S4	AC-111: Given the text ‘zzz’, then the message is displayed and the list is empty.	US-016
Dep: FR-110
FR-112	The system shall display, for a selected session, its date and time, its name and a read-only table of exercises with sets, weights, repetitions and rest times.	Must	MVP	S2; S4	AC-112: Given a stored session, when it is selected, then the read-only table shows all its sets.	US-016
Dep: FR-109
FR-113	The system shall delete a session from History only after the user confirms the deletion.	Should	MVP	S4; ASM	AC-113: Given a session, when Delete is selected and then Cancel, then the session remains; when Delete and then Confirm are selected, then the session is removed. The prototype deletes without confirmation (CF-14).	US-016
Dep: FR-109
FR-114	The system shall display session dates and times in the format YYYY-MM-DD HH:mm using the stored time zone.	Could	MVP	ASM	AC-114: Given a session started on 1 November 2026 at 19:35, then ‘2026-11-01 19:35’ is displayed (CF-16).	US-016
Dep: FR-109
FR-115	The system shall name a finished session after the program it was started from, or ‘Empty program’ when it was started empty.	Could	MVP	S2; S4	AC-115: Given a workout started from Push pull leg, then its name is ‘Push pull leg’. The meaning of the suffix ‘(1)’ in the PDF is TBD (TBD-22).	US-016
Dep: FR-039

2.2.13 Data Persistence and Local Storage
These requirements come from the template (offline operation, autosave, export) and from the MVP text (Save-Set reuse, offline saving, duplicate prevention, time zones). Cloud synchronisation is out of the MVP (CF-03).
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
FR-116	The system shall store all user data on the local device and shall require no network connection for any MVP function, except speech-to-text if the chosen engine requires one (TBD-06).	Must	MVP	S1; S3; PC	AC-116: Given a device in flight mode, when each MVP flow is executed, then it completes without a network error (speech-to-text excepted).	US-017
FR-117	The system shall persist every change to an active workout within 1 second and shall restore the workout after the application restarts.	Must	MVP	S1; S3	AC-117: Given a set recorded and the application force-closed 2 seconds later, when it is reopened, then the set is present.	US-017
FR-118	The system shall provide one Save-Set service, taking exercise, repetitions, weight and timestamp, that manual entry, automatic counting, voice logging and lock-screen actions all use.	Must	MVP	S3	AC-118: Given the four input paths, then each path invokes the Save-Set service (verified with a test spy) and no path writes sets by another route.	US-017
Dep: FR-117
FR-119	The system shall assign a client-generated unique identifier to every set and session and shall not create a second record when an identifier that is already stored is saved again.	Must	MVP	S3	AC-119: Given a set saved twice with the same identifier, then exactly one record exists.	US-017
Dep: FR-118
FR-120	The system shall store timestamps in UTC together with the IANA time-zone identifier and shall assign a session to the calendar day of its start time in the stored time zone.	Should	MVP	S3; ASM	AC-120: Given a session started at 23:50 in Asia/Jakarta and viewed on a device set to another time zone, then it is still assigned to the same calendar day. Midnight-spanning rules are TBD (TBD-17).	US-017
Dep: FR-119
FR-121	The system shall store a schema version with the local database and shall migrate existing data when a newer version is installed.	Should	MVP	ASM	AC-121: Given a database at version N with sample data, when version N+1 is installed, then all sample data is present after migration.	US-017
FR-122	The system shall export the workout history to a JSON file on request.	Could	Future	S1	AC-122: Given 3 stored sessions, when Export is selected, then a valid JSON file containing 3 sessions is produced.	US-017
Dep: FR-109
FR-123	The system shall export the workout history to a CSV file on request.	Could	Future	S1	AC-123: Given 3 stored sessions, when Export is selected, then a CSV file with one row per set is produced.	US-017
Dep: FR-109
FR-124	The system shall delete all locally stored user data when the user requests it and confirms.	Could	Future	ASM	AC-124: Given stored data, when deletion is requested and confirmed, then all tables are empty. Data-retention rules are TBD (TBD-25).	US-017

2.2.14 Analytics Events
Source: MVP text, section ‘Analytics and Quality Assurance’. The MVP text assumes events are measured and shown on dashboards but does not say where they are collected. Because the product is local, events are stored locally in the MVP (CF-17, TBD-23).
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
FR-125	The system shall record every analytics event in a common schema containing event name, UTC timestamp, anonymous user identifier, session identifier and a properties object.	Must	MVP	S3	AC-125: Given any recorded event, then it validates against the schema.	US-018
FR-126	The system shall record the events quiz_prompt_shown, quiz_started, quiz_completed, program_accepted and next_workout_started.	Must	MVP	S3	AC-126: Given a full quiz flow, then the five events are recorded in that order.	US-018
Dep: FR-125; FR-077
FR-127	The system shall record the events workout_quit, micro_session_saved, micro_session_discarded and workout_started_within_48h.	Must	MVP	S3	AC-127: Given a quit followed by a save and a new workout within 48 hours, then workout_quit, micro_session_saved and workout_started_within_48h are recorded.	US-018
Dep: FR-125; FR-090
FR-128	The system shall record the events stitch_started, stitch_preview_shown, stitch_confirmed, stitch_reversed and workout_started_within_48h.	Must	MVP	S3	AC-128: Given a stitch flow followed by an unstitch, then the corresponding events are recorded.	US-018
Dep: FR-125; FR-100
FR-129	The system shall compute from the stored events the quiz funnel (prompt shown, started, completed, accepted), the seven-day return rate, the micro-session save and discard rates, the 48-hour return rate and the stitch and unstitch rates.	Should	MVP	S3	AC-129: Given a fixture event set with known counts, then each computed rate equals the expected value.	US-018
FR-130	The system shall store analytics events only on the local device and shall not transmit them over a network in the MVP.	Must	MVP	ASM	AC-130: Given a recorded flow, then no outbound network request containing event data is made.	US-018
Dep: FR-125
FR-131	The system shall allow the user to turn off analytics event recording.	Should	MVP	ASM	AC-131: Given recording turned off, when a quiz flow is executed, then no event is stored.	US-018
Dep: FR-125
FR-132	The system shall display analytics dashboards for the measurements listed in the MVP text.	Could	Future	S3	AC-132: Not applicable to the MVP; dashboard location and audience are TBD (TBD-23).	US-018
Dep: FR-129

2.3 Usability Requirements
Vague qualities such as ‘user-friendly’ are replaced by measurable criteria. Numeric thresholds marked ASM are proposals for the team to confirm (ASM-13).
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
NFR-001	A first-time user shall be able to register, start an empty workout and save one set within 3 minutes without assistance.	Should	MVP	ASM	AC-101: In a moderated usability test with at least 5 participants, at least 4 complete the task within 3 minutes.	Rel: FR-001; FR-032
NFR-002	Every interactive control shall have a touch target of at least 44 × 44 CSS pixels.	Should	MVP	ASM	AC-102: An automated layout check of all screens reports zero controls smaller than 44 × 44 CSS pixels.	
NFR-003	Text and interactive controls shall have a contrast ratio of at least 4.5:1 in both the light and the dark theme.	Should	MVP	S4; ASM	AC-103: An automated accessibility audit of all screens in both themes reports zero contrast violations.	Rel: FR-012
NFR-004	Every control shall have an accessible name, and the complete quiz flow shall be operable with a screen reader.	Should	MVP	S3	AC-104: An automated audit reports zero critical violations, and a manual screen-reader walkthrough completes the quiz.	Rel: FR-077
NFR-005	The layout shall display without horizontal scrolling at viewport widths from 360 to 430 CSS pixels and shall be centred in a frame of at most 430 CSS pixels width on wider screens.	Must	MVP	S4	AC-105: Automated tests at widths 360, 390, 430 and 1280 CSS pixels find no horizontal scroll bar on any screen.	
NFR-006	The system shall display a confirmation or error message within 300 ms after any save, update, delete or validation failure.	Should	MVP	S4; ASM	AC-106: A timed automated test shows the message within 300 ms for each of the four event types.	
NFR-007	All user-facing text shall be held in a resource file keyed by identifier so that further languages can be added without code changes; English shall be the only language of the MVP.	Should	MVP	S3; ASM	AC-107: A static scan of the source finds no hard-coded user-facing string outside the resource file.	
NFR-008	Every destructive action (discard workout, delete session, unstitch, delete all data) shall require an explicit confirmation.	Should	MVP	S2; ASM	AC-108: For each destructive action, cancelling the confirmation leaves the data unchanged.	Rel: FR-097; FR-113; FR-106
NFR-009	While a set is active, the live counter and the primary set controls shall be visible without scrolling, and the counter text shall be at least 48 CSS pixels high.	Should	MVP	S3; ASM	AC-109: At 360 × 640 CSS pixels, the counter and the controls are fully visible and the computed counter font size is at least 48 px.	Rel: FR-055

2.4 Performance Requirements
The template contains example limits (start-up within 10 s, edit response within 1 s, scrolling stalls under 200 ms, documents of 10000 objects). They are adapted below to a mobile workout application. The reference device is TBD (TBD-09).
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
NFR-010	The system shall display an interactive Home screen within 3 seconds of a cold start for the 95th percentile of runs on the reference device.	Should	MVP	S1; ASM	AC-110: In 20 automated cold starts, at least 19 reach an interactive Home within 3 seconds.	
NFR-011	The system shall render each screen transition within 300 ms for the 95th percentile of transitions on the reference device.	Should	MVP	S1; ASM	AC-111: In an automated run of 100 transitions, at least 95 finish within 300 ms.	
NFR-012	The live repetition counter shall update within 200 ms of the moment a repetition is counted, for the 95th percentile of repetitions.	Must	MVP	S3; ASM	AC-112: In a run of 100 simulated repetitions, at least 95 counter updates occur within 200 ms.	Rel: FR-055
NFR-013	Each Save-Set operation shall complete within 200 ms for the 95th percentile of operations on the reference device.	Must	MVP	S3; ASM	AC-113: In a run of 100 saves, at least 95 complete within 200 ms.	Rel: FR-118
NFR-014	The system shall display the confirmation card within 3 seconds after the end of speech for the 95th percentile of commands, once the speech-to-text result is available.	Should	MVP	ASM	AC-114: In a run of 20 recorded commands, at least 19 show the card within 3 seconds.	Rel: FR-065
NFR-015	The History list shall render within 500 ms with 5000 stored sessions, shall update within 300 ms after each search keystroke and shall show no scrolling stall longer than 200 ms.	Should	MVP	S1; ASM	AC-115: With 5000 generated sessions, the three measurements are within the stated limits.	Rel: FR-109; FR-110
NFR-016	While a set is active, the system shall sample the motion sensors at an effective rate of at least 25 Hz and shall disable automatic counting with a message when the device cannot reach this rate.	Must	MVP	ASM	AC-116: On a device limited to 10 Hz, automatic counting is disabled and a message is displayed; on a device at 50 Hz, it is enabled.	Rel: FR-051
NFR-017	The rest timer shall deviate by no more than 1 second from real time over a 120-second countdown, including when the application is in the background.	Should	MVP	ASM	AC-117: In 10 runs of a 120-second countdown with the application backgrounded for 60 seconds, the deviation is at most 1 second.	Rel: FR-045
NFR-018	Automatic repetition counting shall count within ±1 repetition of the true count in at least 90 % of test sets for each supported exercise, using at least 20 test sets per exercise across the five supported exercises.	Must	MVP	S3; ASM	AC-118: A field test of 5 exercises × 20 sets compares counted and true repetitions; at least 18 of 20 sets per exercise are within ±1. The threshold is a proposal (TBD-09).	Rel: FR-053; FR-054

2.5 Logical Database Requirements
The logical data model is given in Section 2.5.1 and is informative. The constraints below are binding.
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
NFR-019	Every operation that changes more than one record (save session, stitch, unstitch, apply program version) shall be atomic: either all changes are stored or none.	Must	MVP	S3	AC-119: A forced failure in the middle of each listed operation leaves the database identical to its state before the operation.	Rel: FR-107; FR-086
NFR-020	The system shall not allow deletion of a session that is referenced by a stitched parent while the parent exists.	Should	MVP	S3; ASM	AC-120: Given a stitched pair, when deletion of one child is attempted, then it is rejected with a message that names the parent.	Rel: FR-103; FR-113
NFR-021	The system shall store weights in kilograms as decimal numbers, durations as whole seconds and heights in centimetres.	Must	MVP	S2; S4; ASM	AC-121: Given stored records, then weight fields are decimal kg values, duration fields are integers, and height is in cm.	Rel: FR-042
NFR-022	Every stored record shall carry created and last-updated timestamps in UTC.	Should	MVP	S1; ASM	AC-122: Given any record, then both timestamps are present and the last-updated value changes when the record is edited.	
NFR-023	The system shall retain stored data until the user deletes it and shall not delete data automatically.	Should	MVP	ASM	AC-123: Given 400-day-old sessions, then they are still present after restart (TBD-25).	
NFR-024	Exported data shall use an open, human-readable format.	Could	Future	S1	AC-124: A JSON export opens in a plain-text editor and parses with a standard JSON parser.	Rel: FR-122

2.5.1 Logical Data Model (informative)
The entities below support the functional requirements. Attribute names are proposals; entities and attributes marked S3 come from the data work named in the MVP text (session type, completion status, quiz attempt and answer, program version, program adjustment, stitched session).
Entity	Key attributes	Notes and relationships	Source
user_account	id, username, email, password_hash, salt, date_of_birth, created_at, updated_at	One per local account. Passwords never stored in plain text.	S2; S4
user_profile	user_id, weight_kg, height_cm, picture	One per user_account.	S2; S4
app_setting	user_id, theme (light or dark), analytics_enabled	Stored per user.	S4; ASM
exercise	id, name, description, difficulty_note	Catalogue entry; fields beyond name and description are TBD (TBD-20).	S2; S4
program	id, user_id (null for built-in), name, description, is_current	Exactly one is_current per user.	S2; S4
program_version	id, program_id, version_no, source (manual or quiz), created_at	A quiz adjustment creates a new version; the previous version is retained for revert.	S3
program_set	id, program_version_id, exercise_id, set_no, planned_weight_kg, planned_rest_s	Planned content of a program version.	S2; S4
workout_session	id (client UUID), user_id, program_version_id (nullable), name, type (full, micro or stitched), completion_status, parent_session_id (nullable), started_at_utc, time_zone, duration_s, created_at, updated_at	‘type’ and ‘completion_status’ distinguish micro sessions; parent_session_id links a child to a stitched parent.	S3
set_log	id (client UUID), session_id, exercise_id, set_no, weight_kg, reps, rest_s, input_method (manual, sensor, voice, lockscreen), logged_at_utc	Written only through the Save-Set service. input_method is an assumption.	S3; ASM
stitched_session	parent_session_id, child_session_ids (two), combined_sets, combined_reps, combined_volume_kg, combined_duration_s	Parent-child relationship; children keep their own set_log rows.	S3
quiz_attempt	id, user_id, started_at_utc, status (complete or incomplete)	One per quiz run.	S3
quiz_answer	id, quiz_attempt_id, question_key, answer_key	One per answered question.	S3
user_program_adjustment	id, quiz_attempt_id, program_version_from, program_version_to, session_length, intensity, frequency, accepted, reverted	Records what the rule engine changed.	S3
analytics_event	id, name, timestamp_utc, anon_user_id, session_id, properties (JSON)	Common event schema; stored locally.	S3; ASM

2.6 Design Constraints
The technology proposal that satisfies these constraints is in Section 2.6.1 and is an assumption (ASM-02, ASM-03).
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
NFR-025	All application source code shall be written in Dart (Flutter stable) with strict analysis options (strict-casts, strict-inference, strict-raw-types) enabled; generated code is allowed only where the team approves it.	Must	MVP	PC	AC-125: The command ‘flutter analyze’ reports zero issues, and a repository scan finds no hand-written platform source (Kotlin, Swift, Java) outside generated project files unless an approved record exists.	
NFR-026	The product shall run on the user’s device without a server operated by the project team.	Must	MVP	PC; S1	AC-126: The product starts and all MVP flows work with no project-owned server reachable.	Rel: FR-116
NFR-027	The product shall be implemented with the technology proposal in Section 2.6.1 unless the team approves an alternative in writing.	Should	MVP	ASM	AC-127: The dependency manifest matches the proposal or an approved deviation record exists.	
NFR-028	The build shall fail when ‘flutter analyze’ reports an issue or when a unit test fails.	Should	MVP	ASM	AC-128: A deliberate analyzer error and a deliberate failing test each cause the build to fail.	
NFR-029	The product shall contain no native (Kotlin, Swift or Java) business logic; where a device feature requires native code, it shall be a thin plug-in bridged to Dart.	Should	MVP	ASM	AC-129: A code review lists every native source file, and each contains no business logic.	Rel: FR-069

2.6.1 Flutter Stack Proposal and System Architecture (Assumption)
No source names a framework. The proposal below is an assumption (ASM-02, ASM-03). On 2026-10-18 it replaced the earlier TypeScript web stack with Flutter. The architecture keeps a framework-independent domain layer so that a Firebase-backed data layer can be added later without rewriting business logic.
Layer	Responsibility	Proposed technology	Status
Presentation	Screens, navigation, themes, accessibility, text resources	Flutter (Material 3), go_router, ThemeData built from design tokens, a typed strings file	Assumption
Application state	Screen state and user intents	flutter_bloc (Bloc and Cubit), equatable	Assumption
Domain core	Framework-independent business logic: session service, Save-Set service, repetition detector, voice parser, quiz rule engine, stitching service, progression policy, inactivity service, analytics service	Pure Dart (lib/domain) with no Flutter or plugin imports	Assumption
Device adapters	Access to motion sensors, microphone and speech-to-text, vibration and notifications behind Dart interfaces; simulated by default	Flutter plugins (sensors, speech, notifications) behind interfaces; simulated and replay implementations	Assumption
Persistence	Typed stores, transactions, schema version, idempotent writes	sembast (on-device document store) with path_provider, behind repository interfaces	Assumption
Backend (future)	Authentication and cloud database	Firebase Authentication and Cloud Firestore; not part of the MVP	Future
Build and quality	Analysis and formatting	flutter analyze with flutter_lints, dart format	Assumption
Testing	Unit, bloc, widget and flow tests with sensor and voice fixtures	flutter_test, bloc_test, integration_test	Assumption
Packaging	Installable Android application	Android app package built with Flutter	Assumption

Options considered for the delivery form:
Option	Description	Assessment against the sources	Recommendation
A. Flutter Android app, local-first	One Dart code base, data on the device, simulated hardware by default	Matches the prototype screens, runs on a real Android phone, real sensors and microphone are reachable through plugins	Recommended
B. Flutter app with Firebase added later	Same code base with a Firebase data layer behind the repository interfaces	Adds accounts and cloud storage after the prototype	Planned next phase
C. React and TypeScript web app (PWA)	Earlier plan	Cannot provide a lock-screen control and weak sensor access on some browsers	Superseded
D. Native Kotlin Android app	Native code for the platform	Longer to build and not needed for a prototype	Not recommended

The proposed project structure and package allow-list are defined in AGENTS.md Sections 3 and 6.

2.7 Standards Compliance
This SRS follows the ISO/IEC/IEEE 29148:2018 structure used by the template. The product-level standards below are proposals unless marked otherwise.
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
NFR-030	The user interface shall conform to WCAG 2.2 level AA success criteria that apply to mobile web content.	Should	MVP	ASM	AC-130: An accessibility audit against WCAG 2.2 AA finds no unresolved failure for the applicable criteria.	Rel: NFR-004
NFR-031	Device access shall use well-maintained Flutter plugins or standard platform interfaces (motion sensors, microphone, vibration) rather than custom native code where such a plugin exists.	Should	MVP	ASM	AC-131: A code review finds no custom native code where a maintained plugin exists.	Rel: FR-051; FR-060
NFR-032	The product shall comply with the data-protection regulations that apply to its deployment jurisdictions (TBD-25).	Must	MVP	ASM	AC-132: A privacy review against the regulations named in TBD-25 finds no open non-conformity.	

2.8 Software System Attributes
Attributes are grouped as reliability, security, privacy, maintainability and portability.
ID	Requirement	Priority	Scope	Source	Acceptance criterion	Related
NFR-033	After the application is force-closed during an active workout, a relaunch shall restore every set that was stored at least 1 second before closure, with no set lost.	Must	MVP	S3	AC-133: In 20 forced closures at random times, every set stored at least 1 second earlier is present after relaunch.	Rel: FR-117
NFR-034	When a write to local storage fails, the system shall display an error message and keep the unsaved data in memory until the user retries or discards it.	Should	MVP	ASM	AC-134: With a simulated storage-full error, a message is displayed and a retry stores the data.	
NFR-035	The system shall sanitise all data entered by the user before storing or displaying it.	Must	MVP	S1	AC-135: Entering ‘<script>alert(1)</script>’ in every text field stores it as inert text and executes no script.	
NFR-036	The system shall store passwords only as salted hashes produced by a slow key-derivation function and never in plain text.	Must	MVP	ASM	AC-136: Inspection of the stored account record shows a salt and a hash and no plain-text password.	Rel: FR-001
NFR-037	The system shall not send user data to the Internet in the MVP, except any speech-to-text request permitted by TBD-06.	Must	MVP	S1	AC-137: A network trace of all MVP flows shows no request that contains user data (speech-to-text excepted).	Rel: FR-116
NFR-038	The system shall encrypt persistent application data at rest.	Could	MVP	S1; ASM	AC-138: Inspection of the stored data shows no readable workout content. Feasibility is TBD (TBD-24).	
NFR-039	Withdrawn in the Flutter edition: a web content-security policy does not apply. The prototype shall make no network requests (see NFR-037).	Won't	MVP	ASM	AC-139: Not applicable.	
NFR-040	The system shall process raw motion-sensor samples and raw audio in memory only and shall not store them.	Must	MVP	ASM	AC-140: After an automatic-counting set and a voice command, no sensor or audio data exists in storage.	Rel: FR-051; FR-063
NFR-041	The system shall explain the purpose of the sensor and microphone permissions on screen before the platform permission prompt is shown.	Should	MVP	ASM	AC-141: Given first use of each feature, then an explanatory message is displayed before the platform prompt.	Rel: FR-050; FR-061
NFR-042	The core domain modules (repetition detector, voice parser, quiz rule engine, session service, stitching service, progression policy) shall have at least 80 % line coverage from automated unit tests.	Should	MVP	ASM	AC-142: The coverage report shows at least 80 % line coverage for each listed module.	
NFR-043	The core domain modules shall contain no import of user-interface or device-adapter code.	Should	MVP	ASM	AC-143: A dependency-rule check reports zero forbidden imports.	
NFR-044	The test suite shall reuse shared fixtures for time zones, offline operation and application termination across all features.	Should	MVP	S3	AC-144: The three fixtures exist once and are imported by the tests of at least three features.	
NFR-045	The product shall run on Android phones running a currently supported Android version; the minimum supported version is TBD (TBD-04).	Should	MVP	S1; ASM	AC-145: The widget and flow tests pass and the demo script completes on a physical Android phone.	
NFR-046	The product shall be installed as an Android application and shall start and operate without a network connection.	Should	MVP	ASM	AC-146: After installation, in flight mode, the application starts from its launcher icon and all MVP flows (speech-to-text excepted if it needs a network) work.	Rel: FR-116
 
3. VERIFICATION
3.1 Verification Approach
Verification tests are specified in the document ATOMFIT-TESTS, which is TBD. The MVP text asks that test cases be written early, so each requirement’s acceptance criterion is a first test case. The proposed test levels are:
Level	Scope	Proposed tools
Unit	Repetition detector with recorded signals, voice parser, quiz rule table, progression policy, inactivity rule, event schema	Vitest
Integration	Persistence, Save-Set service, idempotent writes, atomic stitch and unstitch, migrations, time zones, termination	Vitest with fake-indexeddb
End to end	Screen flows of the prototypes and of the MVP stories on mobile viewports	Playwright
Accessibility	Contrast, names, touch targets, quiz with screen reader	axe-core, manual
Field test	Repetition accuracy over five exercises; lock-screen control; voice in a noisy room	Physical devices
Usability test	First-task completion time	Moderated sessions

3.2 Acceptance Criteria
An acceptance criterion is written for every requirement and is shown in the AC column of its table in Section 2. Functional criteria are numbered AC-001 to AC-132 and equal the number of their FR. Non-functional criteria are numbered AC-101 to AC-146 and equal 100 plus the number of their NFR. Criteria use the form Given, When, Then, or state a measurable limit. A requirement is accepted when its criterion is met by an automated test, an inspection or a recorded manual test. Numeric limits marked ASM are proposals (ASM-13).
3.3 Traceability Matrix
3.3.1 Epic to Story to Requirement Summary
Epic	Story	Title (short)	Functional requirements	Acceptance criteria
EP-001	US-001	the application to count my repetitions automatically	FR-049–FR-059	AC-049–AC-059
EP-001	US-002	record repetitions with voice commands	FR-060–FR-068	AC-060–AC-068
EP-001	US-003	add a repetition or a set from the lock screen without unlocking my phone	FR-069–FR-073	AC-069–AC-073
EP-001	US-004	take a short quiz about my target, energy and motivation	FR-074–FR-089	AC-074–AC-089
EP-001	US-005	the completed portion saved as a legitimate micro session that I can resume later	FR-090–FR-099	AC-090–AC-099
EP-001	US-006	combine multiple sessions into one visible record	FR-100–FR-108	AC-100–AC-108
EP-002	US-007	register an account	FR-001–FR-004	AC-001–AC-004
EP-002	US-008	log in and log out	FR-005–FR-007	AC-005–AC-007
EP-002	US-009	a home screen that shows my monthly activity and a shortcut to my last workout	FR-015–FR-020	AC-015–AC-020
EP-002	US-010	view and update my profile	FR-008–FR-010	AC-008–AC-010
EP-002	US-011	change display settings such as the light or dark theme	FR-011–FR-014	AC-011–AC-014
EP-002	US-012	browse, view and edit workout programs	FR-022–FR-027	AC-022–AC-027
EP-002	US-013	explore exercises and add them to a program or workout	FR-028–FR-031	AC-028–AC-031
EP-002	US-014	log a workout manually (weights, repetitions, sets, exercises) and see a summary when I finish	FR-021, FR-031–FR-042	AC-021, AC-031–AC-042
EP-002	US-015	a rest timer between sets	FR-043–FR-048	AC-043–AC-048
EP-002	US-016	review, search and delete past workouts	FR-109–FR-115	AC-109–AC-115
EP-002	US-017	my data stored on my device and never lost when the application closes	FR-116–FR-124	AC-116–AC-124
EP-002	US-018	usage events recorded for the quiz, micro sessions and stitching	FR-125–FR-132	AC-125–AC-132

3.3.2 Detailed Matrix: Functional Requirements
Epic	Story	FR	AC	Verification level
EP-002	US-007	FR-001	AC-001	E2E (Playwright)
EP-002	US-007	FR-002	AC-002	E2E (Playwright)
EP-002	US-007	FR-003	AC-003	E2E (Playwright)
EP-002	US-007	FR-004	AC-004	E2E (Playwright)
EP-002	US-008	FR-005	AC-005	E2E (Playwright)
EP-002	US-008	FR-006	AC-006	E2E (Playwright)
EP-002	US-008	FR-007	AC-007	E2E (Playwright)
EP-002	US-010	FR-008	AC-008	E2E (Playwright)
EP-002	US-010	FR-009	AC-009	E2E (Playwright)
EP-002	US-010	FR-010	AC-010	E2E (Playwright)
EP-002	US-011	FR-011	AC-011	E2E (Playwright)
EP-002	US-011	FR-012	AC-012	E2E (Playwright)
EP-002	US-011	FR-013	AC-013	E2E (Playwright)
EP-002	US-011	FR-014	AC-014	E2E (Playwright)
EP-002	US-009	FR-015	AC-015	E2E (Playwright)
EP-002	US-009	FR-016	AC-016	E2E (Playwright)
EP-002	US-009	FR-017	AC-017	E2E (Playwright)
EP-002	US-009	FR-018	AC-018	E2E (Playwright)
EP-002	US-009	FR-019	AC-019	E2E (Playwright)
EP-002	US-009	FR-020	AC-020	E2E (Playwright)
EP-002	US-014	FR-021	AC-021	E2E (Playwright)
EP-002	US-012	FR-022	AC-022	E2E (Playwright)
EP-002	US-012	FR-023	AC-023	E2E (Playwright)
EP-002	US-012	FR-024	AC-024	E2E (Playwright)
EP-002	US-012	FR-025	AC-025	E2E (Playwright)
EP-002	US-012	FR-026	AC-026	E2E (Playwright)
EP-002	US-012	FR-027	AC-027	E2E (Playwright)
EP-002	US-013	FR-028	AC-028	E2E (Playwright)
EP-002	US-013	FR-029	AC-029	E2E (Playwright)
EP-002	US-013	FR-030	AC-030	E2E (Playwright)
EP-002	US-013; US-014	FR-031	AC-031	E2E (Playwright)
EP-002	US-014	FR-032	AC-032	E2E (Playwright)
EP-002	US-014	FR-033	AC-033	E2E (Playwright)
EP-002	US-014	FR-034	AC-034	E2E (Playwright)
EP-002	US-014	FR-035	AC-035	E2E (Playwright)
EP-002	US-014	FR-036	AC-036	E2E (Playwright)
EP-002	US-014	FR-037	AC-037	E2E (Playwright)
EP-002	US-014	FR-038	AC-038	E2E (Playwright)
EP-002	US-014	FR-039	AC-039	E2E (Playwright)
EP-002	US-014	FR-040	AC-040	E2E (Playwright)
EP-002	US-014	FR-041	AC-041	E2E (Playwright)
EP-002	US-014	FR-042	AC-042	E2E (Playwright)
EP-002	US-015	FR-043	AC-043	E2E (Playwright)
EP-002	US-015	FR-044	AC-044	E2E (Playwright)
EP-002	US-015	FR-045	AC-045	E2E (Playwright)
EP-002	US-015	FR-046	AC-046	E2E (Playwright)
EP-002	US-015	FR-047	AC-047	E2E (Playwright)
EP-002	US-015	FR-048	AC-048	E2E (Playwright)
EP-001	US-001	FR-049	AC-049	Unit (signal fixtures) + field test
EP-001	US-001	FR-050	AC-050	Unit (signal fixtures) + field test
EP-001	US-001	FR-051	AC-051	Unit (signal fixtures) + field test
EP-001	US-001	FR-052	AC-052	Unit (signal fixtures) + field test
EP-001	US-001	FR-053	AC-053	Unit (signal fixtures) + field test
EP-001	US-001	FR-054	AC-054	Unit (signal fixtures) + field test
EP-001	US-001	FR-055	AC-055	Unit (signal fixtures) + field test
EP-001	US-001	FR-056	AC-056	Unit (signal fixtures) + field test
EP-001	US-001	FR-057	AC-057	Unit (signal fixtures) + field test
EP-001	US-001	FR-058	AC-058	Unit (signal fixtures) + field test
EP-001	US-001	FR-059	AC-059	Unit (signal fixtures) + field test
EP-001	US-002	FR-060	AC-060	Unit (parser) + manual test
EP-001	US-002	FR-061	AC-061	Unit (parser) + manual test
EP-001	US-002	FR-062	AC-062	Unit (parser) + manual test
EP-001	US-002	FR-063	AC-063	Unit (parser) + manual test
EP-001	US-002	FR-064	AC-064	Unit (parser) + manual test
EP-001	US-002	FR-065	AC-065	Unit (parser) + manual test
EP-001	US-002	FR-066	AC-066	Unit (parser) + manual test
EP-001	US-002	FR-067	AC-067	Unit (parser) + manual test
EP-001	US-002	FR-068	AC-068	Unit (parser) + manual test
EP-001	US-003	FR-069	AC-069	Manual device test + integration
EP-001	US-003	FR-070	AC-070	Manual device test + integration
EP-001	US-003	FR-071	AC-071	Manual device test + integration
EP-001	US-003	FR-072	AC-072	Manual device test + integration
EP-001	US-003	FR-073	AC-073	Manual device test + integration
EP-001	US-004	FR-074	AC-074	Unit (rule table) + E2E (Playwright)
EP-001	US-004	FR-075	AC-075	Unit (rule table) + E2E (Playwright)
EP-001	US-004	FR-076	AC-076	Unit (rule table) + E2E (Playwright)
EP-001	US-004	FR-077	AC-077	Unit (rule table) + E2E (Playwright)
EP-001	US-004	FR-078	AC-078	Unit (rule table) + E2E (Playwright)
EP-001	US-004	FR-079	AC-079	Unit (rule table) + E2E (Playwright)
EP-001	US-004	FR-080	AC-080	Unit (rule table) + E2E (Playwright)
EP-001	US-004	FR-081	AC-081	Unit (rule table) + E2E (Playwright)
EP-001	US-004	FR-082	AC-082	Unit (rule table) + E2E (Playwright)
EP-001	US-004	FR-083	AC-083	Unit (rule table) + E2E (Playwright)
EP-001	US-004	FR-084	AC-084	Unit (rule table) + E2E (Playwright)
EP-001	US-004	FR-085	AC-085	Unit (rule table) + E2E (Playwright)
EP-001	US-004	FR-086	AC-086	Unit (rule table) + E2E (Playwright)
EP-001	US-004	FR-087	AC-087	Unit (rule table) + E2E (Playwright)
EP-001	US-004	FR-088	AC-088	Unit (rule table) + E2E (Playwright)
EP-001	US-004	FR-089	AC-089	Unit (rule table) + E2E (Playwright)
EP-001	US-005	FR-090	AC-090	Integration + E2E (Playwright)
EP-001	US-005	FR-091	AC-091	Integration + E2E (Playwright)
EP-001	US-005	FR-092	AC-092	Integration + E2E (Playwright)
EP-001	US-005	FR-093	AC-093	Integration + E2E (Playwright)
EP-001	US-005	FR-094	AC-094	Integration + E2E (Playwright)
EP-001	US-005	FR-095	AC-095	Integration + E2E (Playwright)
EP-001	US-005	FR-096	AC-096	Integration + E2E (Playwright)
EP-001	US-005	FR-097	AC-097	Integration + E2E (Playwright)
EP-001	US-005	FR-098	AC-098	Integration + E2E (Playwright)
EP-001	US-005	FR-099	AC-099	Integration + E2E (Playwright)
EP-001	US-006	FR-100	AC-100	Integration + E2E (Playwright)
EP-001	US-006	FR-101	AC-101	Integration + E2E (Playwright)
EP-001	US-006	FR-102	AC-102	Integration + E2E (Playwright)
EP-001	US-006	FR-103	AC-103	Integration + E2E (Playwright)
EP-001	US-006	FR-104	AC-104	Integration + E2E (Playwright)
EP-001	US-006	FR-105	AC-105	Integration + E2E (Playwright)
EP-001	US-006	FR-106	AC-106	Integration + E2E (Playwright)
EP-001	US-006	FR-107	AC-107	Integration + E2E (Playwright)
EP-001	US-006	FR-108	AC-108	Integration + E2E (Playwright)
EP-002	US-016	FR-109	AC-109	E2E (Playwright)
EP-002	US-016	FR-110	AC-110	E2E (Playwright)
EP-002	US-016	FR-111	AC-111	E2E (Playwright)
EP-002	US-016	FR-112	AC-112	E2E (Playwright)
EP-002	US-016	FR-113	AC-113	E2E (Playwright)
EP-002	US-016	FR-114	AC-114	E2E (Playwright)
EP-002	US-016	FR-115	AC-115	E2E (Playwright)
EP-002	US-017	FR-116	AC-116	Integration (fake-indexeddb)
EP-002	US-017	FR-117	AC-117	Integration (fake-indexeddb)
EP-002	US-017	FR-118	AC-118	Integration (fake-indexeddb)
EP-002	US-017	FR-119	AC-119	Integration (fake-indexeddb)
EP-002	US-017	FR-120	AC-120	Integration (fake-indexeddb)
EP-002	US-017	FR-121	AC-121	Integration (fake-indexeddb)
EP-002	US-017	FR-122	AC-122	Integration (fake-indexeddb)
EP-002	US-017	FR-123	AC-123	Integration (fake-indexeddb)
EP-002	US-017	FR-124	AC-124	Integration (fake-indexeddb)
EP-002	US-018	FR-125	AC-125	Unit
EP-002	US-018	FR-126	AC-126	Unit
EP-002	US-018	FR-127	AC-127	Unit
EP-002	US-018	FR-128	AC-128	Unit
EP-002	US-018	FR-129	AC-129	Unit
EP-002	US-018	FR-130	AC-130	Unit
EP-002	US-018	FR-131	AC-131	Unit
EP-002	US-018	FR-132	AC-132	Unit

3.3.3 Non-Functional Requirements
NFR	AC	Category	Related requirements
NFR-001	AC-101	Usability	FR-001, FR-032
NFR-002	AC-102	Usability	General
NFR-003	AC-103	Usability	FR-012
NFR-004	AC-104	Usability	FR-077
NFR-005	AC-105	Usability	General
NFR-006	AC-106	Usability	General
NFR-007	AC-107	Usability	General
NFR-008	AC-108	Usability	FR-097, FR-106, FR-113
NFR-009	AC-109	Usability	FR-055
NFR-010	AC-110	Performance	General
NFR-011	AC-111	Performance	General
NFR-012	AC-112	Performance	FR-055
NFR-013	AC-113	Performance	FR-118
NFR-014	AC-114	Performance	FR-065
NFR-015	AC-115	Performance	FR-109, FR-110
NFR-016	AC-116	Performance	FR-051
NFR-017	AC-117	Performance	FR-045
NFR-018	AC-118	Performance	FR-053, FR-054
NFR-019	AC-119	Data	FR-086, FR-107
NFR-020	AC-120	Data	FR-103, FR-113
NFR-021	AC-121	Data	FR-042
NFR-022	AC-122	Data	General
NFR-023	AC-123	Data	General
NFR-024	AC-124	Data	FR-122
NFR-025	AC-125	Design constraint	General
NFR-026	AC-126	Design constraint	FR-116
NFR-027	AC-127	Design constraint	General
NFR-028	AC-128	Design constraint	General
NFR-029	AC-129	Design constraint	FR-069
NFR-030	AC-130	Standards	NFR-004
NFR-031	AC-131	Standards	FR-051, FR-060
NFR-032	AC-132	Standards	General
NFR-033	AC-133	System attribute	FR-117
NFR-034	AC-134	System attribute	General
NFR-035	AC-135	System attribute	General
NFR-036	AC-136	System attribute	FR-001
NFR-037	AC-137	System attribute	FR-116
NFR-038	AC-138	System attribute	General
NFR-039	AC-139	System attribute	General
NFR-040	AC-140	System attribute	FR-051, FR-063
NFR-041	AC-141	System attribute	FR-050, FR-061
NFR-042	AC-142	System attribute	General
NFR-043	AC-143	System attribute	General
NFR-044	AC-144	System attribute	General
NFR-045	AC-145	System attribute	General
NFR-046	AC-146	System attribute	FR-116

4. SUPPORTING INFORMATION
4.1 MVP Scope and Future Scope
The MVP contains the six stories of epic EP-001 and the foundation of epic EP-002. The table shows the requirement counts by priority and scope.
Priority	FR in MVP	FR Future	NFR in MVP	NFR Future
Must	78	0	15	0
Should	44	0	29	0
Could	3	6	1	1
Won't	0	1	0	0

MVP features, by story:
Story	Feature	Scope	Requirements
US-001	the application to count my repetitions automatically	MVP	FR-049–FR-059
US-002	record repetitions with voice commands	MVP	FR-060–FR-068
US-003	add a repetition or a set from the lock screen without unlocking my phone	MVP	FR-069–FR-073
US-004	take a short quiz about my target, energy and motivation	MVP	FR-074–FR-089
US-005	the completed portion saved as a legitimate micro session that I can resume later	MVP	FR-090–FR-099
US-006	combine multiple sessions into one visible record	MVP	FR-100–FR-108
US-007	register an account	MVP	FR-001–FR-004
US-008	log in and log out	MVP	FR-005, FR-006
US-009	a home screen that shows my monthly activity and a shortcut to my last workout	MVP	FR-015–FR-020
US-010	view and update my profile	MVP	FR-008, FR-009
US-011	change display settings such as the light or dark theme	MVP	FR-011–FR-013
US-012	browse, view and edit workout programs	MVP	FR-022–FR-027
US-013	explore exercises and add them to a program or workout	MVP	FR-028–FR-031
US-014	log a workout manually (weights, repetitions, sets, exercises) and see a summary when I finish	MVP	FR-021, FR-031–FR-042
US-015	a rest timer between sets	MVP	FR-043–FR-048
US-016	review, search and delete past workouts	MVP	FR-109–FR-115
US-017	my data stored on my device and never lost when the application closes	MVP	FR-116–FR-121
US-018	usage events recorded for the quiz, micro sessions and stitching	MVP	FR-125–FR-131

Future (non-MVP) requirements:
ID	Requirement	Priority	Source
FR-007	The system shall display a ‘Forgot password?’ link on the Login screen.	Could	S2; S4
FR-010	The system shall allow the user to change the profile picture.	Could	S2; S4
FR-014	The system shall provide user-configurable personalization options (content TBD).	Won't	S2; S4
FR-122	The system shall export the workout history to a JSON file on request.	Could	S1
FR-123	The system shall export the workout history to a CSV file on request.	Could	S1
FR-124	The system shall delete all locally stored user data when the user requests it and confirms.	Could	ASM
FR-132	The system shall display analytics dashboards for the measurements listed in the MVP text.	Could	S3
NFR-024	Exported data shall use an open, human-readable format.	Could	S1

Further future items from ASM-22: cloud synchronisation with remote analytics, social features, wearable integration, nutrition tracking, payments and push notifications. They are not specified in any source.
5. REFERENCES
•	[ATOMFIT-TPL] ReqView Software Requirements Specification Example, Eccam s.r.o., published 2021-09-03 (source S1).
•	[ATOMFIT-MVP] Comprehensive Explanation of the MVP Presentation (source S3).
•	[ATOMFIT-MF] Medium-Fidelity (1).pdf, AtomFit medium-fidelity prototype (source S2).
•	[ATOMFIT-HF] AtomFit – High-Fidelity Prototype.html (source S4).
•	[ATOMFIT-TESTS] AtomFit Verification Tests (TBD).
•	ISO/IEC/IEEE 29148:2018, Systems and software engineering: Life cycle processes: Requirements engineering.
•	IEEE Std 830-1998, Recommended Practice for Software Requirements Specifications.
•	W3C, Web Content Accessibility Guidelines (WCAG) 2.2.
APPENDIX A. MAPPING OF THE TEMPLATE AND OF THE REQUESTED SECTIONS
Table A1 maps the template sections to this document.
Template section	This SRS	Note
Title page (project, document, author, date)	Title page	Author TBD (TBD-30).
Table of Contents	Table of Contents	Placed before the revision history as in the template (CF-19).
Revision History	Revision History	Columns follow the template: Name, Date, Reason for changes, Version.
1.1 Purpose, 1.2 Scope	1.1, 1.2	Rewritten for AtomFit.
1.3 Product perspective (1.3.1 to 1.3.9)	1.3.1 to 1.3.9	All nine subsections kept; this is also the ‘Overall description’.
1.4 Product functions	1.4	Epics and user stories are listed here (the template refers to a NEEDS document).
1.5 User characteristics	1.5	User classes.
1.6 Limitations	1.6	Constraints and operating environment.
1.7 Assumptions and dependencies	1.7	Assumption and dependency registers.
1.8 Definitions, 1.9 Acronyms	1.8, 1.9	
2.1 External interfaces	2.1	Screen inventory, hardware, software and communications interfaces.
2.2 Functions	2.2.1 to 2.2.14	Functional requirements (FR-nnn) with priority, scope, source, acceptance criterion and dependencies.
2.3 Usability requirements	2.3	NFR-nnn.
2.4 Performance requirements	2.4	NFR-nnn.
2.5 Logical database requirements	2.5, 2.5.1	Data requirements and logical data model.
2.6 Design constraints	2.6, 2.6.1	Constraints and the Flutter stack proposal (system architecture).
2.7 Standards compliance	2.7	
2.8 Software system attributes	2.8	Reliability, security, privacy, maintainability, portability.
3 Verification	3	Verification approach, acceptance criteria and traceability matrix.
4 Supporting information	4	MVP and future scope, source conflicts, TBD register, next steps.
5 References	5	

Table A2 maps the sections requested in the brief to this document.
Requested section	Location
Title page, Version history, Table of contents	Front matter
Introduction: purpose, scope, definitions, references	1.1, 1.2, 1.8, 1.9, 5
Overall description: product perspective, user classes, operating environment, constraints	1.3 to 1.6
Functional requirements	2.2
Non-functional requirements	2.3, 2.4, 2.6 to 2.8
External interface requirements	2.1
Data requirements	2.5 and 2.5.1
System architecture / Flutter stack proposal	2.6.1
MVP scope and future scope	4.1
Assumptions and dependencies	1.7
Acceptance criteria	2.2 to 2.8 (inline) and 3.2
Traceability matrix	3.3
Appendices	Appendices A to D

APPENDIX B. SOURCE LEGEND
Code	Meaning
S1	Template (ReqView example SRS)
S2	Medium-fidelity prototype PDF
S3	Epic, user-story and MVP text
S4	High-fidelity prototype HTML
PC	Project brief constraint
ASM	Assumption

APPENDIX C. PROTOTYPE OBSERVATIONS
The table lists behaviour of the prototypes that is not a requirement or that differs from the MVP text, and how this SRS handles it.
Observation	Source	Handling
The HTML login accepts any input; the registration does not validate email or date of birth.	S4	Validation requirements added (FR for login and registration validation).
‘Continue last workout?’ always starts the Push Pull Leg program instead of resuming an unfinished workout.	S4	Requirement for resuming the most recent unfinished workout.
The HTML keeps all data in memory; nothing survives a reload.	S4	Persistence requirements (Section 2.2.13).
The home calendar and ‘5 workouts this month’ are hard-coded.	S4	Calendar and count computed from stored sessions.
The HTML has no automatic counting, voice logging, lock-screen control, inactivity trigger, micro session, stitching, revert or analytics.	S4	Specified from the MVP text; screens listed as ‘no prototype’ in Section 2.1.1.
The status-bar time ‘12:30’ and the bell icon in the prototypes are decoration of the mock-up.	S2; S4	Not treated as requirements (TBD-29 for the bell).
The History dates in the PDF (2026-11-01) are sample data.	S2	Not treated as requirements.
The PDF descriptions of All programs contain placeholder (lorem ipsum) text.	S2	Content TBD-19.
The prototypes use mid-session rest values from 1:30 to 4:00.	S2; S4	Rest is an editable per-set value (no fixed range specified).

APPENDIX D. REUSE OF THE TEMPLATE REQUIREMENTS
Template requirement	AtomFit requirement
DEMO-SRS-144 Auto save and restore	FR-117, NFR-033
DEMO-SRS-176 No project data sent to the Internet	NFR-037, FR-116
DEMO-SRS-199 Sanitise input	NFR-035
DEMO-SRS-194 Encrypt persistent data	NFR-038
DEMO-SRS-195 Run in latest Chrome or Firefox	NFR-045
DEMO-SRS-174 Start-up time	NFR-010
DEMO-SRS-171 Edit response time	NFR-011, NFR-006
DEMO-SRS-173 Smooth scrolling	NFR-015
DEMO-SRS-170 Document size	NFR-015
DEMO-SRS-77 Export to CSV	FR-123
DEMO-SRS-152 Full-text search	FR-110
DEMO-SRS-159 History of changes (author, date)	NFR-022
Application stores data in an open, human-readable format	FR-122, NFR-024
Not applicable: document templates, requirements tables, discussion comments, traceability links, attachments, custom attributes, DNF filters, Word and Excel import, HTML export, print and PDF output	Not carried over (CF-18)

