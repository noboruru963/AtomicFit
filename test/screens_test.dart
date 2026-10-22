import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/app/shell.dart';
import 'package:atomfit/data/store.dart';
import 'package:atomfit/main.dart';
import 'package:atomfit/screens/home_screen.dart';
import 'package:atomfit/state/app_state.dart';

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
