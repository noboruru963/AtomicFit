import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/data/store.dart';
import 'package:atomfit/main.dart';
import 'package:atomfit/models/app_models.dart';
import 'package:atomfit/screens/home_screen.dart';
import 'package:atomfit/state/app_state.dart';
import 'package:atomfit/strings.dart';
import 'package:atomfit/theme/app_theme.dart';

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

WorkoutSession _session({
  required String id,
  required String name,
  required DateTime at,
}) =>
    WorkoutSession(
      id: id,
      userId: 'u_alex_01',
      name: name,
      type: 'full',
      dateLabel: 'label',
      dayOfMonth: at.day,
      startedAtUtc: at.toUtc().toIso8601String(),
      durationMin: 30,
      reps: 10,
      volume: 500,
      setsCount: 1,
      methods: const <String>['manual'],
      setsDetail: const <LoggedSet>[],
      createdAtUtc: at.toUtc().toIso8601String(),
      updatedAtUtc: at.toUtc().toIso8601String(),
    );

/// The Home screen with a hand-picked history, so dates are fully controlled.
Future<AppState> _stateWith(List<WorkoutSession> sessions) async {
  final AppState state = AppState(store: _MemoryStore());
  await state.load();
  state.isLoggedIn = true;
  state.history = sessions;
  return state;
}

/// A day of the current month that is not today, for "last month" markers.
int _otherDayOfMonth() => DateTime.now().day == 15 ? 16 : 15;

BoxDecoration _cell(WidgetTester tester, int day) {
  final Container cell = tester.widget<Container>(
    find.byKey(ValueKey<String>('cal-day-$day')),
  );
  return cell.decoration! as BoxDecoration;
}

void main() {
  testWidgets('a workout from last month does not mark this month',
      (WidgetTester tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(360 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final int oldDay = _otherDayOfMonth();
    final DateTime lastMonth = DateTime(now.year, now.month - 1, oldDay, 10);

    final WorkoutSession old = _session(
      id: 'old',
      name: 'October workout',
      at: lastMonth,
    );
    final WorkoutSession current = _session(
      id: 'current',
      name: 'Today workout',
      at: today.add(const Duration(hours: 10)),
    );

    final AppState state = await _stateWith(<WorkoutSession>[current, old]);
    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();

    final AfTokens t = Theme.of(tester.element(find.byType(HomeScreen)))
        .extension<AfTokens>()!;

    // The same day number in this month stays a plain, empty day.
    final BoxDecoration oldCell = _cell(tester, oldDay);
    expect(oldCell.color, t.bgSubtle);
    expect(oldCell.border, isNull);

    // Today is marked with a white ring on the blue "logged" fill.
    final BoxDecoration todayCell = _cell(tester, now.day);
    expect(todayCell.color, t.accent);
    final Border todayBorder = todayCell.border! as Border;
    expect(todayBorder.top.color, Colors.white);
    expect(todayBorder.top.width, 2);

    // The month count only counts this month.
    expect(
      find.text('${AfStrings.homeWorkoutsLogged} 1'),
      findsOneWidget,
    );

    // Tapping the old day number never opens the old workout.
    await tester.tap(find.byKey(ValueKey<String>('cal-day-$oldDay')));
    await tester.pumpAndSettle();
    expect(find.text('October workout'), findsNothing);
    expect(find.text(AfStrings.openInHistory), findsNothing);
    if (find.text(AfStrings.scheduleCancel).evaluate().isNotEmpty) {
      await tester.tap(find.text(AfStrings.scheduleCancel));
      await tester.pumpAndSettle();
    }

    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 3));
    state.dispose();
  });

  testWidgets('today without a workout gets an accent ring',
      (WidgetTester tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(360 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppState state = await _stateWith(<WorkoutSession>[]);
    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();

    final AfTokens t = Theme.of(tester.element(find.byType(HomeScreen)))
        .extension<AfTokens>()!;

    final BoxDecoration todayCell = _cell(tester, DateTime.now().day);
    expect(todayCell.color, Colors.transparent);
    final Border todayBorder = todayCell.border! as Border;
    expect(todayBorder.top.color, t.accent);
    expect(todayBorder.top.width, 2);

    expect(
      find.text('${AfStrings.homeWorkoutsLogged} 0'),
      findsOneWidget,
    );

    expect(tester.takeException(), isNull);
    state.dispose();
  });
}
