import 'package:flutter/material.dart';

import '../strings.dart';
import '../theme/app_theme.dart';

/// Shown when the app cannot prepare its local data.
///
/// `main()` opens the database and seeds it before the first frame, so a
/// failure there used to leave the window empty (a black screen with no hint).
/// This screen names the problem and offers a retry instead.
class StartupErrorApp extends StatefulWidget {
  const StartupErrorApp({
    super.key,
    required this.error,
    this.stackTrace,
    this.retry,
  });

  final Object error;
  final StackTrace? stackTrace;
  final Future<void> Function()? retry;

  @override
  State<StartupErrorApp> createState() => _StartupErrorAppState();
}

class _StartupErrorAppState extends State<StartupErrorApp> {
  bool _retrying = false;

  Future<void> _retry() async {
    final Future<void> Function()? retry = widget.retry;
    if (retry == null || _retrying) return;
    setState(() => _retrying = true);
    try {
      await retry();
    } finally {
      if (mounted) setState(() => _retrying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AfStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AfTheme.light,
      darkTheme: AfTheme.dark,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AfStrings.startupErrorTitle,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AfStrings.startupErrorMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AfStrings.startupErrorDetailLabel,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: SingleChildScrollView(
                        child: SelectableText(
                          '${widget.error}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _retrying ? null : _retry,
                        child: _retrying
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(AfStrings.startupErrorRetry),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
