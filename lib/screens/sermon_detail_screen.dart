// Sermon detail screen — loads the church website's sermon page in a WebView.
//
// Why a WebView instead of a YouTube embed?
// Rock Creek's YouTube videos have domain-restricted embedding — they only
// allow playback when embedded from rockcreektx.church. The church website
// uses a custom <youtube-video> Web Component (Nucleus platform) that loads
// the YouTube IFrame API from the church's domain, which satisfies the
// restriction. Loading the full sermon page in a WebView preserves this
// origin, so the video plays correctly.
//
// Data flow:
// 1. Receives a Sermon object from the sermons list.
// 2. Loads the full sermon detail page (rockcreektx.church/sermons/<slug>)
//    in a WebView so the Nucleus player handles video playback natively.
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/app_config.dart';
import '../models/sermon.dart';

class SermonDetailScreen extends StatefulWidget {
  final Sermon sermon;

  const SermonDetailScreen({super.key, required this.sermon});

  @override
  State<SermonDetailScreen> createState() => _SermonDetailScreenState();
}

class _SermonDetailScreenState extends State<SermonDetailScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Load the church's own sermon detail page. This ensures the YouTube
    // video plays correctly because the embed originates from rockcreektx.church.
    final url = '${AppConfig.baseUrl}/sermons/${widget.sermon.slug}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            setState(() {
              _isLoading = false;
            });
          },
          // Handle external links (mailto:, tel:, non-church URLs) by
          // opening them outside the WebView so buttons like "Say Hello"
          // in the church website footer work correctly.
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
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sermon.title),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
