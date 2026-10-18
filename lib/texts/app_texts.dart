class AppTexts {
  static const String appName = 'AtomFit';
  static const String tagline = 'Log it. Keep going.';

  // Auth
  static const String welcomeBack = 'Welcome back';
  static const String loginTitle = 'Log in to AtomFit';
  static const String registerTitle = 'Create your AtomFit account';
  static const String emailLabel = 'Email';
  static const String passwordLabel = 'Password';
  static const String usernameLabel = 'Username';
  static const String dateOfBirthLabel = 'Date of birth';
  static const String genderLabel = 'Gender';
  static const String genderPlaceholder = 'Select an option';
  static const String genderMale = 'Male';
  static const String genderFemale = 'Female';
  static const String genderPreferNotToSay = 'Prefer not to say';
  static const String termsLabel = 'I accept the terms';
  static const String loginButton = 'Log in';
  static const String registerButton = 'Create account';
  static const String forgotPassword = 'Forgot password?';
  static const String noAccount = "Don't have an account?";
  static const String haveAccount = 'Already have an account?';
  static const String errPasswordsDoNotMatch = "Passwords do not match";
  static const String errAcceptTerms = 'Please accept the terms';
  static const String errIncorrectCredentials = 'Incorrect email or password';

  // Home
  static String welcome(String name) => 'Welcome back, $name!';
  static const String monthlyCount = 'Workouts this month';
  static const String calendarMonth = 'This month';
  static const String continueLast = 'Continue last workout';
  static const String emptyWorkout = 'Empty workout';
  static const String myPrograms = 'My programs';
  static const String quizEntry = 'Take the quiz';
  static const String noWorkoutsYet = 'No workouts yet. Start your first session.';
  static const String continueNone = 'No unfinished workout to continue.';

  // Quiz
  static const String quizTitle = 'Quiz';
  static const String promptTitle = "Let's restart at your pace";
  static const String promptBody =
      "It's been a while since your last workout. Take a short quiz so we can adjust your program to your current pace — no pressure, no guilt.";
  static const String startButton = 'Start quiz';
  static const String notNowButton = 'Not now';
  static String progress(int n, int total) => '$n / $total';
  static const String nonDiagnostic =
      'Non-diagnostic quiz · used only to adjust your workouts';
  static const String nextButton = 'Next question';
  static const String backButton = 'Back';
  static const String q1 = "What is your current fitness target?";
  static const String q10 = 'Do you still want to push?';
  static const String q10Button = 'See what changed';
  static const String targetMuscleGain = 'Muscle gain';
  static const String targetStayingHealthy = 'Staying healthy';
  static const String targetLookFit = 'Look fit';
  static const String targetNoTarget = 'No target';
  static const String pushYes = 'Yes, progress the weight';
  static const String pushSame = 'No, same program as last';
  static const String pushReduced = 'No, reduced intensity';

  // Quiz result
  static const String explainerTitle = "Why we changed your program";
  static const String explainerBody =
      "Based on your answers, we're suggesting an adjusted program that fits your current energy, motivation, and schedule. You stay in control — nothing changes until you accept.";
  static const String adjustedTitle = 'Adjusted program';
  static const String acceptButton = 'Accept program';
  static const String keepButton = 'Keep my old program';

  // Programs
  static const String programsTitle = 'My programs';
  static const String sessionLengthKey = 'Session length';
  static const String intensityKey = 'Intensity';
  static const String frequencyKey = 'Frequency';
  static const String weightReductionKey = 'Weight reduction';

  // Workout
  static const String workoutTitle = 'Workout';
  static const String addSet = 'Add set';
  static const String addExercise = 'Add exercise';
  static const String finish = 'Finish';
  static const String quickAddRep = '+1 rep';
  static const String quickAddSet = '+1 set';
  static const String repCounter = 'Rep counter';
  static const String autoCount = 'Auto-count';
  static const String voice = 'Voice logging';
  static const String saving = 'Saving';

  // Rest timer
  static const String restTimerTitle = 'Rest timer';
  static const String setTimer = 'Set timer';
  static const String pause = 'Pause';
  static const String resume = 'Resume';
  static const String skip = 'Skip';
  static const String cancel = 'Cancel';

  // Workout complete
  static const String completeTitle = 'Workout completed';
  static const String totalTime = 'Total time';
  static const String totalSets = 'Total sets';
  static const String goHome = 'Go to home page';

  // History
  static const String historyTitle = 'History';
  static const String search = 'Search by program name';
  static const String noWorkouts = 'No workouts found';
  static const String filterAll = 'All';
  static const String filterFull = 'Full';
  static const String filterMicro = 'Micro';
  static const String microBadge = 'Micro';
  static const String stitchedBadge = 'Stitched';
  static const String detail = 'Detail';
  static const String deleteConfirm = 'Delete this session?';
  static const String deleted = 'Session deleted';
  static const String unstitch = 'Unstitch';

  // Discover
  static const String discoverTitle = 'Discover';
  static const String exploreExercise = 'Explore exercise';
  static const String addButton = 'Add';
  static const String catalogue = 'Exercise catalogue';

  // Profile
  static const String profileTitle = 'Profile';
  static const String profileUsername = 'Username';
  static const String profileEmail = 'Email';
  static const String profileGender = 'Gender';
  static const String profileDateOfBirth = 'Date of birth';
  static const String profileWeight = 'Weight (kg)';
  static const String profileHeight = 'Height (cm)';
  static const String updateProfile = 'Update profile';
  static const String profileUpdated = 'Profile updated';
  static const String dobDay = 'Day';
  static const String dobMonth = 'Month';
  static const String dobYear = 'Year';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String display = 'Display';
  static const String theme = 'Theme';
  static const String themeLight = 'Light';
  static const String themeDark = 'Dark';
  static const String personalization = 'Personalization';
  static const String personalizationComingSoon = 'Coming soon';
  static const String about = 'About app';
  static const String aboutName = 'AtomFit';
  static const String aboutVersion = 'Version 1.0.0';
  static const String aboutLine = 'Local-first workout tracker. Log it. Keep going.';

  // Generic
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String confirm = 'Confirm';
  static const String continueBtn = 'Continue';
  static const String close = 'Close';
  static const String ok = 'OK';
  static const String loading = 'Loading...';
  static const String error = 'Something went wrong';
  static const String tryAgain = 'Try again';
}
