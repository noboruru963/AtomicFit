/// Every user-facing string, copied verbatim from the web prototype
/// (`index.html`). Screens reference these constants instead of literals.
class AfStrings {
  const AfStrings._();

  // ---------------------------------------------------------------- app level
  static const String appName = 'AtomFit';
  static const String tagline = 'Log it. Keep going.';
  static const String appTitle = 'AtomFit — Adaptive Workout Tracker';

  // ------------------------------------------------------------- screen titles
  static const String titleHome = 'AtomFit';
  static const String titlePrograms = 'My Programs';
  static const String titleWorkout = 'Workout';
  static const String titleTimer = 'Rest Timer';
  static const String titleWorkoutComplete = 'Workout Complete';
  static const String titleHistory = 'History';
  static const String titleDiscover = 'Discover';
  static const String titleProfile = 'Profile';
  static const String titleSettings = 'Settings';
  static const String titleQuizPrompt = 'Adaptive Check-In';
  static const String titleQuizQuestion = 'Adaptive Quiz';
  static const String titleQuizExplainer = 'Program Adjustment';
  static const String titleQuizAdjusted = 'Adjusted Plan';

  // ------------------------------------------------------------------- login
  static const String loginEyebrow = 'Welcome back';
  static const String loginTitle = 'Log in to AtomFit';
  static const String loginEmailLabel = 'Email';
  static const String loginEmailPlaceholder = 'alex@example.com';
  static const String loginPasswordLabel = 'Password';
  static const String loginPasswordPlaceholder = '••••••••';
  static const String loginForgotPassword = 'Forgot password?';
  static const String loginButton = 'Log in';
  static const String loginNoAccount = "Don't have an account?";
  static const String loginCreateAccount = 'Create account';
  static const String loginError = 'Incorrect email or password';
  static const String loginWelcomeToast = 'Welcome back, {name}!';
  static const String forgotTitle = 'Forgot password?';
  static const String forgotBody =
      "Enter your AtomFit account email and we'll generate a local recovery token.";
  static const String forgotSend = 'Send Reset Link';
  static const String forgotSentToast = 'Password reset instructions sent!';
  static const String cancel = 'Cancel';
  static const String close = 'Close';

  // ----------------------------------------------------------------- register
  static const String registerEyebrow = 'AtomFit Onboarding';
  static const String registerTitle = 'Create your AtomFit account';
  static const String registerUsername = 'Username';
  static const String registerUsernamePlaceholder = 'Your name';
  static const String registerEmailLabel = 'Email';
  static const String registerEmailPlaceholder = 'you@example.com';
  static const String registerPassword = 'Password';
  static const String registerConfirmPassword = 'Confirm password';
  static const String registerDob = 'Date of birth';
  static const String registerGender = 'Gender';
  static const String registerSelectOption = 'Select an option';
  static const String genderMale = 'Male';
  static const String genderFemale = 'Female';
  static const String genderPreferNot = 'Prefer not to say';
  static const String registerTerms = 'I accept the terms';
  static const String registerButton = 'Create account';
  static const String registerSubmit = 'Register';
  static const String registerInvalidEmail =
      'Please enter a valid email address';
  static const String registerPasswordRequired = 'Please enter a password';
  static const String registerEmailTaken =
      'An account with this email already exists';
  static const String registerHasAccount = 'Already have an account?';
  static const String registerLogin = 'Log in';
  static const String registerPasswordMismatch = 'Passwords do not match';
  static const String registerTermsMissing = 'Please accept the terms';
  static const String registerCreatedToast = 'Account created for {name}!';

  // -------------------------------------------------------------------- home
  static const String homeWelcome = 'Welcome back, {name}';
  static const String homeCurrentProgram = 'Current Program:';
  static const String homeNoExercises = 'No exercises configured';
  static const String homeStartProgram = 'Start {program}';
  static const String homeContinueProgram = 'Continue {program} ({sets} sets)';
  static const String homeEmptyWorkout = 'Empty Workout';
  static const String homeQuizTitle = "Let's restart at your pace";
  static const String homeQuizSubtitle =
      'Take a short quiz to adjust your program load.';
  static const String homeQuizButton = 'Quiz';
  static const String homeDismiss = '✕';
  static const String homeWorkoutsLogged = 'Workouts logged: {count}';
  static const String homeHistoryLink = 'History →';
  static const String homeMyPrograms = 'My Programs';
  static const String homeManageAll = 'Manage all ({count})';
  static const String badgeCurrent = 'Current';
  static const String badgeAdjusted = 'Adjusted';
  static const String homeSelect = 'Select';
  static const String homeStart = 'Start';
  static const String calendarRestDayToast =
      '{month} {day}: Rest day (No logged session)';
  static const String calendarDayTitle = '{month} {day} • {name}';
  static const String calendarTotalReps = 'Total Reps: {reps}';
  static const String calendarTotalVolume = 'Total Volume: {volume} kg';
  static const String openInHistory = 'Open in History';
  static const String quizSnoozedToast =
      'Quiz reminder snoozed. You can launch it anytime from Settings.';

  // -------------------------------------------------------------- quiz prompt
  static const String quizNonDiagnostic =
      'Non-diagnostic quiz · used only to adjust your workouts';
  static const String quizPromptTitle = "Let's restart at your pace";
  static const String quizPromptBody =
      "It's been a while since your last workout. Take a short quiz so we can "
      'adjust your program to your current level.';
  static const String quizTuningHeader = 'What the Adaptive Engine tunes:';
  static const String quizTuningVolume = 'Set volume & target weight';
  static const String quizTuningVolumeValue = '-10% to -15%';
  static const String quizTuningDuration = 'Session duration target';
  static const String quizTuningDurationValue = '25 min (-10 min)';
  static const String quizTuningRest = 'Rest timer intervals';
  static const String quizTuningRestValue = 'Auto-adjusted';
  static const String quizStartFull = 'Start quiz (Full 10 Questions)';
  static const String quizStartQuick = 'Quick 3-Question Check-In';
  static const String quizNotNow = 'Not now';

  // ------------------------------------------------------------- quiz question
  static const String quizQuestionIndex = 'Question {index} / {total}';
  static const String quizModeFull = 'Mode: Full 10-Step';
  static const String quizModeFast = 'Mode: 3-Step Fast';
  static const String quizNext = 'Next question →';
  static const String quizSeeWhatChanged = 'See what changed →';
  static const String quizBack = '← Back';

  // ------------------------------------------------------------ quiz explainer
  static const String quizWhyTitle = 'Why we changed your program';
  static const String quizWhyBody =
      "Based on your answers, we're suggesting an adjusted program that fits "
      'your current energy, motivation, and time.';
  static const String quizSessionLength = 'Session length';
  static const String quizIntensity = 'Intensity';
  static const String quizFrequency = 'Frequency';
  static const String quizWeightAdjustment = 'Weight adjustment';
  static const String quizSeeAdjustedPlan = 'See Adjusted Plan →';
  static const String quizBackToQuiz = '← Back to Quiz';

  // ----------------------------------------------------------- quiz adjusted
  static const String quizPlanReady = 'Adaptive Plan Ready';
  static const String quizAdjustedTitle = 'Adjusted program';
  static const String quizAdjustedBody =
      'Review your modified sets and working weights before starting your session.';
  static const String quizAdjustedSets = '{sets} Sets × {reps} Reps';
  static const String quizAccept = 'Accept program & Start Workout';
  static const String quizKeepOld = 'Keep my old program';
  static const String quizAcceptedToast =
      'Adjusted program accepted ({pct} load applied)!';
  static const String quizKeptOldToast = 'Kept original program weights.';

  // ----------------------------------------------------------------- programs
  static const String programsIntro =
      'Select a program to load its exercises and targets into your workout.';
  static const String programsNew = '+ New Program';
  static const String programsStart = 'Start Workout';
  static const String programsSetCurrent = 'Set Current';
  static const String programsDelete = 'Delete';
  static const String programsMeta =
      '{duration} • {frequency} • {count} exercises';
  static const String programsExerciseRow =
      '{sets} sets × {reps} reps · {kg} kg';
  static const String programsNoExercises =
      'No exercises yet. Add exercises during workout.';
  static const String programsEmpty =
      'No programs in this category yet. Click "+ New Program" to build one!';
  static const String programsDeleteTitle = 'Delete "{name}"?';
  static const String programsDeleteBody =
      'Are you sure you want to permanently delete {name}? This action will '
      'remove it from your programs and saved storage.';
  static const String programsDeleteActiveWarning =
      'This program is currently active. Deleting it will safely switch your '
      'active workout to another available program.';
  static const String programsSelectedToast =
      'Selected "{name}" as current program!';
  static const String programsLoadedToast = 'Loaded {name} ({count} exercises)';
  static const String programsNameLabel = 'Program Name';
  static const String programsNamePlaceholder = 'e.g. Upper Body Express';
  static const String programsTypeLabel = 'Type';
  static const String programsSetsLabel = 'Sets';
  static const String programsRepsLabel = 'Reps';
  static const String programsWeightLabel = 'Weight (kg)';
  static const String programsAddExercise = 'Add Exercise';
  static const String programsDoneSelecting = 'Done Selecting';
  static const String programsSelectedExercises =
      'Selected Exercises ({count})';
  static const String programsCreateTitle = 'Create Custom Program';
  static const String programsSave = 'Save Program';
  static const String programsNameRequired = 'Please enter a program name.';
  static const String programsExerciseRequired =
      'Please select at least one exercise from Discover.';

  // ------------------------------------------------------------ active workout
  static const String workoutCurrentExercise = 'Current Exercise';
  static const String workoutNoneSelected = 'None Selected';
  static const String workoutTarget =
      'Target: {sets} sets × {reps} reps @ {kg} kg';
  static const String workoutLogged = 'Logged: {done}/{total}';
  static const String workoutNoExerciseHint =
      'Select a program or add an exercise from Discover to begin logging.';
  static const String workoutWeightLabel = 'Weight (kg)';
  static const String workoutRepsLabel = 'Reps';
  static const String workoutMinusOneRep = '-1 reps';
  static const String workoutPlusOneRep = '+1 reps';
  static const String workoutAddSet = 'Add Set';
  static const String workoutLoggedSets = 'Logged Sets ({count})';
  static const String workoutTotalVolume = 'Total Vol: {volume} kg';
  static const String workoutNoSets =
      'No sets logged yet. Tap "Add Set" above to record your first set.';
  static const String workoutInputChannel =
      'Input channel: {method} (Change in Settings)';
  static const String workoutFinish = 'Finish Workout';
  static const String workoutSetNumber = 'Set {number}';
  static const String workoutSetSummary = '{kg} kg × {reps} reps';
  static const String workoutAutoCount = '⌚ Auto-Count Channel:';
  static const String workoutCounting = 'Counting reps...';
  static const String workoutReady = 'Ready';
  static const String workoutStartAutoCount = 'Start Auto-Count';
  static const String workoutStopSensor = 'Stop Sensor';
  static const String workoutVoicePlaceholder = 'e.g. 20 kg for 12 reps';
  static const String workoutParseAdd = '🎙️ Parse & Add Set';
  static const String workoutLockscreen = '🔒 Lockscreen Quick-Log:';
  static const String workoutWeightInvalid =
      'Please enter a valid weight in kg (0 or greater).';
  static const String workoutWeightNotNumber =
      'Weight (kg) must be a valid non-negative number.';
  static const String workoutWeightRange =
      'Weight (kg) must be between 0 and 1000.';
  static const String workoutNeedExercise =
      'Please add or select an exercise first.';
  static const String workoutLoggedToast =
      'Logged Set #{index} for {exercise} ({kg} kg × {reps} reps)';
  static const String workoutFinishEmptyToast =
      'Log at least one set before finishing your workout.';

  // ---------------------------------------------------------------- rest timer
  static const String timerTitle = 'Rest Countdown';
  static const String timerRunning = 'Running';
  static const String timerPaused = 'Paused';
  static const String timerReady = 'Ready';
  static const String timerMinutes = 'Minutes';
  static const String timerSeconds = 'Seconds';
  static const String timerTargetLine =
      'Target Duration: {duration} · Exercise: {exercise}';
  static const String timerGeneralRest = 'General Rest';
  static const String timerStart = 'Start';
  static const String timerReset = 'Reset';
  static const String timerPause = 'Pause';
  static const String timerMinus15 = '-15s';
  static const String timerPlus15 = '+15s';
  static const String timerSkip = 'Skip Rest';
  static const String timerBackToWorkout = 'Back to Workout';
  static const String timerErrorEmpty =
      'Please enter a duration in minutes or seconds.';
  static const String timerErrorNotWhole =
      'Invalid input: minutes and seconds must be whole numbers.';
  static const String timerErrorNegative = 'Timer duration cannot be negative.';
  static const String timerErrorSeconds = 'Seconds must be between 0 and 59.';
  static const String timerErrorZero =
      'Timer duration must be greater than 0 seconds.';
  static const String timerErrorTooLong =
      'Timer duration cannot exceed 180 minutes.';
  static const String timerCompleteToast =
      '🔔 Rest complete! Ready for your next set.';
  static const String timerDonePill = '🔔 Rest Done';

  // ---------------------------------------------------------- workout complete
  static const String completeBadge = '{type} session saved';
  static const String completeTitle = 'Workout completed';
  static const String completeSubtitle = 'Log it. Keep going. • {name}';
  static const String completeTotalTime = 'Total time';
  static const String completeTotalSets = 'Total sets';
  static const String completeTotalVolume = 'Total Volume';
  static const String completeTotalReps = 'Total Reps';
  static const String completeChannelsUsed = 'Input channels used:';
  static const String completeGoHome = 'Go to home page';
  static const String completeViewHistory = 'View in Workout History';

  // ------------------------------------------------------------------ history
  static const String historySearchPlaceholder = 'Search by program name';
  static const String historyStitchBanner =
      'Workout Stitching Available ({count} Micro Sessions)';
  static const String historyStitchBannerBody =
      'Combine fragmented micro-workouts into one unified Stitched session.';
  static const String historyStitchButton = 'Stitch Micros';
  static const String historyStitchedFrom =
      'Stitched from {count} micro-sessions:';
  static const String historyUnstitch = 'Unstitch';
  static const String historyDetail = 'Detail';
  static const String historyDelete = 'Delete';
  static const String historyEmpty = 'No workouts found';
  static const String historyTotalVolume = 'Total Volume: {volume} kg';
  static const String historyTotalReps = 'Total Reps: {reps}';
  static const String historySetRow =
      '#{index} {exercise} — {kg} kg × {reps} ({method})';
  static const String historyNoSetDetail =
      'Total {reps} reps across {count} logged sets.';
  static const String historyDeleteTitle = 'Delete this session?';
  static const String historyDeleteBody =
      'This removes the session from your history. This cannot be undone.';
  static const String historyUnstitchedToast =
      'Unstitched into {count} individual Micro sessions!';
  static const String historyStitchedToast = 'Stitched {count} micro sessions.';

  // ----------------------------------------------------------------- discover
  static const String discoverCustomTitle = 'Add Custom Exercise';
  static const String discoverManualEntry = 'Manual Entry';
  static const String discoverCustomNamePlaceholder =
      'Enter exercise name (e.g. Dumbbell Floor Press)';
  static const String discoverWeightPlaceholder = 'Weight kg';
  static const String discoverRepsPlaceholder = 'Reps';
  static const String discoverAddCustom = 'Add Custom Exercise';
  static const String discoverTarget = 'Target: {kg} kg × {reps} reps';
  static const String discoverAdd = 'Add';
  static const String discoverEmpty =
      'No matching exercises in catalogue. Use "Add Custom Exercise" above!';
  static const String discoverNameRequired =
      'Please enter an exercise name before adding.';
  static const String discoverCustomNameRequired =
      'Please enter a valid exercise name.';
  static const String discoverNameRequiredToast =
      'Please enter an exercise name.';
  static const String discoverAddedToast = 'Added "{name}" to Active Workout!';
  static const String discoverCustomAddedToast =
      'Added custom exercise "{name}"!';

  // ------------------------------------------------------------------ profile
  static const String profileMemberSince = 'Member since {date}';
  static const String profileSessions = 'Sessions';
  static const String profileVolume = 'Volume';
  static const String profileDetails = 'Personal Details';
  static const String profileUsername = 'Username';
  static const String profileEmail = 'Email';
  static const String profileGender = 'Gender';
  static const String profileDobMonth = 'Date of birth (Month)';
  static const String profileWeight = 'Weight (kg)';
  static const String profileHeight = 'Height (cm)';
  static const String profileUpdate = 'Update profile';
  static const String profileUpdatedToast = 'Profile updated!';

  // ----------------------------------------------------------------- settings
  static const String settingsInputChannel = 'Input Channel (Save-Set Service)';
  static const String settingsInputChannelBody =
      'Select how sets are logged during workouts (Manual, Sensor Auto-count, '
      'Voice, or Lockscreen).';
  static const String settingsActiveChannel = 'Active: {method}';
  static const String settingsManual = '⌨️ Manual';
  static const String settingsSensor = '⌚ Auto-count';
  static const String settingsVoice = '🎙️ Voice logging';
  static const String settingsLockscreen = '🔒 Lockscreen';
  static const String settingsTheme = 'Theme & Appearance';
  static const String settingsThemeBody =
      'Switch between Light Mode and Dark Mode';
  static const String settingsLightActive = 'Light Active';
  static const String settingsDarkActive = 'Dark Active';
  static const String settingsLightMode = '☀️ Light Mode';
  static const String settingsDarkMode = '🌙 Dark Mode';
  static const String settingsDevice = 'Device, Timer & Sensor Preferences';
  static const String settingsBellTitle = 'Timer Completion Bell Sound';
  static const String settingsBellDesc =
      'Play a bell chime when the rest timer reaches 00:00';
  static const String settingsNotifTitle =
      'Background Rest-Timer Notifications';
  static const String settingsNotifDesc =
      'Show a local notification if rest ends after leaving the app';
  static const String settingsSensorTitle =
      'Sensor Auto-Detect (Accelerometer)';
  static const String settingsSensorDesc =
      'Automatically count reps during active sets';
  static const String settingsVoiceTitle = 'Voice Logging (Speech-to-Set)';
  static const String settingsVoiceDesc =
      'Log weight and reps hands-free via voice commands';
  static const String settingsLockscreenTitle = 'Lock Screen Quick-Log Widget';
  static const String settingsLockscreenDesc =
      'Enable 1-tap micro-workout set logging from lock screen';
  static const String settingsHapticTitle = 'Haptic Rest Timer Alerts';
  static const String settingsHapticDesc =
      'Vibrate when rest timer reaches 00:00';
  static const String settingsAdaptive = 'Adaptive Engine & State';
  static const String settingsTriggerQuiz = 'Trigger Inactivity Quiz';
  static const String settingsResetSeed = 'Reset Seeded Data';
  static const String settingsAboutCredits = 'About & Credits';
  static const String settingsAboutVersion =
      'AtomFit v1.0 · Log it. Keep going.';
  static const String settingsAboutExerciseData = 'Exercise data by';
  static const String settingsLogOut = 'Log out';
  static const String settingsUpdatedToast = 'Updated {key} preference';
  static const String settingsNotificationsUnsupported =
      'System notifications are not supported on this device. In-app bell & '
      'visual alerts remain active.';
  static const String settingsNotificationsDenied =
      'Notification permission was denied. Enable notifications in system '
      'settings to receive rest timer alerts.';

  // --------------------------------------------------------- personal details
  static const String titlePersonalDetails = 'Personal details';
  static const String personalDetailsTitle = 'Personal details';
  static const String personalDetailsSubtitle =
      'Tell us a bit about yourself before heading to Home.';
  static const String personalDetailsUsername = 'Username';
  static const String personalDetailsUsernamePlaceholder =
      'Enter your username';
  static const String personalDetailsDob = 'Date of birth';
  static const String personalDetailsGender = 'Gender';
  static const String personalDetailsWeight = 'Weight (kg)';
  static const String personalDetailsWeightPlaceholder = 'e.g. 74.5';
  static const String personalDetailsHeight = 'Height (cm)';
  static const String personalDetailsHeightPlaceholder = 'e.g. 178';
  static const String personalDetailsContinue = 'Continue';
  static const String personalDetailsDay = 'Day';
  static const String personalDetailsMonth = 'Month';
  static const String personalDetailsYear = 'Year';
  static const String personalDetailsSavedToast =
      'Personal details saved! Welcome, {name}!';

  // ------------------------------------------------------ discover (new UI)
  static const String discoverTitle = 'Discover Exercises';
  static const String discoverSubtitle =
      'Browse all {count} exercises by body part and learn step-by-step form.';
  static const String discoverCustom = '+ Custom';
  static const String discoverSearchPlaceholder =
      'Search exercise, muscle, body part, or equipment...';
  static const String discoverClear = 'All / Clear';
  static const String discoverResultCount = '{count} exercises';
  static const String discoverResultCountOne = '1 exercise';
  static const String discoverShowAll = 'Show All ({count})';
  static const String discoverEmptyTitle =
      'No exercises found. Try another name or body part.';
  static const String discoverResetFilters = 'Reset filters to All';
  static const String discoverShowMore =
      'Show more exercises ({count} remaining)';
  static const String discoverViewInstructions = 'View instructions';
  static const String discoverAddToWorkout = '+ Add to Workout';
  static const String discoverTargetMuscles = 'Target: {muscles}';
  static const String discoverRepDbFooter = 'Exercise data by';
  static const String discoverRepDbLink = 'RepDB (repdb.co)';

  // ------------------------------------------------- exercise detail (new)
  static const String titleExerciseGuide = 'Exercise Guide';
  static const String detailBackToDiscover = '← Back to Discover';
  static const String detailTargetMuscles = 'Target muscles';
  static const String detailPrimaryMuscles = 'Primary muscles';
  static const String detailSecondaryMuscles = 'Secondary muscles';
  static const String detailNone = 'None';
  static const String detailDescription = 'Description & Movement Purpose';
  static const String detailGoals = 'Goals:';
  static const String detailFormTips = 'Form tips';
  static const String detailNoInstructions =
      'Instructions are not available for this exercise yet';
  static const String detailNoTips = 'Form tips are not available yet.';
  static const String detailIllustrationPlaceholder =
      'Illustration placeholder';
  static const String detailStartPosition = 'Start position';
  static const String detailPeakPosition = 'Peak position';
  static const String detailExercisePosition = 'Exercise position';
  static const String detailUnilateral = 'Unilateral';
  static const String detailMet = '{value} MET';

  // ------------------------------------------------------------------ shared
  static const String delete = 'Delete';
  static const String removeSet = 'Remove set';
  static const String previousExercise = 'Previous exercise';
  static const String nextExercise = 'Next exercise';
  static const String openInSettings = 'Change in Settings';

  /// Replaces `{key}` placeholders in [template] with [values].
  static String fill(String template, Map<String, Object?> values) {
    String out = template;
    values.forEach((key, value) {
      out = out.replaceAll('{$key}', value?.toString() ?? '');
    });
    return out;
  }
}
