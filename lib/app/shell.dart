import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Provides the [AppState] to the widget tree and rebuilds listeners when it
/// changes.
class AfAppScope extends InheritedNotifier<AppState> {
  const AfAppScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final AfAppScope? scope =
        context.dependOnInheritedWidgetOfExactType<AfAppScope>();
    assert(scope != null, 'AfAppScope is missing from the widget tree');
    return scope!.notifier!;
  }

  /// Reads the state without subscribing to changes.
  static AppState read(BuildContext context) {
    final AfAppScope? scope =
        context.getInheritedWidgetOfExactType<AfAppScope>();
    assert(scope != null, 'AfAppScope is missing from the widget tree');
    return scope!.notifier!;
  }
}

/// Screen identifiers, matching the prototype's `currentScreen` values.
class AfScreen {
  const AfScreen._();

  static const String login = 'login';
  static const String register = 'register';
  static const String personalDetails = 'personal-details';
  static const String home = 'home';
  static const String programs = 'programs';
  static const String activeWorkout = 'active-workout';
  static const String timer = 'timer';
  static const String workoutComplete = 'workout-complete';
  static const String history = 'history';
  static const String discover = 'discover';
  static const String discoverDetail = 'discover-detail';
  static const String profile = 'profile';
  static const String settings = 'settings';
  static const String quizPrompt = 'quiz-prompt';
  static const String quizQuestion = 'quiz-question';
  static const String quizExplainer = 'quiz-explainer';
  static const String quizAdjusted = 'quiz-adjusted';

  /// The prototype's `getScreenTitle()` (lines 1272-1289).
  static String titleFor(String screenId) {
    switch (screenId) {
      case programs:
        return AfStrings.titlePrograms;
      case activeWorkout:
        return AfStrings.titleWorkout;
      case timer:
        return AfStrings.titleTimer;
      case workoutComplete:
        return AfStrings.titleWorkoutComplete;
      case history:
        return AfStrings.titleHistory;
      case discover:
        return AfStrings.titleDiscover;
      case discoverDetail:
        return AfStrings.titleExerciseGuide;
      case profile:
        return AfStrings.titleProfile;
      case settings:
        return AfStrings.titleSettings;
      case personalDetails:
        return AfStrings.titlePersonalDetails;
      case quizPrompt:
        return AfStrings.titleQuizPrompt;
      case quizQuestion:
        return AfStrings.titleQuizQuestion;
      case quizExplainer:
        return AfStrings.titleQuizExplainer;
      case quizAdjusted:
        return AfStrings.titleQuizAdjusted;
      case home:
      default:
        return AfStrings.titleHome;
    }
  }

  /// The auth screens hide the app chrome, like the prototype's
  /// `updateChromeBars()`.
  static bool showsTopBar(String screenId, {bool isLoggedIn = true}) =>
      isLoggedIn &&
      screenId != login &&
      screenId != register &&
      screenId != personalDetails;

  static bool showsBottomNav(String screenId, {bool isLoggedIn = true}) =>
      isLoggedIn &&
      screenId != login &&
      screenId != register &&
      screenId != personalDetails &&
      screenId != timer;
}

/// The persistent app header (`#app-top-bar`).
class AfTopBar extends StatelessWidget {
  const AfTopBar({super.key, required this.screenId});

  final String screenId;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;

    return Container(
      decoration: BoxDecoration(
        color: t.bgCard,
        border: Border(bottom: BorderSide(color: t.borderLine)),
      ),
      // The bar reaches the top edge, its content stays clear of the status
      // bar and the front camera.
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(AfScreen.home),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 32,
                      height: 32,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: t.accent, width: 2),
                      ),
                      child: Image.asset(
                        'assets/images/logo.jpg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AfScreen.titleFor(screenId),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 16,
                            letterSpacing: -0.4,
                          ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: <Widget>[
                  const SizedBox(width: 6),
                  _IconAction(
                    icon: Icons.person_outline,
                    tooltip: AfStrings.titleProfile,
                    onTap: () =>
                        Navigator.of(context).pushNamed(AfScreen.profile),
                  ),
                  const SizedBox(width: 6),
                  _IconAction(
                    icon: Icons.settings_outlined,
                    tooltip: AfStrings.titleSettings,
                    onTap: () =>
                        Navigator.of(context).pushNamed(AfScreen.settings),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: t.bgSubtle,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 16, color: t.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// The persistent bottom navigation (`#app-bottom-nav`).
///
/// Places the **Workout** button prominently in the center with a noticeably
/// larger, raised, rounded style and contrasting blue background, while
/// keeping the remaining navigation buttons smaller and evenly spaced on both
/// sides.
class AfBottomNav extends StatelessWidget {
  const AfBottomNav({super.key, required this.current});

  final String current;

  static const List<({String id, String label, IconData icon})> _leftTabs =
      <({String id, String label, IconData icon})>[
    (id: AfScreen.home, label: 'Home', icon: Icons.home_outlined),
    (id: AfScreen.programs, label: 'Programs', icon: Icons.assignment_outlined),
  ];

  static const List<({String id, String label, IconData icon})> _rightTabs =
      <({String id, String label, IconData icon})>[
    (id: AfScreen.history, label: 'History', icon: Icons.bar_chart_outlined),
    (id: AfScreen.discover, label: 'Discover', icon: Icons.search_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final bool workoutSelected = current == AfScreen.activeWorkout;

    return Container(
      decoration: BoxDecoration(
        color: t.bgCard,
        border: Border(top: BorderSide(color: t.borderLine)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x140F172A),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              for (final ({String id, String label, IconData icon}) tab
                  in _leftTabs)
                Expanded(
                  child: _NavTab(
                    key: ValueKey<String>('nav-tab-${tab.id}'),
                    label: tab.label,
                    icon: tab.icon,
                    selected: tab.id == current,
                    onTap: () {
                      if (tab.id == current) return;
                      Navigator.of(context).pushReplacementNamed(tab.id);
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: AfWorkoutNavButton(
                  key: const ValueKey<String>('nav-workout-button'),
                  selected: workoutSelected,
                  onTap: () {
                    if (workoutSelected) return;
                    Navigator.of(context)
                        .pushReplacementNamed(AfScreen.activeWorkout);
                  },
                ),
              ),
              for (final ({String id, String label, IconData icon}) tab
                  in _rightTabs)
                Expanded(
                  child: _NavTab(
                    key: ValueKey<String>('nav-tab-${tab.id}'),
                    label: tab.label,
                    icon: tab.icon,
                    selected: tab.id == current,
                    onTap: () {
                      if (tab.id == current) return;
                      Navigator.of(context).pushReplacementNamed(tab.id);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Prominent, raised, rounded central navigation button for **Workout**.
class AfWorkoutNavButton extends StatelessWidget {
  const AfWorkoutNavButton({
    super.key,
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final Color bgColor = selected ? t.accentDark : t.accent;
    final BorderRadius borderRadius = BorderRadius.circular(20);

    return Semantics(
      selected: selected,
      button: true,
      label: 'Workout',
      child: Padding(
        // Raises the central Workout button visually above the smaller side
        // navigation items while keeping its full touch target inside the bar.
        padding: const EdgeInsets.only(bottom: 4),
        child: Container(
          width: 78,
          height: 58,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius,
            border: Border.all(
              color: selected ? Colors.white : t.accentDark,
              width: 1.5,
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: t.accent.withOpacity(0.38),
                blurRadius: 14,
                offset: const Offset(0, 5),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: borderRadius,
            child: InkWell(
              onTap: onTap,
              borderRadius: borderRadius,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.bolt_rounded,
                      size: 26,
                      color: Colors.white,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Workout',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavTab extends StatelessWidget {
  const _NavTab({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final Color color = selected ? t.accent : t.textMuted;
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: Material(
        color: selected ? t.accentTint : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(icon, size: 20, color: color),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The app frame: header, content, bottom navigation and the global toast.
class AfScaffold extends StatelessWidget {
  const AfScaffold({
    super.key,
    required this.screenId,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 112),
  });

  final String screenId;
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final bool loggedIn = AfAppScope.of(context).isLoggedIn;

    return Scaffold(
      backgroundColor: t.bgPage,
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              if (AfScreen.showsTopBar(screenId, isLoggedIn: loggedIn))
                AfTopBar(screenId: screenId),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: SingleChildScrollView(
                      padding: padding,
                      child: child,
                    ),
                  ),
                ),
              ),
              if (AfScreen.showsBottomNav(screenId, isLoggedIn: loggedIn))
                AfBottomNav(current: screenId),
            ],
          ),
          const AfToastHost(),
        ],
      ),
    );
  }
}

/// Renders the global toast above the bottom navigation.
class AfToastHost extends StatelessWidget {
  const AfToastHost({super.key});

  @override
  Widget build(BuildContext context) {
    final AppState state = AfAppScope.of(context);
    final String? message = state.toastText;
    if (message == null) return const SizedBox.shrink();
    final ToastTone tone = switch (state.toastKind) {
      ToastKind.success => ToastTone.success,
      ToastKind.info => ToastTone.info,
      ToastKind.danger => ToastTone.danger,
    };
    return Positioned(
      right: 0,
      bottom: 0,
      child: AfToastView(message: message, kind: tone),
    );
  }
}
