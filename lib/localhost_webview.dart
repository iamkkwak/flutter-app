import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/write_review_page.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:html' as html;

class LocalhostWebView extends StatefulWidget {
  const LocalhostWebView({super.key});

  @override
  _LocalhostWebViewState createState() => _LocalhostWebViewState();
}

class _LocalhostWebViewState extends State<LocalhostWebView> {
  late InAppWebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      html.window.onMessage.listen((event) {
        final data = event.data;

        if (data is Map && data['type'] == 'openWriteReviewPage') {
          if (!mounted) {
            return;
          }

          Future.microtask(() {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WriteReviewPage()),
            );
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri("http://localhost:3000")),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onConsoleMessage: (controller, consoleMessage) {
          debugPrint('Console: ${consoleMessage.message}');
        },
        onJsAlert: (controller, jsAlertRequest) async {
          return JsAlertResponse(handledByClient: true);
        },
        onReceivedError: (controller, request, error) {
          debugPrint('Error: ${error.description}');
        },
        onLoadStart: (controller, url) {
          controller.addJavaScriptHandler(
            handlerName: 'openWriteReviewPage',
            callback: (args) async {
              final reviewResult = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WriteReviewPage()),
              );

              if (reviewResult != null) {
                final jsonReview = jsonEncode(reviewResult);
                controller.evaluateJavascript(
                  source: 'showReview($jsonReview)',
                );
              }

              return null;
            },
          );
        },
      )),
    );
  }
}
