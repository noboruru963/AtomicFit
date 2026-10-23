import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/app/shell.dart';
import 'package:atomfit/data/store.dart';
import 'package:atomfit/main.dart';
import 'package:atomfit/models/app_models.dart';
import 'package:atomfit/screens/home_screen.dart';
import 'package:atomfit/state/app_state.dart';
import 'package:atomfit/strings.dart';
import 'package:atomfit/widgets/af_widgets.dart';

import 'helpers/fonts.dart';

class _MemoryStore implements AtomFitStore {
  Map<String, dynamic>? data;

  @override
  Future<Map<String, dynamic>?> read() async => data;

  @override
  Future<void> write(Map<String, dynamic> document) async {
    data = document;
  }
}

/// Renders every screen at phone width in both themes and fails on any
/// layout overflow or runtime exception.
void main() {
  const List<String> routes = <String>[
    AfScreen.login,
    AfScreen.register,
    AfScreen.personalDetails,
    AfScreen.home,
    AfScreen.programs,
    AfScreen.activeWorkout,
    AfScreen.timer,
    AfScreen.workoutComplete,
    AfScreen.history,
    AfScreen.discover,
    AfScreen.discoverDetail,
    AfScreen.profile,
    AfScreen.settings,
    AfScreen.quizPrompt,
    AfScreen.quizQuestion,
    AfScreen.quizExplainer,
    AfScreen.quizAdjusted,
  ];

  Future<void> pumpRoute(
    WidgetTester tester,
    AppState state,
    String route,
  ) async {
    await tester.pumpWidget(
      KeyedSubtree(
        key: ValueKey<String>('route-$route-${state.isDarkMode}'),
        child: AtomFitApp(state: state),
      ),
    );
    await tester.pump();
    final BuildContext context = tester.element(find.byType(HomeScreen));
    Navigator.of(context).pushNamed(route);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  for (final bool dark in <bool>[false, true]) {
    testWidgets('every screen renders (${dark ? 'dark' : 'light'})',
        (WidgetTester tester) async {
      await loadAppFonts();
      tester.view.physicalSize = const Size(360 * 3, 640 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      for (final String route in routes) {
        final AppState state = AppState(store: _MemoryStore());
        await state.load();
        state.isDarkMode = dark;
        // The app opens on the login screen until a user is signed in.
        state.isLoggedIn = true;
        await pumpRoute(tester, state, route);
        expect(
          tester.takeException(),
          isNull,
          reason: 'exception while rendering $route',
        );
      }
    });
  }

  testWidgets('Empty Workout button is removed from the Home page',
      (WidgetTester tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppState state = AppState(store: _MemoryStore());
    await state.load();
    state.isLoggedIn = true;
    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();

    expect(find.text(AfStrings.homeEmptyWorkout), findsNothing);
    expect(find.text('Start Push Day'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'tapping an empty calendar date schedules, views, edits, and removes a workout without changing completed count',
      (WidgetTester tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final DateTime fixedNow = DateTime(2026, 10, 23, 14, 0);
    final AppState state = AppState(store: _MemoryStore(), now: fixedNow);
    await state.load();
    state.isLoggedIn = true;
    final int initialCompletedCount = state.history.length;

    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();

    // Pick a day in October 2026 that has no completed session (day 25).
    expect(
      state.history.any((WorkoutSession s) => s.dayOfMonth == 25),
      isFalse,
    );

    final Finder day25 = find.byKey(const ValueKey<String>('calendar-day-25'));
    await tester.ensureVisible(day25);
    await tester.pump();
    await tester.tap(day25);
    await tester.pumpAndSettle();

    // The Schedule Workout dialog opens with date, time, and program selectors.
    expect(find.text(AfStrings.calendarScheduleTitle), findsOneWidget);
    expect(find.text('October 25, 2026'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('schedule-time-dropdown')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('schedule-program-dropdown')),
      findsOneWidget,
    );

    // Save the scheduled workout.
    await tester.tap(
      find.byKey(const ValueKey<String>('schedule-save-button')),
    );
    await tester.pumpAndSettle();

    // Scheduled workout is stored and shown on calendar day 25; completed count is unchanged.
    expect(state.scheduledWorkouts, hasLength(1));
    expect(state.scheduledWorkoutForDay(25)?.programName, 'Push Day');
    expect(state.history.length, initialCompletedCount);
    expect(
      find.byKey(const ValueKey<String>('calendar-scheduled-indicator-25')),
      findsOneWidget,
    );

    // Tap day 25 again to view scheduled workout details.
    await tester.tap(day25);
    await tester.pumpAndSettle();
    expect(find.text('SCHEDULED'), findsOneWidget);
    expect(find.text('Workout Program: Push Day'), findsOneWidget);
    expect(find.text('Planned Time: 09:00'), findsOneWidget);

    // Tap Edit to modify the scheduled workout.
    await tester.tap(
      find.widgetWithText(AfButton, AfStrings.calendarEditSchedule),
    );
    await tester.pumpAndSettle();
    expect(find.text(AfStrings.calendarEditScheduleTitle), findsOneWidget);

    // Change the program to Pull Day and save.
    await tester.tap(
      find.byKey(const ValueKey<String>('schedule-program-dropdown')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Pull Day').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('schedule-save-button')),
    );
    await tester.pumpAndSettle();

    expect(state.scheduledWorkoutForDay(25)?.programName, 'Pull Day');
    expect(state.history.length, initialCompletedCount);

    // Tap day 25 again and remove the scheduled workout.
    await tester.tap(day25);
    await tester.pumpAndSettle();
    expect(find.text('Workout Program: Pull Day'), findsOneWidget);
    await tester.tap(
      find.widgetWithText(AfButton, AfStrings.calendarRemoveSchedule),
    );
    await tester.pumpAndSettle();

    expect(state.scheduledWorkoutForDay(25), isNull);
    expect(
      find.byKey(const ValueKey<String>('calendar-scheduled-indicator-25')),
      findsNothing,
    );
    expect(state.history.length, initialCompletedCount);

    await tester.pump(const Duration(seconds: 3));
    state.dispose();
  });

  testWidgets(
      'Workout navigation button is centered, larger than side tabs, and navigates to Workout page',
      (WidgetTester tester) async {
    await loadAppFonts();
    for (final Size screenSize in const <Size>[
      Size(360 * 3, 640 * 3),
      Size(412 * 3, 892 * 3),
    ]) {
      tester.view.physicalSize = screenSize;
      tester.view.devicePixelRatio = 3.0;

      final AppState state = AppState(store: _MemoryStore());
      await state.load();
      state.isLoggedIn = true;
      await tester.pumpWidget(AtomFitApp(state: state));
      await tester.pump();

      final Finder workoutBtn =
          find.byKey(const ValueKey<String>('nav-workout-button'));
      final Finder homeTab = find.byKey(const ValueKey<String>('nav-tab-home'));
      final Finder programsTab =
          find.byKey(const ValueKey<String>('nav-tab-programs'));
      final Finder historyTab =
          find.byKey(const ValueKey<String>('nav-tab-history'));
      final Finder discoverTab =
          find.byKey(const ValueKey<String>('nav-tab-discover'));

      expect(workoutBtn, findsOneWidget);
      expect(homeTab, findsOneWidget);
      expect(programsTab, findsOneWidget);
      expect(historyTab, findsOneWidget);
      expect(discoverTab, findsOneWidget);

      final Rect workoutRect = tester.getRect(workoutBtn);
      final Rect homeRect = tester.getRect(homeTab);
      final Rect programsRect = tester.getRect(programsTab);
      final Rect historyRect = tester.getRect(historyTab);

      // Workout button is taller/larger and raised (top edge higher than side tabs).
      expect(workoutRect.height, greaterThan(homeRect.height));
      expect(workoutRect.top, lessThan(homeRect.top));

      // Centered horizontally on the screen and does not overlap adjacent tabs.
      final double logicalWidth = screenSize.width / 3.0;
      expect(workoutRect.center.dx, closeTo(logicalWidth / 2, 2.0));
      expect(programsRect.right, lessThanOrEqualTo(workoutRect.left));
      expect(historyRect.left, greaterThanOrEqualTo(workoutRect.right));

      // Tapping Workout opens the Active Workout screen.
      await tester.tap(workoutBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Current Exercise'), findsOneWidget);
      expect(tester.takeException(), isNull);

      state.dispose();
    }
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  testWidgets('starting a program opens the workout and logs a set',
      (WidgetTester tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppState state = AppState(store: _MemoryStore());
    await state.load();
    state.isLoggedIn = true;
    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();

    // "Start Push Day" on the home card.
    await tester.tap(find.text('Start Push Day'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Current Exercise'), findsOneWidget);

    // "+1 reps" bumps the rep counter (Push Day starts at 8 reps).
    await tester.tap(find.text('+1 reps'));
    await tester.pump();
    expect(state.activeWorkout.repsInput, 9);

    // "Add Set" stores the set and opens the rest timer.
    await tester.tap(find.text('Add Set'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(state.activeWorkout.sets, hasLength(1));
    // The prototype upper-cases the rest timer heading.
    expect(find.text('REST COUNTDOWN'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Let the toast auto-dismiss timer run out before the tree is torn down.
    await tester.pump(const Duration(seconds: 3));
    state.dispose();
  });
}
