// @atomfit/web/src/texts.ts
// Typed text-resource module (Rule I-27, NFR-007).
// English only in MVP. All user-facing strings live here keyed by ID.
// Zero-guilt language (Rule I-11); non-diagnostic quiz wording (Rule I-10).
export const texts = {
  // Identity
  appName: 'AtomFit',
  tagline: 'Log it. Keep going.',

  // Auth
  authWelcome: 'Welcome back',
  authLoginTitle: 'Log in to AtomFit',
  authEmailLabel: 'Email',
  authPasswordLabel: 'Password',
  authUsernameLabel: 'Username',
  authDateOfBirthLabel: 'Date of birth',
  authGenderLabel: 'Gender', // BA-002
  authGenderPlaceholder: 'Select an option',
  authGenderMale: 'Male',
  authGenderFemale: 'Female',
  authGenderPreferNotToSay: 'Prefer not to say',
  authTermsLabel: 'I accept the terms',
  authLoginButton: 'Log in',
  authRegisterButton: 'Create account',
  authRegisterTitle: 'Create your AtomFit account',
  authForgotPassword: "Forgot password?",
  authNoAccount: "Don't have an account?",
  authHaveAccount: 'Already have an account?',
  errPasswordsDoNotMatch: "Passwords do not match",
  errAcceptTerms: 'Please accept the terms',
  errIncorrectCredentials: 'Incorrect email or password',
  errTermsRequired: 'Please accept the terms to continue',

  // Home
  homeWelcome: 'Welcome back, {name}!',
  homeMonthlyCount: 'Workouts this month',
  homeCalendarMonth: 'This month',
  homeContinueLast: 'Continue last workout',
  homeEmptyWorkout: 'Empty workout',
  homeMyPrograms: 'My programs',
  homeQuizEntry: 'Take the quiz',
  homeNoWorkoutsYet: 'No workouts yet. Start your first session.',
  homeContinueNone: 'No unfinished workout to continue.',

  // Quiz (US-004, FR-074..089)
  quizTitle: 'Quiz',
  quizRestartTitle: 'Restart quiz',
  quizPromptTitle: "Let's restart at your pace",
  quizPromptBody:
    "It's been a while since your last workout. Take a short quiz so we can adjust your program to your current pace — no pressure, no guilt.",
  quizStartButton: 'Start quiz',
  quizNotNowButton: 'Not now',
  quizProgress: '{n} / 10',
  quizNonDiagnostic: 'Non-diagnostic quiz · used only to adjust your workouts', // Rule I-10
  quizNext: 'Next question',
  quizBack: 'Back',
  quizQ1: "What is your current fitness target?",
  quizQ10: 'Do you still want to push?',
  quizQ10Button: 'See what changed',
  quizTargetMuscleGain: 'Muscle gain',
  quizTargetStayingHealthy: 'Staying healthy',
  quizTargetLookFit: 'Look fit',
  quizTargetNoTarget: 'No target',
  quizPushYes: 'Yes, progress the weight',
  quizPushSame: 'No, same program as last',
  quizPushReduced: 'No, reduced intensity',

  // Quiz result
  quizExplainerTitle: "Why we changed your program",
  quizExplainerBody:
    "Based on your answers, we're suggesting an adjusted program that fits your current energy, motivation, and schedule. You stay in control — nothing changes until you accept.",
  quizAdjustedTitle: 'Adjusted program',
  quizAcceptButton: 'Accept program',
  quizKeepButton: 'Keep my old program',
  quizPreviewSessionLength: 'Session length',
  quizPreviewIntensity: 'Intensity',
  quizPreviewFrequency: 'Frequency',
  quizPreviewWeightReduction: 'Weight reduction {pct}%',
  quizPreviewNoReduction: 'No weight reduction',

  // Programs
  programsTitle: 'My programs',
  programsCurrent: 'Current program',
  programsBuiltIn: 'Built-in',
  programsStart: 'Start',
  programsEdit: 'Edit',
  programsConfirmEdit: 'Confirm edit?',
  programsConfirmDelete: 'Delete this program?',
  programsUpdated: 'Program updated',
  programsEmpty: 'No programs yet.',

  // Active workout (US-001..003)
  workoutTitle: 'Workout',
  workoutAddSet: 'Add set',
  workoutAddExercise: 'Add exercise',
  workoutFinish: 'Finish',
  workoutSetLabel: 'Set {n}',
  workoutReps: 'Reps',
  workoutWeight: 'Weight (kg)',
  workoutRest: 'Rest (s)',
  workoutQuickAddRep: '+1 rep',
  workoutQuickAddSet: '+1 set', // TBD-05 meaning
  workoutRepCounter: 'Rep counter',
  workoutAutoCount: 'Auto-count',
  workoutManual: 'Manual entry',
  workoutVoice: 'Voice logging',
  workoutEditing: 'Editing',

  // Rest timer
  restTimerTitle: 'Rest timer',
  restSetTimer: 'Set timer',
  restPause: 'Pause',
  restResume: 'Resume',
  restSkip: 'Skip',
  restCancel: 'Cancel',

  // Workout complete
  completeTitle: 'Workout completed',
  completeTotalTime: 'Total time',
  completeTotalSets: 'Total sets',
  completeGoHome: 'Go to home page',

  // History
  historyTitle: 'History',
  historySearch: 'Search by program name',
  historyNoWorkouts: 'No workouts found',
  historyNoWorkoutsFound: 'No workouts found',
  historyFilterAll: 'All',
  historyFilterFull: 'Full',
  historyFilterMicro: 'Micro',
  historyMicroBadge: 'Micro',
  historyDetail: 'Workout detail',
  historyDateFormat: 'YYYY-MM-DD HH:mm',
  historyDeleteConfirm: 'Delete this session? This cannot be undone.',
  historyDeleted: 'Session deleted',
  historyStitchedBadge: 'Stitched',
  historyUnstitch: 'Unstitch',
  historyStitchConfirm: 'Stitch these two sessions?',

  // Discover
  discoverTitle: 'Discover',
  discoverSearch: 'Search exercises',
  discoverExplore: 'Explore exercise',
  discoverAdd: 'Add',
  discoverCatalogue: 'Exercise catalogue',

  // Profile
  profileTitle: 'Profile',
  profileUsername: 'Username',
  profileEmail: 'Email',
  profileGender: 'Gender', // BA-002
  profileDateOfBirth: 'Date of birth',
  profileWeight: 'Weight (kg)',
  profileHeight: 'Height (cm)',
  profileUpdate: 'Update profile',
  profileUpdated: 'Profile updated',

  // Settings
  settingsTitle: 'Settings',
  settingsDisplay: 'Display',
  settingsTheme: 'Theme',
  settingsThemeLight: 'Light',
  settingsThemeDark: 'Dark',
  settingsPersonalization: 'Personalization',
  settingsPersonalizationComingSoon: 'Coming soon',
  settingsAbout: 'About app',
  settingsAboutName: 'AtomFit',
  settingsAboutVersion: 'Version 1.0.0',
  settingsAboutLine: 'Local-first workout tracker. Log it. Keep going.',

  // Generic
  genericSave: 'Save',
  genericCancel: 'Cancel',
  genericDelete: 'Delete',
  genericEdit: 'Edit',
  genericConfirm: 'Confirm',
  genericContinue: 'Continue',
  genericClose: 'Close',
  genericOk: 'OK',
  genericLoading: 'Loading...',
  genericError: 'Something went wrong',
  genericTryAgain: 'Try again',
} as const;

export type TextKey = keyof typeof texts;
export type TextValue = (typeof texts)[TextKey];

// Simple typed lookup. Components should use t(key) and interpolate {name} etc.
export function t<K extends TextKey>(key: K, params?: Record<string, string | number>): string {
  let str = String(texts[key]);
  if (params) {
    for (const [k, v] of Object.entries(params)) {
      str = str.replace(new RegExp(`\\{${k}\\}`, 'g'), String(v));
    }
  }
  return str;
}
