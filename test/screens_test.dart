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
    AfScreen.home,
    AfScreen.programs,
    AfScreen.activeWorkout,
    AfScreen.timer,
    AfScreen.workoutComplete,
    AfScreen.history,
    AfScreen.discover,
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
        await pumpRoute(tester, state, route);
        expect(
          tester.takeException(),
          isNull,
          reason: 'exception while rendering $route',
        );
      }
    });
  }
}
