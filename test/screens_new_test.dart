import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/app/shell.dart';
import 'package:atomfit/data/store.dart';
import 'package:atomfit/main.dart';
import 'package:atomfit/screens/discover_screen.dart';
import 'package:atomfit/screens/exercise_detail_screen.dart';
import 'package:atomfit/screens/personal_details_screen.dart';
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

Future<AppState> _signedInState() async {
  final AppState state = AppState(store: _MemoryStore());
  await state.load();
  state.isLoggedIn = true;
  state.personalDetailsComplete = true;
  return state;
}

void main() {
  setUp(() async {
    await loadAppFonts();
  });

  void usePhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(360 * 3, 640 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('the discover screen shows the catalogue, filters and credits',
      (WidgetTester tester) async {
    usePhoneSize(tester);
    final AppState state = await _signedInState();
    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();

    await tester.tap(find.text('Discover'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(DiscoverScreen), findsOneWidget);
    expect(find.text(AfStrings.discoverTitle), findsOneWidget);
    expect(
      find.textContaining(
        AfStrings.discoverRepDbLink,
        findRichText: true,
      ),
      findsOneWidget,
    );

    // The body-part filters are offered as pills.
    expect(find.text('Chest'), findsWidgets);
    expect(find.text('Shoulders'), findsWidgets);

    // The result count reflects the catalogue.
    expect(
      find.textContaining('exercises'),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a body part filter narrows the results',
      (WidgetTester tester) async {
    usePhoneSize(tester);
    final AppState state = await _signedInState();
    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();

    await tester.tap(find.text('Discover'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap the "Chest" filter pill (the first one in the tree).
    await tester.tap(find.text('Chest').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(state.catalogueFilter, 'Chest');
    expect(
      state.catalogue.where(state.matchesCatalogueFilters).isNotEmpty,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('searching narrows the results', (WidgetTester tester) async {
    usePhoneSize(tester);
    final AppState state = await _signedInState();
    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();

    await tester.tap(find.text('Discover'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(
      find.byType(TextField).first,
      'squat',
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(state.catalogueSearch, 'squat');
    expect(
      state.catalogue
          .where((dynamic e) => state.matchesCatalogueFilters(e))
          .isNotEmpty,
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the exercise detail screen shows the instructions',
      (WidgetTester tester) async {
    usePhoneSize(tester);
    final AppState state = await _signedInState();
    state.openExerciseDetail('cat10');
    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();

    await tester.tap(find.text('Discover'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.pushNamed(AfScreen.discoverDetail);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(ExerciseDetailScreen), findsOneWidget);
    expect(find.text(AfStrings.detailTargetMuscles), findsOneWidget);
    expect(find.text(AfStrings.detailBackToDiscover), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the personal details screen reports invalid input',
      (WidgetTester tester) async {
    usePhoneSize(tester);
    final AppState state = await _signedInState();
    // A fresh account has no details yet, so the form starts out empty.
    state.user = state.user.copyWith(
      username: '',
      dobDay: '',
      dobMonth: '',
      dobYear: '',
      weightKg: '',
      heightCm: '',
    );
    state.personalDetailsComplete = false;
    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(PersonalDetailsScreen), findsOneWidget);
    expect(find.text(AfStrings.personalDetailsContinue), findsOneWidget);

    // Nothing is filled in, so the form must complain.
    final Finder continueButton =
        find.widgetWithText(AfButton, AfStrings.personalDetailsContinue);
    await tester.ensureVisible(continueButton);
    await tester.pump();
    await tester.tap(continueButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(AfErrorBanner), findsOneWidget);
    expect(state.personalDetailsComplete, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a complete personal details form is accepted',
      (WidgetTester tester) async {
    usePhoneSize(tester);
    final AppState state = await _signedInState();
    state.personalDetailsComplete = false;
    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The seeded profile already holds a valid date of birth, weight and
    // height, so the form can be submitted as it is.
    final Finder continueButton =
        find.widgetWithText(AfButton, AfStrings.personalDetailsContinue);
    await tester.ensureVisible(continueButton);
    await tester.pump();
    await tester.tap(continueButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(state.personalDetailsComplete, isTrue);
    expect(find.byType(AfErrorBanner), findsNothing);
    expect(tester.takeException(), isNull);

    // Let the toast auto-dismiss timer run out before the tree is torn down.
    await tester.pump(const Duration(seconds: 3));
  });
}
