import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Debug-only screen that loads the original web prototype (`index.html`)
/// inside the app so the native port can be compared with the reference.
class HtmlReferenceScreen extends StatefulWidget {
  const HtmlReferenceScreen({super.key});

  /// The WebView plugin only ships Android, iOS and macOS implementations.
  static bool get isSupported {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  State<HtmlReferenceScreen> createState() => _HtmlReferenceScreenState();
}

class _HtmlReferenceScreenState extends State<HtmlReferenceScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadFlutterAsset('index.html');
  }

  @override
  Widget build(BuildContext context) {
    if (!HtmlReferenceScreen.isSupported) {
      return Scaffold(
        appBar: AppBar(title: const Text('HTML reference (debug)')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'The HTML reference viewer needs Android, iOS or macOS.\n'
              'Open index.html in a browser instead.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTML reference (debug)'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
