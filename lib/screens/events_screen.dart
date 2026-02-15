// Events tab — displays the church events page in a full-screen WebView.
//
// The URL is set in AppConfig.eventsUrl. If the church moves their events
// to a different page, just update that constant.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/app_config.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          // Handle external links (mailto:, tel:, non-church URLs) so
          // footer buttons like "Say Hello" open correctly.
          onNavigationRequest: (request) {
            final url = request.url;
            if (url.startsWith('mailto:') ||
                url.startsWith('tel:') ||
                (!url.contains('rockcreektx.church') &&
                    !url.contains('youtube.com'))) {
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(AppConfig.eventsUrl));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}
