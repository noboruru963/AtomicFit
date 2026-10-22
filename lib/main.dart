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
import 'services/rest_alerts.dart';
import 'state/app_state.dart';
import 'strings.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _boot();
}

/// Opens the database, prepares the catalogue and loads the saved state.
///
/// The first frame needs this data, so it runs before `runApp`. Anything that
/// fails here is reported on screen ([StartupErrorApp]) instead of leaving the
/// launch window blank.
Future<void> _boot() async {
  try {
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
    await state.load();
    await RestAlerts.instance.init();

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
  String get _initialRoute {
    if (!state.isLoggedIn) return AfScreen.login;
    if (!state.personalDetailsComplete) return AfScreen.personalDetails;
    return AfScreen.home;
  }

  @override
  Widget build(BuildContext context) {
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
