import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_prompt_screen.dart';
import 'screens/quiz_question_screen.dart';
import 'screens/quiz_explainer_screen.dart';
import 'screens/quiz_adjusted_program_screen.dart';
import 'screens/programs_screen.dart';
import 'screens/active_workout_screen.dart';
import 'screens/workout_complete_screen.dart';
import 'screens/history_screen.dart';
import 'screens/discover_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';
import 'texts/app_texts.dart';

void main() {
  runApp(const AtomFitApp());
}

class AtomFitApp extends StatelessWidget {
  const AtomFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppTexts.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: '/login',
      routes: {
        '/': (context) => const LoginScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/quiz/prompt': (context) => const QuizPromptScreen(),
        '/quiz/question': (context) => const QuizQuestionScreen(),
        '/quiz/explainer': (context) => const QuizExplainerScreen(),
        '/quiz/adjusted-program': (context) => const QuizAdjustedProgramScreen(),
        '/programs': (context) => const ProgramsScreen(),
        '/workout/active': (context) => const ActiveWorkoutScreen(),
        '/workout/complete': (context) => const WorkoutCompleteScreen(),
        '/history': (context) => const HistoryScreen(),
        '/discover': (context) => const DiscoverScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
