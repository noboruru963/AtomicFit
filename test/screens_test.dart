import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/app/shell.dart';
import 'package:atomfit/data/store.dart';
import 'package:atomfit/main.dart';
import 'package:atomfit/screens/home_screen.dart';
import 'package:atomfit/services/speech_source.dart';
import 'package:atomfit/state/app_state.dart';
import 'package:atomfit/strings.dart';
import 'package:atomfit/widgets/af_widgets.dart';

import 'helpers/fonts.dart';
import 'support/fake_speech_source.dart';

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
    AfScreen.lockScreenWidget,
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
        // The rest timer starts by itself, so stop it before the next route.
        state.dispose();
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
    await tester.ensureVisible(find.text('+1 reps'));
    await tester.pump();
    await tester.tap(find.text('+1 reps'));
    await tester.pump();
    expect(state.activeWorkout.repsInput, 9);

    // "Add Set" stores the set and opens the rest timer.
    await tester.ensureVisible(find.text('Add Set'));
    await tester.pump();
    await tester.tap(find.text('Add Set'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(state.activeWorkout.sets, hasLength(1));
    // The prototype upper-cases the rest timer heading.
    expect(find.text('REST COUNTDOWN'), findsOneWidget);

    // The countdown starts by itself after a set; there is no Start button.
    expect(state.isTimerRunning, isTrue);
    expect(find.text('Start'), findsNothing);
    expect(find.text('Pause'), findsOneWidget);

    // "-15s" also rewrites the boxes (02:00 -> 01:45).
    await tester.tap(find.text('-15s'));
    await tester.pump();
    expect(state.activeWorkout.restTotalSeconds, 105);
    expect(find.text('45'), findsOneWidget);

    // Pausing swaps the primary control to Continue.
    await tester.tap(find.text('Pause'));
    await tester.pump();
    expect(state.isTimerRunning, isFalse);
    expect(find.text('Continue'), findsOneWidget);

    // Reset goes back to the edited target and stays paused.
    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(state.isTimerRunning, isFalse);
    expect(state.restSecondsRemaining, 105);
    expect(tester.takeException(), isNull);

    // Let the toast auto-dismiss timer run out before the tree is torn down.
    await tester.pump(const Duration(seconds: 3));
    state.dispose();
  });

  testWidgets('the voice log turns commands into reps and a saved set',
      (WidgetTester tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppState state = AppState(store: _MemoryStore());
    await state.load();
    state.isLoggedIn = true;
    state.updateRepsInput(8);
    state.switchInputMethod('voice');
    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();
    Navigator.of(tester.element(find.byType(HomeScreen)))
        .pushNamed(AfScreen.activeWorkout);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    Future<void> runCommand(String command) async {
      final Finder field = find.byType(AfTextField).first;
      await tester.ensureVisible(field);
      await tester.enterText(field, command);
      await tester.pump();
      final Finder run = find.widgetWithText(
        AfButton,
        AfStrings.workoutVoiceRun,
      );
      await tester.ensureVisible(run);
      await tester.tap(run);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
    }

    // "add 10 reps" bumps the current set without saving it.
    await runCommand('add 10 reps');
    expect(state.activeWorkout.repsInput, 18);
    expect(find.text('18'), findsWidgets);
    expect(state.activeWorkout.sets, isEmpty);

    await runCommand('subtract 5 reps');
    expect(state.activeWorkout.repsInput, 13);

    await runCommand('set reps to 12');
    expect(state.activeWorkout.repsInput, 12);

    // "finished set" saves the set and opens the (auto-starting) rest timer.
    await runCommand('finished set');
    expect(state.activeWorkout.sets, hasLength(1));
    expect(state.activeWorkout.sets.single.reps, 12);
    expect(find.text('REST COUNTDOWN'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    state.dispose();
  });

  testWidgets('a recent command fills the box instead of running again',
      (WidgetTester tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppState state = AppState(store: _MemoryStore());
    await state.load();
    state.isLoggedIn = true;
    state.updateRepsInput(8);
    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();
    Navigator.of(tester.element(find.byType(HomeScreen)))
        .pushNamed(AfScreen.activeWorkout);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // "add 3 reps" is not one of the samples, so its chip is unique.
    state.applyVoiceCommand('add 3 reps');
    await tester.pump();
    expect(state.activeWorkout.repsInput, 11);

    final Finder recent = find.widgetWithText(AfButton, 'add 3 reps');
    await tester.ensureVisible(recent);
    await tester.tap(recent);
    await tester.pump();

    // The box now holds the line, but nothing was applied or saved.
    expect(state.activeWorkout.repsInput, 11);
    expect(state.activeWorkout.voiceSimText, 'add 3 reps');
    expect(state.activeWorkout.sets, isEmpty);

    await tester.pump(const Duration(seconds: 3));
    state.dispose();
  });

  testWidgets('the microphone turns speech into reps and a saved set',
      (WidgetTester tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final FakeSpeechSource speech = FakeSpeechSource();
    final AppState state = AppState(store: _MemoryStore());
    await state.load();
    state.isLoggedIn = true;
    state.speech = speech;
    state.updateRepsInput(8);
    state.switchInputMethod('voice');
    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();
    Navigator.of(tester.element(find.byType(HomeScreen)))
        .pushNamed(AfScreen.activeWorkout);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The first tap explains what the microphone is for, then opens it.
    await tester.tap(find.text(AfStrings.workoutVoiceSpeak));
    await tester.pumpAndSettle();
    expect(find.text(AfStrings.workoutMicExplainBody), findsOneWidget);
    await tester.tap(find.text(AfStrings.workoutMicExplainContinue));
    await tester.pumpAndSettle();

    expect(speech.starts, 1);
    expect(find.text(AfStrings.workoutVoiceStop), findsOneWidget);

    // Partial words fill the box but do not run anything yet.
    speech.say('add ten', isFinal: false);
    await tester.pump();
    expect(find.text('add ten'), findsOneWidget);
    expect(state.activeWorkout.repsInput, 8);

    speech.say('add 10 reps');
    await tester.pump();
    expect(state.activeWorkout.repsInput, 18);
    expect(state.activeWorkout.sets, isEmpty);
    expect(find.text(AfStrings.workoutVoiceSpeak), findsOneWidget);

    // Spoken "finished set" saves the set and opens the rest timer.
    await tester.tap(find.text(AfStrings.workoutVoiceSpeak));
    await tester.pumpAndSettle();
    expect(speech.starts, 2);
    speech.say('finished set');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(state.activeWorkout.sets, hasLength(1));
    expect(state.activeWorkout.sets.single.reps, 18);
    expect(find.text('REST COUNTDOWN'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    state.dispose();
  });

  testWidgets('a refused microphone keeps the typed commands working',
      (WidgetTester tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final FakeSpeechSource speech =
        FakeSpeechSource(status: SpeechStartStatus.permissionDenied);
    final AppState state = AppState(store: _MemoryStore());
    await state.load();
    state.isLoggedIn = true;
    state.speech = speech;
    state.updateRepsInput(8);
    state.switchInputMethod('voice');
    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();
    Navigator.of(tester.element(find.byType(HomeScreen)))
        .pushNamed(AfScreen.activeWorkout);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text(AfStrings.workoutVoiceSpeak));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AfStrings.workoutMicExplainContinue));
    await tester.pumpAndSettle();

    expect(find.text(AfStrings.workoutMicDenied), findsOneWidget);
    expect(find.text(AfStrings.workoutVoiceSpeak), findsOneWidget);

    // Typing still logs, which is the whole point of the fallback.
    final Finder field = find.byType(AfTextField).first;
    await tester.ensureVisible(field);
    await tester.enterText(field, 'add 10 reps');
    await tester.pump();
    final Finder run = find.widgetWithText(AfButton, AfStrings.workoutVoiceRun);
    await tester.ensureVisible(run);
    await tester.tap(run);
    await tester.pump();
    expect(state.activeWorkout.repsInput, 18);

    await tester.pump(const Duration(seconds: 3));
    state.dispose();
  });

  testWidgets('settings asks for a section before showing its options',
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
    Navigator.of(tester.element(find.byType(HomeScreen)))
        .pushNamed(AfScreen.settings);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The hub lists the four sections and no controls.
    expect(find.text(AfStrings.settingsSectionAppearance), findsOneWidget);
    expect(find.text(AfStrings.settingsSectionDevice), findsOneWidget);
    expect(find.text(AfStrings.settingsSectionPreferences), findsOneWidget);
    expect(find.text(AfStrings.settingsSectionAbout), findsOneWidget);
    expect(find.text(AfStrings.settingsNotifTitle), findsNothing);
    expect(find.text(AfStrings.settingsBellTitle), findsNothing);
    expect(find.text(AfStrings.settingsLightMode), findsNothing);

    // Appearance holds the theme switch.
    await tester.tap(find.text(AfStrings.settingsSectionAppearance));
    await tester.pump();
    expect(find.text(AfStrings.settingsLightMode), findsOneWidget);
    expect(find.text(AfStrings.settingsBellTitle), findsNothing);

    await tester.tap(find.textContaining(AfStrings.settingsBack));
    await tester.pump();

    // Device holds notifications, sensors, lock screen and haptics.
    await tester.tap(find.text(AfStrings.settingsSectionDevice));
    await tester.pump();
    expect(find.text(AfStrings.settingsNotifTitle), findsOneWidget);
    expect(find.text(AfStrings.settingsSensorTitle), findsOneWidget);
    expect(find.text(AfStrings.settingsLockscreenTitle), findsOneWidget);
    expect(find.text(AfStrings.settingsHapticTitle), findsOneWidget);
    expect(find.text(AfStrings.settingsBellTitle), findsNothing);

    await tester.tap(find.textContaining(AfStrings.settingsBack));
    await tester.pump();

    // Preferences holds the bell sound and the adaptive engine.
    await tester.tap(find.text(AfStrings.settingsSectionPreferences));
    await tester.pump();
    expect(find.text(AfStrings.settingsBellTitle), findsOneWidget);
    expect(find.text(AfStrings.settingsAdaptive), findsOneWidget);
    expect(find.text(AfStrings.settingsNotifTitle), findsNothing);

    await tester.tap(find.textContaining(AfStrings.settingsBack));
    await tester.pump();

    // About us holds the version and the credits.
    await tester.tap(find.text(AfStrings.settingsSectionAbout));
    await tester.pump();
    expect(find.text(AfStrings.settingsAboutCredits), findsOneWidget);
    expect(find.text(AfStrings.settingsBellTitle), findsNothing);

    expect(tester.takeException(), isNull);
    state.dispose();
  });

  testWidgets('the lock screen widget logs reps and starts the rest countdown',
      (WidgetTester tester) async {
    await loadAppFonts();
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final AppState state = AppState(store: _MemoryStore());
    await state.load();
    state.isLoggedIn = true;
    state.startProgramWorkout(state.programs.first.id, 'full');
    final String first = state.activeWorkout.currentExercise;
    final int startReps = state.activeWorkout.repsInput;

    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();
    Navigator.of(tester.element(find.byType(HomeScreen)))
        .pushNamed(AfScreen.lockScreenWidget);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Current exercise and the four actions are on the panel.
    expect(find.text(first), findsOneWidget);
    expect(find.text(AfStrings.lockWidgetAddSet), findsOneWidget);
    expect(find.text(AfStrings.lockWidgetNext), findsOneWidget);

    // ±1 rep works without opening the workout screen.
    await tester.tap(find.widgetWithText(AfButton, '+1'));
    await tester.pump();
    expect(state.activeWorkout.repsInput, startReps + 1);
    await tester.tap(find.widgetWithText(AfButton, '−1'));
    await tester.pump();
    expect(state.activeWorkout.repsInput, startReps);

    // Add set saves through the one write path and starts the countdown here.
    await tester.tap(find.text(AfStrings.lockWidgetAddSet));
    await tester.pump();
    expect(state.activeWorkout.sets, hasLength(1));
    expect(state.isTimerRunning, isTrue);
    expect(find.text(AfStrings.lockWidgetSkip), findsOneWidget);

    // Next exercise moves the panel to the following exercise.
    await tester.tap(find.text(AfStrings.lockWidgetNext));
    await tester.pump();
    expect(state.activeWorkout.currentExercise, isNot(first));

    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 3));
    state.dispose();
  });

  testWidgets('dragging an exercise handle reorders the program',
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
    Navigator.of(tester.element(find.byType(HomeScreen)))
        .pushNamed(AfScreen.programs);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final program = state.getActiveProgram()!;
    final String first = program.exercises.first.name;
    final String second = program.exercises[1].name;

    final Finder card = find
        .ancestor(
          of: find.text('1. $first'),
          matching: find.byType(AfCard),
        )
        .first;
    final Finder handles = find.descendant(
      of: card,
      matching: find.byTooltip(AfStrings.programsReorderTooltip),
    );
    expect(handles, findsNWidgets(program.exercises.length));

    // Drag the second exercise above the first one.
    await tester.ensureVisible(handles.at(1));
    await tester.pumpAndSettle();
    final TestGesture gesture =
        await tester.startGesture(tester.getCenter(handles.at(1)));
    for (int step = 0; step < 4; step++) {
      await gesture.moveBy(const Offset(0, -18));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(state.getActiveProgram()!.exercises.first.name, second);
    expect(find.text('1. $second'), findsWidgets);
    expect(find.text('2. $first'), findsWidgets);
    expect(tester.takeException(), isNull);

    // Let the "order saved" toast time out before the tree goes away.
    await tester.pump(const Duration(seconds: 3));
    state.dispose();
  });

  testWidgets('the program editor saves a dragged exercise order',
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
    Navigator.of(tester.element(find.byType(HomeScreen)))
        .pushNamed(AfScreen.programs);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final program = state.getActiveProgram()!;
    final String first = program.exercises.first.name;
    final String second = program.exercises[1].name;

    final Finder card = find
        .ancestor(
          of: find.text('1. $first'),
          matching: find.byType(AfCard),
        )
        .first;
    final Finder editButton =
        find.descendant(of: card, matching: find.text(AfStrings.programsEdit));
    await tester.ensureVisible(editButton);
    await tester.pumpAndSettle();
    await tester.tap(editButton);
    await tester.pumpAndSettle();

    // The dialog lists the same exercises with their own drag handles.
    final Finder handles = find.descendant(
      of: find.byType(Dialog),
      matching: find.byTooltip(AfStrings.programsReorderTooltip),
    );
    expect(handles, findsNWidgets(program.exercises.length));

    await tester.ensureVisible(handles.at(1));
    await tester.pumpAndSettle();
    final TestGesture gesture =
        await tester.startGesture(tester.getCenter(handles.at(1)));
    for (int step = 0; step < 4; step++) {
      await gesture.moveBy(const Offset(0, -18));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    // Nothing is stored until the dialog is saved.
    expect(state.getActiveProgram()!.exercises.first.name, first);

    await tester.ensureVisible(find.text(AfStrings.programsSaveChanges));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AfStrings.programsSaveChanges));
    await tester.pumpAndSettle();

    expect(state.getActiveProgram()!.exercises.first.name, second);
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 3));
    state.dispose();
  });
}
