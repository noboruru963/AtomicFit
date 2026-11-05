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

/// A state with one logged set, so the workout can be finished.
Future<AppState> _stateWithLoggedSet(_MemoryStore store) async {
  final AppState state = AppState(store: store);
  await state.load();
  state.isLoggedIn = true;
  state.updateWeightInput('20');
  state.updateRepsInput(10);
  state.logCurrentSet();
  return state;
}

void main() {
  testWidgets('the complete screen saves the note the user typed',
      (WidgetTester tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppState state = await _stateWithLoggedSet(_MemoryStore());
    final WorkoutSession session = state.finishActiveWorkout()!;

    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();
    Navigator.of(tester.element(find.byType(HomeScreen)))
        .pushNamed(AfScreen.workoutComplete);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(AfStrings.completeNoteLabel), findsOneWidget);
    final Finder saveButton =
        find.widgetWithText(AfButton, AfStrings.completeNoteSave);
    expect(saveButton, findsOneWidget);

    // Nothing is written while the box is empty.
    await tester.ensureVisible(saveButton);
    await tester.tap(saveButton);
    await tester.pump();
    expect(state.sessionById(session.id)!.note, '');

    // Typing and saving stores the note on the finished session.
    const String note = 'Today was good, but too much sodium makes it rough.';
    await tester.enterText(find.byType(TextField), note);
    await tester.pump();
    await tester.tap(saveButton);
    await tester.pump();
    expect(state.sessionById(session.id)!.note, note);
    // The toast is mid-animation, so the old and new copies can coexist.
    expect(find.text(AfStrings.completeNoteSaved), findsWidgets);

    // Leaving without pressing Save still keeps the text.
    await tester.enterText(find.byType(TextField), 'Second thoughts.');
    await tester.pump();
    final Finder home = find.widgetWithText(AfButton, AfStrings.completeGoHome);
    await tester.ensureVisible(home);
    await tester.pumpAndSettle();
    await tester.tap(home);
    await tester.pumpAndSettle();
    expect(state.sessionById(session.id)!.note, 'Second thoughts.');

    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 3));
    state.dispose();
  });

  testWidgets('the history detail shows the note and lets it be edited',
      (WidgetTester tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppState state = await _stateWithLoggedSet(_MemoryStore());
    final WorkoutSession session = state.finishActiveWorkout()!;
    state.setSessionNote(session.id, 'Felt strong today.');

    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();
    Navigator.of(tester.element(find.byType(HomeScreen)))
        .pushNamed(AfScreen.history);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text(AfStrings.historyDetail).first);
    await tester.pumpAndSettle();
    expect(find.text(AfStrings.historyNoteLabel), findsOneWidget);
    expect(find.text('Felt strong today.'), findsOneWidget);

    // Editing from the detail dialog updates the stored note.
    await tester.tap(find.text(AfStrings.historyNoteEdit));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Edited note.');
    await tester.tap(find.widgetWithText(AfButton, AfStrings.completeNoteSave));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    expect(state.sessionById(session.id)!.note, 'Edited note.');
    expect(find.text('Edited note.'), findsOneWidget);

    // Clearing the box removes the note and its block.
    await tester.tap(find.text(AfStrings.historyNoteEdit));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '');
    await tester.tap(find.widgetWithText(AfButton, AfStrings.completeNoteSave));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    expect(state.sessionById(session.id)!.note, '');
    expect(find.text(AfStrings.historyNoteAdd), findsOneWidget);
    expect(find.text(AfStrings.historyNoteLabel), findsNothing);

    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 3));
    state.dispose();
  });
}
