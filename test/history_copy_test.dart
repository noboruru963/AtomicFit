import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/app/shell.dart';
import 'package:atomfit/data/store.dart';
import 'package:atomfit/main.dart';
import 'package:atomfit/models/app_models.dart';
import 'package:atomfit/screens/home_screen.dart';
import 'package:atomfit/state/app_state.dart';
import 'package:atomfit/state/history_text.dart';
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

/// A state with one finished workout (one set, 20 kg × 10).
Future<AppState> _stateWithFinishedSession(_MemoryStore store) async {
  final AppState state = AppState(store: store);
  await state.load();
  state.isLoggedIn = true;
  state.updateWeightInput('20');
  state.updateRepsInput(10);
  state.logCurrentSet();
  state.finishActiveWorkout();
  return state;
}

void main() {
  testWidgets('the history detail copies the workout as plain text',
      (WidgetTester tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Capture what the app puts on the OS clipboard.
    String? copied;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'Clipboard.setData') {
          copied = (call.arguments as Map<Object?, Object?>)['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    final AppState state = await _stateWithFinishedSession(_MemoryStore());
    final WorkoutSession session = state.history.first;
    state.setSessionNote(session.id, 'Felt strong today.');

    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();
    Navigator.of(tester.element(find.byType(HomeScreen)))
        .pushNamed(AfScreen.history);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text(AfStrings.historyDetail).first);
    await tester.pumpAndSettle();

    final Finder copyButton =
        find.widgetWithText(AfButton, AfStrings.historyCopy);
    expect(copyButton, findsOneWidget);

    await tester.tap(copyButton);
    await tester.pump();

    expect(copied, isNotNull);
    // The exact wording is pinned by history_text_test.dart; here we only
    // check that the real session reached the clipboard.
    expect(copied, sessionToClipboardText(session));
    expect(copied, contains('#1 '));
    expect(copied, contains('(20 kg) : 10'));
    expect(copied, isNot(contains('Felt strong today.')));
    expect(find.text(AfStrings.historyCopied), findsWidgets);

    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 3));
    state.dispose();
  });

  testWidgets('copy is disabled for a workout without logged sets',
      (WidgetTester tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppState state = await _stateWithFinishedSession(_MemoryStore());
    // Older/seeded records can carry totals without per-set rows.
    final WorkoutSession bare = state.history.first;
    state.history = <WorkoutSession>[
      WorkoutSession(
        id: bare.id,
        userId: bare.userId,
        name: bare.name,
        type: bare.type,
        dateLabel: bare.dateLabel,
        dayOfMonth: bare.dayOfMonth,
        startedAtUtc: bare.startedAtUtc,
        durationMin: bare.durationMin,
        reps: bare.reps,
        volume: bare.volume,
        setsCount: bare.setsCount,
        methods: bare.methods,
        setsDetail: const <LoggedSet>[],
        createdAtUtc: bare.createdAtUtc,
        updatedAtUtc: bare.updatedAtUtc,
      ),
    ];

    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();
    Navigator.of(tester.element(find.byType(HomeScreen)))
        .pushNamed(AfScreen.history);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text(AfStrings.historyDetail).first);
    await tester.pumpAndSettle();

    final AfButton copy = tester.widget<AfButton>(
      find.widgetWithText(AfButton, AfStrings.historyCopy),
    );
    expect(copy.onPressed, isNull);

    expect(tester.takeException(), isNull);
    state.dispose();
  });
}
