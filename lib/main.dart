import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/shell.dart';
import 'data/store.dart';
import 'screens/active_workout_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/html_reference_screen.dart';
import 'screens/login_screen.dart';
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

  final AppState state = AppState(store: LocalBlobStore());
  await state.load();
  await RestAlerts.instance.init();

  runApp(AtomFitApp(state: state));
}

class AtomFitApp extends StatelessWidget {
  const AtomFitApp({super.key, required this.state});

  final AppState state;

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
            initialRoute: AfScreen.home,
            routes: <String, WidgetBuilder>{
              AfScreen.login: (BuildContext context) => const LoginScreen(),
              AfScreen.register: (BuildContext context) =>
                  const RegisterScreen(),
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
