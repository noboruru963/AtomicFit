import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled Inter fonts so widget tests measure text with the real
/// metrics instead of the placeholder test font.
Future<void> loadAppFonts() async {
  const List<String> files = <String>[
    'assets/fonts/Inter-Regular.ttf',
    'assets/fonts/Inter-Medium.ttf',
    'assets/fonts/Inter-SemiBold.ttf',
    'assets/fonts/Inter-Bold.ttf',
    'assets/fonts/Inter-ExtraBold.ttf',
  ];

  final FontLoader loader = FontLoader('Inter');
  for (final String file in files) {
    final File source = File(file);
    if (!source.existsSync()) continue;
    final Uint8List bytes = source.readAsBytesSync();
    loader.addFont(Future<ByteData>.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}
