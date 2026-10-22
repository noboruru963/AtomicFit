import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/data/store.dart';
import 'package:atomfit/main.dart';
import 'package:atomfit/state/app_state.dart';
import 'package:atomfit/strings.dart';

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

void main() {
  testWidgets('shows the home screen', (WidgetTester tester) async {
    await loadAppFonts();
    final AppState state = AppState(store: _MemoryStore());
    await state.load();

    await tester.pumpWidget(AtomFitApp(state: state));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text(AfStrings.appName), findsOneWidget);
    expect(find.text(AfStrings.homeMyPrograms), findsOneWidget);
  });
}
