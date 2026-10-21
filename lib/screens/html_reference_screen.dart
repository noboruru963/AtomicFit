import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Debug-only screen that loads the original web prototype (`index.html`)
/// inside the app so the native port can be compared with the reference.
class HtmlReferenceScreen extends StatefulWidget {
  const HtmlReferenceScreen({super.key});

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
