import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/shell.dart';
import 'app/startup_error_app.dart';
import 'data/db/app_database.dart';
import 'data/db/bootstrap.dart';
import 'data/db/exercise_repository.dart';
import 'data/db/legacy_migration.dart';
import 'data/db/sqlite_store.dart';
import 'screens/active_workout_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/exercise_detail_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/html_reference_screen.dart';
import 'screens/login_screen.dart';
import 'screens/lockscreen_widget_screen.dart';
import 'screens/personal_details_screen.dart';
import 'screens/programs_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/quiz_adjusted_program_screen.dart';
import 'screens/quiz_explainer_screen.dart';
import 'screens/quiz_prompt_screen.dart';
import 'screens/quiz_question_screen.dart';
import 'screens/register_screen.dart';
import 'screens/rest_timer_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/workout_complete_screen.dart';
import 'services/notifications.dart';
import 'services/rest_alerts.dart';
import 'services/speech_to_text_source.dart';
import 'state/app_state.dart';
import 'strings.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _boot();
}

/// Keeps the "Rest over" alert from lingering after the user is back in the
/// app. Held here so it is created once per boot and disposed on a retry.
AppLifecycleListener? _lifecycle;

/// Opens the database, prepares the catalogue and loads the saved state.
///
/// The first frame needs this data, so it runs before `runApp`. Anything that
/// fails here is reported on screen ([StartupErrorApp]) instead of leaving the
/// launch window blank.
///
/// This is also the **only** place that wires the real implementations
/// (sqflite, OS notifications, the phone microphone) into [AppState]. Tests
/// build `AppState` themselves with fakes, so a bug that only shows on the
/// device usually means the wiring here is wrong, not the screen.
Future<void> _boot() async {
  try {
    await Firebase.initializeApp();
    // The local database: accounts, exercise catalogue, programs, sessions.
    final AppDatabase database = AppDatabase();
    final SqliteExerciseRepository exercises =
        SqliteExerciseRepository(await database.database);
    final SqliteStore store = SqliteStore(database);

    // Data of the previous (JSON blob) build moves into the database once.
    // A failure here must not stop the app: the user can still train, and the
    // database simply starts empty.
    try {
      await LegacyMigration.run(
        appDatabase: database,
        store: store,
        exercises: exercises,
      );
    } catch (error, stackTrace) {
      debugPrint('AtomFit: legacy migration skipped ($error)\n$stackTrace');
    }

    await DatabaseBootstrap.ensureCatalogue(exercises);

    final AppState state = AppState(
      store: store,
      exercises: exercises,
    );
    state.auth = FirebaseAuthService();
    await state.load();
    // OS notifications: the live rest countdown and the planned-workout
    // reminders. Both are optional; the app works without them.
    await AfNotifications.instance.init();
    state.restTimerNotifications = AfNotifications.instance;
    state.reminders = AfNotifications.instance;
    await state.reconcileReminders();
    await RestAlerts.instance.warmUp();
    // A "Rest over" alert posted while the app was in the background should
    // not sit in the shade once the user is back. Only the finished alert is
    // cleared: a countdown that is still running keeps its notification.
    _lifecycle?.dispose();
    _lifecycle = AppLifecycleListener(
      onResume: AfNotifications.instance.cancelFinished,
    );
    // The microphone behind the voice log. It asks for access on first use and
    // reports a refusal back to the screen, which falls back to typing.
    state.speech = SpeechToTextSource();

    runApp(AtomFitApp(state: state));
  } catch (error, stackTrace) {
    debugPrint('AtomFit: startup failed ($error)\n$stackTrace');
    runApp(
      StartupErrorApp(
        error: error,
        stackTrace: stackTrace,
        retry: _boot,
      ),
    );
  }
}

class AtomFitApp extends StatelessWidget {
  const AtomFitApp({super.key, required this.state});

  final AppState state;

  /// The screen the app opens on — the prototype routes to the login screen
  /// until a user is signed in (`renderCurrentScreen`, `index.html` 1501).
  ///
  /// It is read once, when [MaterialApp] is built. Changing the login flag
  /// later does **not** move the user; screens navigate themselves with
  /// `Navigator.pushReplacementNamed`.
  String get _initialRoute {
    if (!state.isLoggedIn) return AfScreen.login;
    if (!state.personalDetailsComplete) return AfScreen.personalDetails;
    return AfScreen.home;
  }

  @override
  Widget build(BuildContext context) {
    // `ListenableBuilder` sits above `MaterialApp` so a theme or login change
    // rebuilds the whole app shell (top bar, nav, toast) at once. Every screen
    // also subscribes to the same [AppState] through [AfAppScope].
    return AfAppScope(
      state: state,
      child: ListenableBuilder(
        listenable: state,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            title: AfStrings.appTitle,
            debugShowCheckedModeBanner: false,
            theme: AfTheme.light,
            darkTheme: AfTheme.dark,
            themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: _initialRoute,
            routes: <String, WidgetBuilder>{
              AfScreen.login: (BuildContext context) => const LoginScreen(),
              AfScreen.register: (BuildContext context) =>
                  const RegisterScreen(),
              AfScreen.personalDetails: (BuildContext context) =>
                  const PersonalDetailsScreen(),
              AfScreen.home: (BuildContext context) => const HomeScreen(),
              AfScreen.programs: (BuildContext context) =>
                  const ProgramsScreen(),
              AfScreen.activeWorkout: (BuildContext context) =>
                  const ActiveWorkoutScreen(),
              AfScreen.timer: (BuildContext context) => const RestTimerScreen(),
              AfScreen.lockScreenWidget: (BuildContext context) =>
                  const LockScreenWidgetScreen(),
              AfScreen.workoutComplete: (BuildContext context) =>
                  const WorkoutCompleteScreen(),
              AfScreen.history: (BuildContext context) => const HistoryScreen(),
              AfScreen.discover: (BuildContext context) =>
                  const DiscoverScreen(),
              AfScreen.discoverDetail: (BuildContext context) =>
                  const ExerciseDetailScreen(),
              AfScreen.profile: (BuildContext context) => const ProfileScreen(),
              AfScreen.settings: (BuildContext context) =>
                  const SettingsScreen(),
              AfScreen.quizPrompt: (BuildContext context) =>
                  const QuizPromptScreen(),
              AfScreen.quizQuestion: (BuildContext context) =>
                  const QuizQuestionScreen(),
              AfScreen.quizExplainer: (BuildContext context) =>
                  const QuizExplainerScreen(),
              AfScreen.quizAdjusted: (BuildContext context) =>
                  const QuizAdjustedProgramScreen(),
              if (kDebugMode)
                '/reference-html': (BuildContext context) =>
                    const HtmlReferenceScreen(),
            },
          );
        },
      ),
    );
  }
}
