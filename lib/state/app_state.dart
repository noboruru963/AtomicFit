import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../data/db/catalogue.dart';
import '../data/db/exercise_repository.dart';
import '../data/db/password_hasher.dart';
import '../data/seed_data.dart';
import '../data/store.dart';
import '../models/app_account.dart';
import '../models/app_models.dart';
import '../services/personal_details_validation.dart';

enum ToastKind { success, info, danger }

/// The application state, ported 1:1 from the web prototype's global
/// `appState` object (`index.html` lines 667-764) plus its handlers.
///
/// Screens read from this object and call the methods below; nothing else
/// mutates application data.
class AppState extends ChangeNotifier {
  AppState({
    required this.store,
    ExerciseRepository? exercises,
    DateTime? now,
  })  : _exercises = exercises,
        _now = now ?? DateTime.now();

  final AtomFitStore store;

  /// The exercise catalogue backed by the database. When it is `null` the
  /// state falls back to the seeded catalogue (used by the widget tests).
  final ExerciseRepository? _exercises;

  final PasswordHasher _hasher = const PasswordHasher();
  final DateTime _now;

  // ------------------------------------------------------------- persisted
  AppUser user = AppUser.defaultUser();
  AppSettings settings = AppSettings.defaults(SeedData.userId);
  bool isDarkMode = false;
  List<Exercise> catalogue = <Exercise>[];
  List<Program> programs = <Program>[];
  List<WorkoutSession> history = <WorkoutSession>[];
  ActiveWorkout activeWorkout = const ActiveWorkout(
    programId: 'p_push',
    sessionName: 'Push Day',
    sessionType: 'full',
    exercises: <ProgramExercise>[],
    currentExercise: '',
    weightInput: '0',
    repsInput: 0,
    inputMethod: 'manual',
    restTotalSeconds: 120,
    restSeconds: 120,
    sets: <LoggedSet>[],
  );
  bool isProgramAdjusted = false;
  double adjustmentFactor = 0.9;

  // --------------------------------------------------------------- accounts
  /// The local accounts (`appState.accounts[]` in the prototype).
  List<AppAccount> accounts = <AppAccount>[];

  /// Whether a user is signed in (`appState.isLoggedIn`).
  bool isLoggedIn = false;

  /// Whether the signed-in account finished the personal-details step.
  bool personalDetailsComplete = true;

  /// The exercise the Discover detail screen is showing.
  String? selectedExerciseId;

  /// How many Discover results are currently rendered (`discoverVisibleLimit`).
  int discoverVisibleLimit = 60;

  // ------------------------------------------------------------- ui state
  bool showQuizBannerOnHome = true;
  bool quizShortMode = false;
  int quizStepIndex = 0;
  final Map<String, String> quizAnswers = <String, String>{};
  String programsFilter = 'All';
  String catalogueFilter = 'All';
  String catalogueSearch = '';
  String historyFilter = 'All';
  String historySearch = '';
  WorkoutSummary? lastCompletedWorkout;

  // ------------------------------------------------------- rest timer state
  bool restRunning = false;
  bool restCompleted = false;
  DateTime? restEndTime;
  int timerRunId = 0;
  bool sensorSimActive = false;
  Timer? _ticker;
  Timer? _sensorTicker;

  // ------------------------------------------------------------------ toast
  String? toastText;
  ToastKind toastKind = ToastKind.success;
  Timer? _toastTimer;

  bool _loaded = false;

  /// Whether the persisted state has been loaded (or seeded) already.
  bool get isLoaded => _loaded;

  // ------------------------------------------------------------------ setup

  /// Loads persisted state, seeding the demo data on first launch.
  Future<void> load() async {
    final Map<String, dynamic>? document = await store.read();
    if (document == null) {
      _seed();
      await _loadCatalogue();
      await persist();
    } else {
      _restore(document);
      await _loadCatalogue();
    }
    _loaded = true;
    notifyListeners();
  }

  /// Reads the exercise catalogue from the database.
  ///
  /// Custom exercises come first, mirroring the prototype's
  /// `customExercises.concat(DEFAULT_CATALOGUE)`.
  Future<void> _loadCatalogue() async {
    final ExerciseRepository? repository = _exercises;
    if (repository == null) return;
    final List<Exercise> stored = await repository.loadAll();
    if (stored.isEmpty) return;
    catalogue = stored;
  }

  void _seed() {
    final DateTime now = _now;
    user = AppUser.defaultUser();
    settings = AppSettings.defaults(SeedData.userId);
    isDarkMode = false;
    catalogue = SeedData.catalogue(now);
    programs = SeedData.programs(now);
    history = SeedData.history(now);
    isProgramAdjusted = false;
    adjustmentFactor = 0.9;
    showQuizBannerOnHome = true;
    isLoggedIn = false;
    personalDetailsComplete = true;
    accounts = _demoAccounts();
    final Program active = programs.first;
    activeWorkout = _workoutFor(active, 'full', clearSets: true);
  }

  /// The demo accounts the prototype seeds (`index.html` lines 735-766).
  ///
  /// The passwords are stored as salted hashes — never in clear text.
  List<AppAccount> _demoAccounts() {
    final String now = _now.toUtc().toIso8601String();
    final String createdAt = DateFormat('MMMM yyyy').format(_now);

    AppAccount make(String id, String username, String email) {
      final String salt = _hasher.newSalt();
      return AppAccount(
        id: id,
        userId: id,
        email: email,
        username: username,
        passwordHash: _hasher.hash('password123', salt),
        passwordSalt: salt,
        gender: 'Prefer not to say',
        dobDay: '14',
        dobMonth: 'May',
        dobYear: '1998',
        weightKg: '74',
        heightCm: '178',
        personalDetailsComplete: true,
        createdAt: createdAt,
        createdAtUtc: now,
        updatedAtUtc: now,
      );
    }

    return <AppAccount>[
      make('u_joe_01', 'Joe123', 'joe@example.com'),
      make('u_alex_01', 'Alex', 'alex@example.com'),
    ];
  }

  void _restore(Map<String, dynamic> document) {
    final Object? userJson = document['user'];
    if (userJson is Map<String, dynamic>) {
      user = AppUser.fromJson(userJson);
    }
    final Object? settingsJson = document['settings'];
    if (settingsJson is Map<String, dynamic>) {
      settings = AppSettings.fromJson(settingsJson);
    }
    isDarkMode = document['isDarkMode'] == true;
    isProgramAdjusted = document['isProgramAdjusted'] == true;
    adjustmentFactor =
        (document['adjustmentFactor'] as num?)?.toDouble() ?? 0.9;
    isLoggedIn = document['isLoggedIn'] == true;

    accounts = _mapList(document['accounts'])
        .map(AppAccount.fromJson)
        .where((AppAccount a) => a.email.isNotEmpty)
        .toList();
    personalDetailsComplete = _accountFor(user.id)?.personalDetailsComplete ??
        (document['personalDetailsComplete'] == true);

    final List<Exercise> restoredCatalogue = _mapList(document['catalogue'])
        .map(Exercise.fromJson)
        .where((Exercise e) => e.name.isNotEmpty)
        .toList();
    catalogue = restoredCatalogue.isEmpty
        ? SeedData.catalogue(_now)
        : restoredCatalogue;

    final List<Program> restoredPrograms =
        _mapList(document['programs']).map(Program.fromJson).toList();
    if (restoredPrograms.isEmpty) {
      programs = SeedData.programs(_now);
    } else {
      programs = restoredPrograms;
      if (!programs.any((Program p) => p.active)) {
        programs = <Program>[
          programs.first.copyWith(active: true),
          ...programs.skip(1),
        ];
      }
    }

    final List<WorkoutSession> restoredHistory = _mapList(document['history'])
        .map(WorkoutSession.fromJson)
        .where((WorkoutSession s) => s.id.isNotEmpty && s.name.isNotEmpty)
        .toList();
    history =
        restoredHistory.isEmpty ? SeedData.history(_now) : restoredHistory;

    final Object? draft = document['activeWorkout'];
    if (draft is Map<String, dynamic>) {
      final ActiveWorkout restored = ActiveWorkout.fromJson(draft);
      final Program? active = getActiveProgram();
      activeWorkout = ActiveWorkout(
        programId: restored.programId.isEmpty
            ? (active?.id ?? '')
            : restored.programId,
        sessionName: restored.sessionName.isEmpty
            ? (active?.name ?? 'Empty Workout')
            : restored.sessionName,
        sessionType: restored.sessionType,
        exercises: restored.exercises.isEmpty
            ? (active?.exercises ?? const <ProgramExercise>[])
            : restored.exercises,
        currentExercise: restored.currentExercise.isEmpty
            ? (active?.exercises.isNotEmpty == true
                ? active!.exercises.first.name
                : '')
            : restored.currentExercise,
        weightInput: restored.weightInput,
        repsInput: restored.repsInput,
        inputMethod: restored.inputMethod,
        restTotalSeconds: restored.restTotalSeconds,
        restSeconds: restored.restSeconds,
        sets: restored.sets,
        voiceSimText: restored.voiceSimText,
      );
    } else {
      final Program? active = getActiveProgram();
      if (active != null) {
        activeWorkout = _workoutFor(active, 'full', clearSets: true);
      }
    }
  }

  /// Writes the current state back to the store.
  Future<void> persist() async {
    await store.write(<String, dynamic>{
      'schemaVersion': 1,
      'seedVersion': 1,
      'user': user.toJson(),
      'accounts': accounts.map((AppAccount a) => a.toJson()).toList(),
      'isLoggedIn': isLoggedIn,
      'personalDetailsComplete': personalDetailsComplete,
      'settings': settings.toJson(),
      'isDarkMode': isDarkMode,
      'isProgramAdjusted': isProgramAdjusted,
      'adjustmentFactor': adjustmentFactor,
      'programs': programs.map((Program p) => p.toJson()).toList(),
      'history': history.map((WorkoutSession s) => s.toJson()).toList(),
      'activeWorkout': activeWorkout.toJson(),
      'quizAnswers': Map<String, dynamic>.from(quizAnswers),
      'showQuizBannerOnHome': showQuizBannerOnHome,
      'quizShortMode': quizShortMode,
      'quizStepIndex': quizStepIndex,
    });
  }

  /// The account record matching [userId], if any.
  AppAccount? _accountFor(String userId) {
    for (final AppAccount account in accounts) {
      if (account.id == userId || account.userId == userId) return account;
    }
    return null;
  }

  // --------------------------------------------------------------- accounts

  /// Registers a local account.
  ///
  /// Returns an error message, or `null` when the account was created. The
  /// new account starts with `personalDetailsComplete = false`, so the flow
  /// continues on the personal-details screen.
  String? registerAccount({required String email, required String password}) {
    final String cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      return 'Please enter a valid email address';
    }
    if (password.isEmpty) {
      return 'Please enter a password';
    }
    for (final AppAccount account in accounts) {
      if (account.email.toLowerCase() == cleanEmail) {
        return 'An account with this email already exists';
      }
    }

    final String now = DateTime.now().toUtc().toIso8601String();
    final String id = 'u_${DateTime.now().millisecondsSinceEpoch}';
    final String salt = _hasher.newSalt();
    final AppAccount account = AppAccount(
      id: id,
      userId: id,
      email: cleanEmail,
      username: '',
      passwordHash: _hasher.hash(password, salt),
      passwordSalt: salt,
      gender: 'Prefer not to say',
      dobDay: '',
      dobMonth: '',
      dobYear: '',
      weightKg: '',
      heightCm: '',
      personalDetailsComplete: false,
      createdAt: DateFormat('MMMM yyyy').format(DateTime.now()),
      createdAtUtc: now,
      updatedAtUtc: now,
    );
    accounts = <AppAccount>[...accounts, account];
    user = _profileFor(account);
    isLoggedIn = true;
    personalDetailsComplete = false;
    history = <WorkoutSession>[];
    unawaited(persist());
    notifyListeners();
    return null;
  }

  /// Signs an account in.
  ///
  /// The identifier may be the e-mail address or the username. Returns an
  /// error message, or `null` on success.
  String? login({required String identifier, required String password}) {
    final String key = identifier.trim().toLowerCase();
    if (key.isEmpty || password.isEmpty) {
      return 'Incorrect email or password';
    }

    AppAccount? match;
    for (final AppAccount account in accounts) {
      if (account.email.toLowerCase() == key ||
          account.username.toLowerCase() == key) {
        match = account;
        break;
      }
    }

    if (match == null) {
      // The prototype signs unknown e-mails up on the fly.
      final String? error = registerAccount(
        email: identifier,
        password: password,
      );
      if (error != null) return error;
      final AppAccount created = accounts.last;
      accounts = <AppAccount>[
        ...accounts.take(accounts.length - 1),
        created.copyWith(personalDetailsComplete: true),
      ];
      personalDetailsComplete = true;
      user = _profileFor(accounts.last);
      unawaited(persist());
      notifyListeners();
      return null;
    }

    if (!_hasher.verify(
      password: password,
      salt: match.passwordSalt,
      expectedHash: match.passwordHash,
    )) {
      return 'Incorrect email or password';
    }

    isLoggedIn = true;
    personalDetailsComplete = match.personalDetailsComplete;
    user = _profileFor(match);
    unawaited(persist());
    notifyListeners();
    return null;
  }

  /// Signs the current user out.
  void logout() {
    isLoggedIn = false;
    unawaited(persist());
    notifyListeners();
    showToast('Logged out', kind: ToastKind.info);
  }

  /// Saves the personal details of the signed-in account.
  ///
  /// Returns the validation result; when it is valid the account is updated
  /// and `personalDetailsComplete` becomes `true`.
  PersonalDetailsCheck savePersonalDetails({
    required String username,
    required String dobDay,
    required String dobMonth,
    required String dobYear,
    required String gender,
    required String weightRaw,
    required String heightRaw,
  }) {
    final PersonalDetailsCheck check = validatePersonalDetails(
      username: username,
      dobDay: dobDay,
      dobMonth: dobMonth,
      dobYear: dobYear,
      gender: gender,
      weightRaw: weightRaw,
      heightRaw: heightRaw,
      now: DateTime.now(),
    );
    if (!check.isValid) return check;

    user = user.copyWith(
      username: check.username,
      gender: check.gender,
      dobDay: check.dobDay,
      dobMonth: check.dobMonth,
      dobYear: check.dobYear,
      weightKg: check.weightKg,
      heightCm: check.heightCm,
    );
    personalDetailsComplete = true;

    final AppAccount? account = _accountFor(user.id);
    if (account != null) {
      accounts = accounts
          .map(
            (AppAccount a) => a.id == account.id
                ? a.copyWith(
                    username: check.username,
                    gender: check.gender,
                    dobDay: check.dobDay,
                    dobMonth: check.dobMonth,
                    dobYear: check.dobYear,
                    weightKg: check.weightKg,
                    heightCm: check.heightCm,
                    personalDetailsComplete: true,
                  )
                : a,
          )
          .toList();
    }

    unawaited(persist());
    notifyListeners();
    return check;
  }

  /// The profile shown in the UI for an account record.
  AppUser _profileFor(AppAccount account) {
    final String now = DateTime.now().toUtc().toIso8601String();
    return AppUser(
      id: account.id,
      userId: account.userId,
      username: account.username,
      email: account.email,
      gender: account.gender,
      dobDay: account.dobDay,
      dobMonth: account.dobMonth,
      dobYear: account.dobYear,
      weightKg: account.weightKg,
      heightCm: account.heightCm,
      createdAt: account.createdAt,
      createdAtUtc: account.createdAtUtc.isEmpty ? now : account.createdAtUtc,
      updatedAtUtc: now,
    );
  }

  // ----------------------------------------------------------------- toast

  void showToast(String message, {ToastKind kind = ToastKind.success}) {
    toastText = message;
    toastKind = kind;
    _toastTimer?.cancel();
    _toastTimer = Timer(const Duration(milliseconds: 2800), () {
      toastText = null;
      notifyListeners();
    });
    notifyListeners();
  }

  void clearToast() {
    _toastTimer?.cancel();
    toastText = null;
    notifyListeners();
  }

  // -------------------------------------------------------------- settings

  void setThemeExplicit(bool dark) {
    isDarkMode = dark;
    unawaited(persist());
    notifyListeners();
  }

  void toggleDeviceSetting(String key) {
    switch (key) {
      case 'bellSound':
        settings = settings.copyWith(bellSound: !settings.bellSound);
        break;
      case 'restNotifications':
        settings = settings.copyWith(
          restNotifications: !settings.restNotifications,
        );
        break;
      case 'sensorAutoDetect':
        settings = settings.copyWith(
          sensorAutoDetect: !settings.sensorAutoDetect,
        );
        break;
      case 'voiceLogging':
        settings = settings.copyWith(voiceLogging: !settings.voiceLogging);
        break;
      case 'lockscreenWidget':
        settings = settings.copyWith(
          lockscreenWidget: !settings.lockscreenWidget,
        );
        break;
      case 'hapticFeedback':
        settings = settings.copyWith(hapticFeedback: !settings.hapticFeedback);
        break;
    }
    unawaited(persist());
    showToast('Updated $key preference', kind: ToastKind.info);
  }

  void switchInputMethod(String method) {
    activeWorkout = activeWorkout.copyWith(inputMethod: method);
    unawaited(persist());
    notifyListeners();
  }

  // -------------------------------------------------------------- programs

  Program? getActiveProgram() {
    for (final Program program in programs) {
      if (program.active) return program;
    }
    return programs.isEmpty ? null : programs.first;
  }

  void setActiveProgram(String programId) {
    Program? found;
    programs = programs.map((Program p) {
      final bool isTarget = p.id == programId;
      if (isTarget) found = p;
      return p.copyWith(active: isTarget);
    }).toList();
    if (found != null) {
      activeWorkout = _workoutFor(
        found!,
        found!.type == 'Micro' ? 'micro' : 'full',
        clearSets: true,
      );
    }
    unawaited(persist());
    notifyListeners();
    showToast(
      'Selected "${found?.name ?? 'Program'}" as current program!',
    );
  }

  void startProgramWorkout(String programId, String mode) {
    Program? found;
    for (final Program program in programs) {
      if (program.id == programId) {
        found = program;
        break;
      }
    }
    found ??= getActiveProgram();
    if (found == null) return;

    final Program target = found;
    final bool switching = activeWorkout.programId != target.id;
    programs = programs
        .map((Program p) => p.copyWith(active: p.id == target.id))
        .toList();
    activeWorkout = _workoutFor(
      target,
      mode.isEmpty ? (target.type == 'Micro' ? 'micro' : 'full') : mode,
      clearSets: switching,
    );
    unawaited(persist());
    notifyListeners();
    showToast(
      'Loaded ${target.name} (${activeWorkout.exercises.length} exercises)',
    );
  }

  void startEmptyWorkout() {
    activeWorkout = const ActiveWorkout(
      programId: 'p_empty',
      sessionName: 'Empty Workout',
      sessionType: 'micro',
      exercises: <ProgramExercise>[],
      currentExercise: '',
      weightInput: '0',
      repsInput: 10,
      inputMethod: 'manual',
      restTotalSeconds: 120,
      restSeconds: 120,
      sets: <LoggedSet>[],
    );
    unawaited(persist());
    notifyListeners();
    showToast('Started Empty Workout. Add an exercise to begin!');
  }

  ActiveWorkout _workoutFor(
    Program program,
    String mode, {
    required bool clearSets,
  }) {
    final List<ProgramExercise> exercises = program.exercises;
    final ProgramExercise? first = exercises.isEmpty ? null : exercises.first;
    return ActiveWorkout(
      programId: program.id,
      sessionName: program.name,
      sessionType: mode,
      exercises: exercises,
      currentExercise: first?.name ?? '',
      weightInput: (first?.weightKg ?? 0).toString(),
      repsInput: first?.reps ?? 10,
      inputMethod: activeWorkout.inputMethod,
      restTotalSeconds: activeWorkout.restTotalSeconds,
      restSeconds: activeWorkout.restTotalSeconds,
      sets: clearSets ? <LoggedSet>[] : activeWorkout.sets,
    );
  }

  void deleteProgram(String programId) {
    final Program? target =
        programs.where((Program p) => p.id == programId).firstOrNull;
    programs = programs.where((Program p) => p.id != programId).toList();
    if (programs.isEmpty) {
      startEmptyWorkout();
    } else if (!programs.any((Program p) => p.active)) {
      programs = <Program>[
        programs.first.copyWith(active: true),
        ...programs.skip(1)
      ];
      final Program next = programs.first;
      activeWorkout = _workoutFor(next, 'full', clearSets: true);
    }
    unawaited(persist());
    notifyListeners();
    if (target != null) {
      showToast('Deleted "${target.name}"', kind: ToastKind.info);
    }
  }

  Program createProgram({
    required String name,
    required String type,
    required int sets,
    required int reps,
    required double weightKg,
    required List<ProgramExercise> exercises,
  }) {
    final String now = _now.toUtc().toIso8601String();
    final Program program = Program(
      id: 'p_custom_${DateTime.now().millisecondsSinceEpoch}',
      userId: SeedData.userId,
      name: name,
      splitGroup: type,
      type: type,
      duration: type == 'Micro' ? '8 min' : '35 min',
      frequency: '3 days/wk',
      difficulty: 'Custom',
      active: true,
      exercises: exercises
          .map((ProgramExercise e) => e.copyWith(
                sets: sets,
                reps: reps,
                weightKg: weightKg,
              ))
          .toList(),
      createdAtUtc: now,
      updatedAtUtc: now,
    );
    programs = <Program>[
      program,
      ...programs.map((Program p) => p.copyWith(active: false))
    ];
    activeWorkout = _workoutFor(program, 'full', clearSets: true);
    unawaited(persist());
    notifyListeners();
    return program;
  }

  // -------------------------------------------------------------- workout

  ProgramExercise? get currentTarget {
    final String name = activeWorkout.currentExercise.toLowerCase();
    for (final ProgramExercise exercise in activeWorkout.exercises) {
      if (exercise.name.toLowerCase() == name) return exercise;
    }
    return null;
  }

  int loggedCountFor(String exerciseName) {
    final String key = exerciseName.toLowerCase();
    return activeWorkout.sets
        .where((LoggedSet s) => s.exerciseName.toLowerCase() == key)
        .length;
  }

  double get activeVolume {
    double total = 0;
    for (final LoggedSet set in activeWorkout.sets) {
      total += set.weightKg * set.reps;
    }
    return double.parse(total.toStringAsFixed(1));
  }

  void changeActiveExercise(String name) {
    final ProgramExercise? target = activeWorkout.exercises
        .where(
            (ProgramExercise e) => e.name.toLowerCase() == name.toLowerCase())
        .firstOrNull;
    activeWorkout = activeWorkout.copyWith(
      currentExercise: name,
      weightInput: (target?.weightKg ?? 0).toString(),
      repsInput: target?.reps ?? 0,
    );
    unawaited(persist());
    notifyListeners();
  }

  void stepActiveExercise(int delta) {
    final List<ProgramExercise> exercises = activeWorkout.exercises;
    if (exercises.isEmpty) return;
    int index = exercises.indexWhere(
      (ProgramExercise e) =>
          e.name.toLowerCase() == activeWorkout.currentExercise.toLowerCase(),
    );
    if (index < 0) index = 0;
    final int next = (index + delta).clamp(0, exercises.length - 1);
    changeActiveExercise(exercises[next].name);
  }

  void updateWeightInput(String value) {
    activeWorkout = activeWorkout.copyWith(weightInput: value);
    notifyListeners();
  }

  void updateRepsInput(int value) {
    activeWorkout = activeWorkout.copyWith(repsInput: value < 0 ? 0 : value);
    notifyListeners();
  }

  void incrementRepCounter(int delta) {
    final int next = (activeWorkout.repsInput + delta) < 0
        ? 0
        : activeWorkout.repsInput + delta;
    activeWorkout = activeWorkout.copyWith(repsInput: next);
    notifyListeners();
  }

  /// Validates the current weight. Returns an error message, or `null` when
  /// the value is acceptable.
  String? validateWeight(String raw) {
    final String value = raw.trim();
    if (value.isEmpty) {
      return 'Please enter a valid weight in kg (0 or greater).';
    }
    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(value)) {
      return 'Weight (kg) must be a valid non-negative number.';
    }
    final double parsed = double.parse(value);
    if (parsed < 0 || parsed > 1000) {
      return 'Weight (kg) must be between 0 and 1000.';
    }
    return null;
  }

  /// The single write path for sets (manual, sensor, voice and lockscreen all
  /// funnel through here). Returns an error message when the set was rejected.
  String? logCurrentSet() {
    if (activeWorkout.currentExercise.isEmpty) {
      return 'Please add or select an exercise first.';
    }
    final String? error = validateWeight(activeWorkout.weightInput);
    if (error != null) return error;

    final double weight = double.parse(activeWorkout.weightInput.trim());
    final int reps = activeWorkout.repsInput;
    final int exerciseSetNo = loggedCountFor(activeWorkout.currentExercise) + 1;
    final String now = DateTime.now().toUtc().toIso8601String();
    final LoggedSet set = LoggedSet(
      id: 'ws_${DateTime.now().millisecondsSinceEpoch}_'
          '${DateTime.now().microsecondsSinceEpoch % 1000}',
      userId: SeedData.userId,
      exerciseName: activeWorkout.currentExercise,
      setNo: activeWorkout.sets.length + 1,
      exerciseSetNo: exerciseSetNo,
      weightKg: weight,
      reps: reps,
      restS: activeWorkout.restTotalSeconds,
      inputMethod: activeWorkout.inputMethod,
      loggedAtUtc: now,
      createdAtUtc: now,
      updatedAtUtc: now,
    );

    activeWorkout = activeWorkout.copyWith(
      sets: <LoggedSet>[...activeWorkout.sets, set],
      restSeconds: activeWorkout.restTotalSeconds,
    );
    restRunning = false;
    restCompleted = false;
    restEndTime = null;
    _ticker?.cancel();
    unawaited(persist());
    notifyListeners();
    showToast(
      'Logged Set #${set.setNo} for ${set.exerciseName} '
      '(${_trimWeight(set.weightKg)} kg × ${set.reps} reps)',
    );
    return null;
  }

  void removeLoggedSet(String setId) {
    final List<LoggedSet> remaining =
        activeWorkout.sets.where((LoggedSet s) => s.id != setId).toList();
    activeWorkout = activeWorkout.copyWith(sets: remaining);
    unawaited(persist());
    notifyListeners();
  }

  /// Applies the voice command text (`"22.5 kg for 8 reps"`).
  void parseVoiceSet(String text) {
    final RegExp number = RegExp(r'\d+(\.\d+)?');
    final List<RegExpMatch> matches =
        number.allMatches(text).toList(growable: false);
    if (matches.length >= 2) {
      activeWorkout = activeWorkout.copyWith(
        weightInput: matches[0].group(0),
        repsInput: int.parse(matches[1].group(0)!),
      );
    }
    logCurrentSet();
  }

  /// Simulated auto-count: bumps the rep counter while the simulation runs.
  void toggleSensorSimulation() {
    sensorSimActive = !sensorSimActive;
    _sensorTicker?.cancel();
    if (sensorSimActive) {
      _sensorTicker = Timer.periodic(const Duration(milliseconds: 1100), (_) {
        incrementRepCounter(1);
      });
    }
    notifyListeners();
  }

  /// Finishes the workout and stores the session in history.
  WorkoutSession? finishActiveWorkout() {
    if (activeWorkout.sets.isEmpty) {
      showToast(
        'Log at least one set before finishing your workout.',
        kind: ToastKind.info,
      );
      return null;
    }

    int totalReps = 0;
    double totalVolume = 0;
    final Set<String> methods = <String>{};
    for (final LoggedSet set in activeWorkout.sets) {
      totalReps += set.reps;
      totalVolume += set.weightKg * set.reps;
      methods.add(set.inputMethod);
    }

    final DateTime now = DateTime.now();
    final int durationMin = _durationMinutes;
    final String label = DateFormat('MMM d, HH:mm').format(now);
    final String nowIso = now.toUtc().toIso8601String();
    final List<String> methodList = methods.toList(growable: false);

    final WorkoutSession session = WorkoutSession(
      id: 's_${DateTime.now().millisecondsSinceEpoch}',
      userId: SeedData.userId,
      name: activeWorkout.sessionName,
      type: activeWorkout.sessionType,
      dateLabel: label,
      dayOfMonth: now.day,
      startedAtUtc: nowIso,
      durationMin: durationMin,
      reps: totalReps,
      volume: double.parse(totalVolume.toStringAsFixed(1)),
      setsCount: activeWorkout.sets.length,
      methods: methodList,
      setsDetail: activeWorkout.sets,
      createdAtUtc: nowIso,
      updatedAtUtc: nowIso,
    );

    history = <WorkoutSession>[session, ...history];
    lastCompletedWorkout = WorkoutSummary(
      name: session.name,
      type: session.type,
      durationMin: session.durationMin,
      totalSets: session.setsCount,
      totalReps: session.reps,
      totalVolume: session.volume,
      methods: methodList,
    );
    activeWorkout = activeWorkout.copyWith(sets: <LoggedSet>[]);
    unawaited(persist());
    notifyListeners();
    return session;
  }

  /// Elapsed workout time, measured from the first logged set of the session.
  int get _durationMinutes {
    if (activeWorkout.sets.isEmpty) return 0;
    final DateTime first = DateTime.parse(activeWorkout.sets.first.loggedAtUtc);
    final int seconds = DateTime.now().difference(first).inSeconds;
    if (seconds <= 0) return 1;
    return (seconds / 60).ceil();
  }

  // ---------------------------------------------------------------- history

  void deleteSession(String sessionId) {
    history = history.where((WorkoutSession s) => s.id != sessionId).toList();
    unawaited(persist());
    notifyListeners();
  }

  /// Combines the first two micro sessions into one stitched session.
  WorkoutSession? stitchMicroSessions() {
    final List<WorkoutSession> micros =
        history.where((WorkoutSession s) => s.type == 'micro').take(2).toList();
    if (micros.length < 2) return null;

    final WorkoutSession first = micros[0];
    final WorkoutSession second = micros[1];
    final String now = _now.toUtc().toIso8601String();
    final List<LoggedSet> combined = <LoggedSet>[
      ...first.setsDetail,
      ...second.setsDetail,
    ];

    final WorkoutSession stitched = WorkoutSession(
      id: 's_stitched_${DateTime.now().millisecondsSinceEpoch}',
      userId: SeedData.userId,
      name: '${first.name} + ${second.name}',
      type: 'stitched',
      dateLabel: first.dateLabel,
      dayOfMonth: first.dayOfMonth,
      startedAtUtc: first.startedAtUtc,
      durationMin: first.durationMin + second.durationMin,
      reps: first.reps + second.reps,
      volume: double.parse((first.volume + second.volume).toStringAsFixed(1)),
      setsCount: first.setsCount + second.setsCount,
      methods: const <String>['manual', 'lockscreen'],
      setsDetail: combined,
      children: <WorkoutSession>[first, second],
      createdAtUtc: now,
      updatedAtUtc: now,
    );

    history = <WorkoutSession>[
      stitched,
      ...history.where(
        (WorkoutSession s) => s.id != first.id && s.id != second.id,
      ),
    ];
    unawaited(persist());
    notifyListeners();
    showToast('Stitched ${micros.length} micro sessions.');
    return stitched;
  }

  /// Replaces a stitched session with its children.
  int unstitchSession(String sessionId) {
    final int index =
        history.indexWhere((WorkoutSession s) => s.id == sessionId);
    if (index < 0) return 0;
    final WorkoutSession item = history[index];
    final List<WorkoutSession> children = item.children.isNotEmpty
        ? item.children
        : <WorkoutSession>[
            _syntheticChild(item, 1),
            _syntheticChild(item, 2),
          ];
    history = <WorkoutSession>[
      ...history.take(index),
      ...children,
      ...history.skip(index + 1),
    ];
    unawaited(persist());
    notifyListeners();
    showToast('Unstitched into ${children.length} individual Micro sessions!');
    return children.length;
  }

  WorkoutSession _syntheticChild(WorkoutSession parent, int part) {
    final String now = _now.toUtc().toIso8601String();
    final int halfReps = parent.reps ~/ 2;
    final double halfVolume = (parent.volume / 2).roundToDouble();
    return WorkoutSession(
      id: '${parent.id}_$part',
      userId: SeedData.userId,
      name: '${parent.name} (Part $part)',
      type: 'micro',
      dateLabel: parent.dateLabel,
      dayOfMonth: parent.dayOfMonth,
      startedAtUtc: parent.startedAtUtc,
      durationMin: part == 1 ? 12 : 14,
      reps: part == 1 ? halfReps : parent.reps - halfReps,
      volume: part == 1 ? halfVolume : parent.volume - halfVolume,
      setsCount: 2,
      methods: part == 1 ? const <String>['manual'] : const <String>['voice'],
      setsDetail: const <LoggedSet>[],
      createdAtUtc: now,
      updatedAtUtc: now,
    );
  }

  // ------------------------------------------------------------------- quiz

  List<QuizQuestion> get activeQuizQuestions {
    if (!quizShortMode) return SeedData.quizQuestions;
    return <QuizQuestion>[
      SeedData.quizQuestions[0],
      SeedData.quizQuestions[1],
      SeedData.quizQuestions[9],
    ];
  }

  void selectQuizOption(String questionId, String value) {
    quizAnswers[questionId] = value;
    notifyListeners();
  }

  void toggleQuizLengthMode() {
    quizShortMode = !quizShortMode;
    quizStepIndex = 0;
    notifyListeners();
  }

  void setQuizStep(int index) {
    quizStepIndex = index;
    notifyListeners();
  }

  /// The quiz rule table, ported from `getComputedQuizAdjustment`
  /// (`index.html` lines 1885-1895).
  QuizAdjustment computedQuizAdjustment() {
    final String energy = quizAnswers['q2'] ?? 'Low';
    final String pushPreference = quizAnswers['q10'] ?? 'No, reduced intensity';
    final String frequencyDays = quizAnswers['q4'] ?? '3-4';

    if (pushPreference == 'Yes, progress the weight') {
      return QuizAdjustment(
        factor: 1.05,
        pctText: '+5%',
        intensityLabel: 'Progressive Overload (+5%)',
        sessionLength: '40 min (+5 min)',
        frequency: '$frequencyDays days/week',
      );
    }
    if (energy == 'Low' || pushPreference == 'No, reduced intensity') {
      return const QuizAdjustment(
        factor: 0.85,
        pctText: '-15%',
        intensityLabel: 'Reduced (-15% volume & load)',
        sessionLength: '25 min (-10 min)',
        frequency: '3 days/week',
      );
    }
    return QuizAdjustment(
      factor: 0.90,
      pctText: '-10%',
      intensityLabel: 'Moderate Deload (-10% weight)',
      sessionLength: '25 min (-10 min)',
      frequency: '$frequencyDays days/week',
    );
  }

  /// Applies the adjusted weights to the active program.
  void acceptAdjustedProgram() {
    final QuizAdjustment adjustment = computedQuizAdjustment();
    final Program? active = getActiveProgram();
    if (active != null) {
      programs = programs.map((Program p) {
        if (p.id != active.id) return p;
        return p.copyWith(
          exercises: p.exercises
              .map(
                (ProgramExercise e) => e.copyWith(
                  weightKg: _roundToHalf(e.weightKg * adjustment.factor),
                ),
              )
              .toList(),
        );
      }).toList();
      activeWorkout = _workoutFor(active, 'full', clearSets: true);
    }
    isProgramAdjusted = true;
    adjustmentFactor = adjustment.factor;
    showQuizBannerOnHome = false;
    unawaited(persist());
    notifyListeners();
    showToast(
      'Adjusted program accepted (${adjustment.pctText} load applied)!',
    );
  }

  void keepOldProgram() {
    isProgramAdjusted = false;
    showQuizBannerOnHome = false;
    unawaited(persist());
    notifyListeners();
    showToast('Kept original program weights.', kind: ToastKind.info);
  }

  void dismissQuizBanner() {
    showQuizBannerOnHome = false;
    unawaited(persist());
    notifyListeners();
    showToast(
      'Quiz reminder snoozed. You can launch it anytime from Settings.',
      kind: ToastKind.info,
    );
  }

  void retriggerQuizBanner() {
    showQuizBannerOnHome = true;
    unawaited(persist());
    notifyListeners();
  }

  // -------------------------------------------------------------- catalogue

  /// The body-part filter pills offered by the Discover screen.
  ///
  /// "Other" is only offered when at least one exercise uses it — the same
  /// rule as the prototype's `getAvailableDiscoverFilters`.
  List<String> get availableCatalogueFilters {
    final bool hasOther = catalogue.any(
      (Exercise e) => _bodyPartLabel(e) == 'Other',
    );
    return discoverBodyPartFilters
        .where((String filter) => filter != 'Other' || hasOther)
        .toList(growable: false);
  }

  /// The display label of an exercise's body part.
  String _bodyPartLabel(Exercise exercise) {
    if (exercise.bodyPartLabel.isNotEmpty) return exercise.bodyPartLabel;
    return normalizeExerciseBodyPart(
      exercise.bodyPart.isEmpty ? exercise.category : exercise.bodyPart,
      primaryMuscles: exercise.primaryMuscles,
    );
  }

  /// The lower-cased search haystack of an exercise.
  String _searchIndexFor(Exercise exercise) {
    if (exercise.searchIndex.isNotEmpty) return exercise.searchIndex;
    return buildSearchIndex(
      id: exercise.id,
      name: exercise.nameEn.isEmpty ? exercise.name : exercise.nameEn,
      description: exercise.descriptionEn.isEmpty
          ? exercise.description
          : exercise.descriptionEn,
      bodyPart: exercise.bodyPart,
      bodyPartLabel: _bodyPartLabel(exercise),
      exerciseCategory: exercise.exerciseCategory,
      difficulty: exercise.difficulty,
      equipment: exercise.equipment,
      equipmentLabel: exercise.equipment,
      isBodyweight: exercise.isBodyweight,
      isUnilateral: exercise.isUnilateral,
      primaryMuscles: exercise.primaryMuscles,
      secondaryMuscles: exercise.secondaryMuscles,
      goals: exercise.goals,
      tags: exercise.tags,
    );
  }

  /// Whether an exercise passes the current Discover filter and search.
  bool matchesCatalogueFilters(Exercise exercise) {
    final bool filterMatches = matchesBodyPartFilter(
      bodyPartLabel: _bodyPartLabel(exercise),
      exerciseCategory: exercise.exerciseCategory,
      goals: exercise.goals,
      tags: exercise.tags,
      filter: catalogueFilter,
    );
    final bool searchMatches =
        matchesSearchIndex(_searchIndexFor(exercise), catalogueSearch);
    return filterMatches && searchMatches;
  }

  /// The Discover results for the current filter and search.
  ///
  /// The database answers the query; without a repository the state falls
  /// back to filtering the in-memory catalogue.
  Future<List<Exercise>> searchCatalogue(
      {int limit = 60, int offset = 0}) async {
    final ExerciseRepository? repository = _exercises;
    if (repository != null) {
      return repository.search(
        query: catalogueSearch,
        bodyPartFilter: catalogueFilter,
        limit: limit,
        offset: offset,
      );
    }
    final List<Exercise> filtered =
        catalogue.where(matchesCatalogueFilters).toList(growable: false);
    if (limit <= 0) return filtered;
    return filtered.skip(offset).take(limit).toList(growable: false);
  }

  /// How many exercises match the current filter and search.
  Future<int> countCatalogue() async {
    final ExerciseRepository? repository = _exercises;
    if (repository != null) {
      return repository.count(
        query: catalogueSearch,
        bodyPartFilter: catalogueFilter,
      );
    }
    return catalogue.where(matchesCatalogueFilters).length;
  }

  /// The exercise the Discover detail screen is showing.
  Exercise? get selectedExercise {
    final String? id = selectedExerciseId;
    if (id == null) return null;
    for (final Exercise exercise in catalogue) {
      if (exercise.id == id) return exercise;
    }
    return null;
  }

  /// Opens the detail screen of an exercise.
  void openExerciseDetail(String exerciseId) {
    selectedExerciseId = exerciseId;
    notifyListeners();
  }

  /// Clears the Discover search and body-part filter.
  void resetCatalogueFilters() {
    catalogueFilter = 'All';
    catalogueSearch = '';
    discoverVisibleLimit = 60;
    notifyListeners();
  }

  /// Reveals the next batch of Discover results.
  void showMoreCatalogue() {
    discoverVisibleLimit += 120;
    notifyListeners();
  }

  Exercise? findExercise(String name) {
    for (final Exercise exercise in catalogue) {
      if (exercise.name.toLowerCase() == name.toLowerCase()) return exercise;
    }
    return null;
  }

  /// Adds an exercise to the catalogue and to the active workout + program.
  Exercise addExerciseToWorkoutAndProgram({
    required String name,
    int sets = 3,
    int reps = 10,
    double weightKg = 15,
    String category = 'Custom',
  }) {
    Exercise? exercise = findExercise(name);
    if (exercise == null) {
      final String now = _now.toUtc().toIso8601String();
      final String bodyPartLabel =
          normalizeExerciseBodyPart(category, primaryMuscles: const <String>[]);
      exercise = Exercise(
        id: 'cat_custom_${DateTime.now().millisecondsSinceEpoch}',
        userId: SeedData.userId,
        name: name,
        nameEn: name,
        category: bodyPartLabel,
        bodyPart: category,
        bodyPartLabel: bodyPartLabel,
        exerciseCategory: 'strength',
        difficulty: 'beginner',
        equipment: weightKg > 0 ? 'dumbbell' : 'none',
        isBodyweight: weightKg <= 0,
        defaultKg: weightKg,
        defaultReps: reps,
        defaultSets: sets,
        description: 'Custom exercise added manually.',
        descriptionEn: 'Custom exercise added manually.',
        isCustom: true,
        createdAtUtc: now,
        updatedAtUtc: now,
      );
      exercise = exercise.copyWith(
        searchIndex: buildSearchIndex(
          id: exercise.id,
          name: name,
          description: exercise.description,
          bodyPart: exercise.bodyPart,
          bodyPartLabel: bodyPartLabel,
          exerciseCategory: exercise.exerciseCategory,
          difficulty: exercise.difficulty,
          equipment: exercise.equipment,
          equipmentLabel: formatExerciseIdentifier(exercise.equipment),
          isBodyweight: exercise.isBodyweight,
          isUnilateral: exercise.isUnilateral,
          primaryMuscles: exercise.primaryMuscles,
          secondaryMuscles: exercise.secondaryMuscles,
          goals: exercise.goals,
          tags: exercise.tags,
        ),
      );
      catalogue = <Exercise>[exercise, ...catalogue];
      final ExerciseRepository? repository = _exercises;
      if (repository != null) {
        unawaited(repository.upsert(exercise));
      }
    } else {
      catalogue = catalogue.map((Exercise e) {
        if (e.id != exercise!.id) return e;
        return e.copyWith(
          defaultKg: weightKg,
          defaultReps: reps,
          defaultSets: sets,
        );
      }).toList();
    }

    final ProgramExercise programExercise = ProgramExercise(
      name: name,
      sets: sets,
      reps: reps,
      weightKg: weightKg,
      exerciseId: exercise.id,
    );

    final List<ProgramExercise> workoutExercises =
        List<ProgramExercise>.from(activeWorkout.exercises);
    final bool alreadyInWorkout = workoutExercises.any(
      (ProgramExercise e) => e.name.toLowerCase() == name.toLowerCase(),
    );
    if (!alreadyInWorkout) {
      workoutExercises.add(programExercise);
    }

    final String programId = activeWorkout.programId;
    programs = programs.map((Program p) {
      if (p.id != programId) return p;
      final bool already = p.exercises.any(
        (ProgramExercise e) => e.name.toLowerCase() == name.toLowerCase(),
      );
      if (already) return p;
      return p.copyWith(exercises: <ProgramExercise>[
        ...p.exercises,
        programExercise,
      ]);
    }).toList();

    activeWorkout = activeWorkout.copyWith(
      exercises: workoutExercises,
      currentExercise: name,
      weightInput: weightKg.toString(),
      repsInput: reps,
    );
    unawaited(persist());
    notifyListeners();
    return exercise;
  }

  // ---------------------------------------------------------------- profile

  void saveProfile({
    required String username,
    required String email,
    required String gender,
    required String dobMonth,
    required String weightKg,
    required String heightCm,
  }) {
    user = user.copyWith(
      username: username.trim().isEmpty ? 'Alex' : username.trim(),
      email: email.trim().isEmpty ? 'alex@example.com' : email.trim(),
      gender: gender,
      dobMonth: dobMonth,
      weightKg: weightKg,
      heightCm: heightCm,
    );
    final AppAccount? account = _accountFor(user.id);
    if (account != null) {
      accounts = accounts
          .map(
            (AppAccount a) => a.id == account.id
                ? a.copyWith(
                    username: user.username,
                    email: user.email,
                    gender: user.gender,
                    dobMonth: user.dobMonth,
                    weightKg: user.weightKg,
                    heightCm: user.heightCm,
                  )
                : a,
          )
          .toList();
    }
    unawaited(persist());
    notifyListeners();
    showToast('Profile updated!');
  }

  // ------------------------------------------------------------------ misc

  void setProgramsFilter(String filter) {
    programsFilter = filter;
    notifyListeners();
  }

  void setCatalogueFilter(String filter) {
    catalogueFilter = filter;
    discoverVisibleLimit = 60;
    notifyListeners();
  }

  void setCatalogueSearch(String value) {
    catalogueSearch = value;
    discoverVisibleLimit = 60;
    notifyListeners();
  }

  void setHistoryFilter(String filter) {
    historyFilter = filter;
    notifyListeners();
  }

  void setHistorySearch(String value) {
    historySearch = value;
    notifyListeners();
  }

  /// Restores the seeded demo data.
  void resetDemoState() {
    final DateTime now = _now;
    catalogue = SeedData.catalogue(now);
    programs = SeedData.programs(now);
    history = SeedData.history(now);
    isProgramAdjusted = false;
    showQuizBannerOnHome = true;
    final Program active = programs.first;
    activeWorkout = _workoutFor(active, 'full', clearSets: true);
    unawaited(persist());
    unawaited(_loadCatalogue());
    notifyListeners();
    showToast('Seeded data restored.', kind: ToastKind.info);
  }

  // ------------------------------------------------------------- rest timer

  int get restTotalSeconds => activeWorkout.restTotalSeconds;

  /// Seconds left, always derived from the stored end time so the countdown
  /// stays correct while the app is backgrounded.
  int get restSecondsRemaining {
    if (restEndTime == null) return activeWorkout.restSeconds;
    final int remaining =
        (restEndTime!.difference(DateTime.now()).inMilliseconds / 1000).ceil();
    return remaining < 0 ? 0 : remaining;
  }

  bool get isTimerRunning => restRunning;

  void startRestTimerCountdown() {
    timerRunId += 1;
    restRunning = true;
    restCompleted = false;
    restEndTime =
        DateTime.now().add(Duration(seconds: activeWorkout.restSeconds));
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (restEndTime == null) return;
      final int remaining = restSecondsRemaining;
      activeWorkout = activeWorkout.copyWith(restSeconds: remaining);
      if (remaining <= 0) {
        _ticker?.cancel();
        restRunning = false;
        restCompleted = true;
        restEndTime = null;
        activeWorkout = activeWorkout.copyWith(restSeconds: 0);
        onRestTimerFinished?.call();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  /// Invoked when the countdown reaches zero. The screen reacts to it.
  void Function()? onRestTimerFinished;

  void pauseRestTimer() {
    if (!restRunning) return;
    restRunning = false;
    final int remaining = restSecondsRemaining;
    restEndTime = null;
    _ticker?.cancel();
    activeWorkout = activeWorkout.copyWith(restSeconds: remaining);
    notifyListeners();
  }

  void resetRestTimer() {
    restRunning = false;
    restCompleted = false;
    restEndTime = null;
    _ticker?.cancel();
    activeWorkout = activeWorkout.copyWith(
      restSeconds: activeWorkout.restTotalSeconds,
    );
    notifyListeners();
  }

  void skipRestTimer() {
    restRunning = false;
    restCompleted = false;
    restEndTime = null;
    _ticker?.cancel();
    activeWorkout = activeWorkout.copyWith(restSeconds: 0);
    notifyListeners();
  }

  /// Applies a ±15 second adjustment to the remaining time.
  void adjustRestSeconds(int delta) {
    final int current =
        restRunning ? restSecondsRemaining : activeWorkout.restSeconds;
    final int next = (current + delta).clamp(0, 10800);
    activeWorkout = activeWorkout.copyWith(restSeconds: next);
    if (restRunning) {
      restEndTime = DateTime.now().add(Duration(seconds: next));
    }
    notifyListeners();
  }

  /// Applies an edited minutes/seconds duration.
  String? setTimerDuration(int minutes, int seconds) {
    if (minutes < 0 || seconds < 0) {
      return 'Timer duration cannot be negative.';
    }
    if (seconds > 59) return 'Seconds must be between 0 and 59.';
    final int total = minutes * 60 + seconds;
    if (total <= 0) return 'Timer duration must be greater than 0 seconds.';
    if (total > 180 * 60) return 'Timer duration cannot exceed 180 minutes.';
    activeWorkout = activeWorkout.copyWith(
      restTotalSeconds: total,
      restSeconds: total,
    );
    restEndTime = null;
    restRunning = false;
    restCompleted = false;
    _ticker?.cancel();
    notifyListeners();
    return null;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _sensorTicker?.cancel();
    _toastTimer?.cancel();
    super.dispose();
  }
}

double _roundToHalf(double value) => (value * 2).round() / 2;

String _trimWeight(double value) {
  final String text = value.toStringAsFixed(1);
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map<dynamic, dynamic>>()
      .map((Map<dynamic, dynamic> e) => e.cast<String, dynamic>())
      .toList(growable: false);
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final Iterator<T> it = iterator;
    return it.moveNext() ? it.current : null;
  }
}
