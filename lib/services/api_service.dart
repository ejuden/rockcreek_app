import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/sermon.dart';

/// Service responsible for fetching and parsing sermon data from the church website.
///
/// The Rock Creek website is built on the Nucleus church platform, which is a
/// JavaScript SPA. The HTML returned by the server contains a base64-encoded JSON
/// blob in `window.__PRELOADED_STATE__` that holds all the page data, including
/// sermon titles, slugs, dates, speakers, and media URLs.
///
/// Parsing strategy:
/// 1. Fetch the raw HTML via HTTP GET.
/// 2. Extract the base64 string from `window.__PRELOADED_STATE__ = "..."`.
/// 3. Base64-decode and JSON-parse to get the full state object.
/// 4. Walk `queryState.queries` to find sermon entries.
class ApiService {
  /// Regex to extract the base64-encoded preloaded state from HTML.
  /// Matches: window.__PRELOADED_STATE__ = "BASE64STRING"
  static final _preloadedStateRegex =
      RegExp(r'window\.__PRELOADED_STATE__\s*=\s*"([^"]+)"');

  /// Fetches the sermon listing page and returns a list of [Sermon] objects.
  ///
  /// Parses the `__PRELOADED_STATE__` JSON from the sermons page HTML.
  /// Collects sermons from all embedded queries (featured, playlists, speakers)
  /// and deduplicates by slug, returning them sorted newest-first.
  static Future<List<Sermon>> fetchSermons() async {
    final response = await http.get(Uri.parse(AppConfig.sermonsUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to load sermons page (${response.statusCode})');
    }

    final state = _extractPreloadedState(response.body);
    if (state == null) {
      throw Exception('Could not find preloaded state in sermons page');
    }

    return _parseSermonsFromState(state);
  }

  /// Fetches a sermon detail page and extracts the YouTube video URL.
  ///
  /// Parses the `__PRELOADED_STATE__` JSON from the detail page HTML.
  /// Looks for `mediaItems` in the page sections, finding entries with
  /// type "embed/video" that contain a YouTube `href`.
  /// Returns null if no video URL is found.
  static Future<String?> fetchSermonVideoUrl(String slug) async {
    final url = '${AppConfig.baseUrl}/sermons/$slug';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load sermon detail page (${response.statusCode})');
    }

    final state = _extractPreloadedState(response.body);
    if (state == null) {
      throw Exception('Could not find preloaded state in sermon detail page');
    }

    return _parseVideoUrlFromState(state);
  }

  /// Extracts and decodes the `__PRELOADED_STATE__` base64 JSON from raw HTML.
  /// Returns the decoded JSON as a Map, or null if not found.
  static Map<String, dynamic>? _extractPreloadedState(String html) {
    final match = _preloadedStateRegex.firstMatch(html);
    if (match == null) return null;

    try {
      final base64String = match.group(1)!;
      final decoded = utf8.decode(base64Decode(base64String));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Walks through all queries in the preloaded state to collect sermon entries.
  ///
  /// The state structure is:
  /// ```
  /// queryState.queries[n].state.data.pages[0].sermons[...]
  /// ```
  /// Each sermon object has: title, slug, date, speakerIds, speakers map.
  /// We deduplicate by slug and sort by date descending.
  static List<Sermon> _parseSermonsFromState(Map<String, dynamic> state) {
    final sermons = <Sermon>[];
    final seenSlugs = <String>{};

    try {
      final queries = state['queryState']?['queries'] as List<dynamic>? ?? [];

      for (final query in queries) {
        // Only process queries that contain sermon data
        final queryKey = query['queryKey'] as List<dynamic>? ?? [];
        if (queryKey.isEmpty || queryKey[0] != 'sermonHub') continue;
        if (queryKey.length < 2 || queryKey[1] != 'sermon') continue;

        final data = query['state']?['data'];
        if (data == null) continue;

        final pages = data['pages'] as List<dynamic>? ?? [];
        for (final page in pages) {
          final sermonList = page['sermons'] as List<dynamic>? ?? [];
          for (final s in sermonList) {
            final slug = s['slug'] as String?;
            final title = s['title'] as String?;
            if (slug == null || title == null || seenSlugs.contains(slug)) {
              continue;
            }
            seenSlugs.add(slug);

            // Extract speaker name from the speakers map
            String? speakerName;
            final speakers = s['speakers'] as Map<String, dynamic>? ?? {};
            if (speakers.isNotEmpty) {
              final firstSpeaker =
                  speakers.values.first as Map<String, dynamic>?;
              speakerName = firstSpeaker?['displayName'] as String?;
            }

            sermons.add(Sermon(
              title: title,
              slug: slug,
              date: s['date'] as String?,
              speaker: speakerName,
            ));
          }
        }
      }
    } catch (e) {
      // If parsing fails, return whatever we've collected so far
    }

    // Sort by date descending (newest first)
    sermons.sort((a, b) {
      if (a.date == null && b.date == null) return 0;
      if (a.date == null) return 1;
      if (b.date == null) return -1;
      return b.date!.compareTo(a.date!);
    });

    return sermons;
  }

  /// Extracts a YouTube embed URL from the sermon detail page state.
  ///
  /// The state structure for detail pages is:
  /// ```
  /// queryState.queries[0].state.data.page.sections.<sectionId>.payload
  ///   .blocks[0].sermon.mediaItems.<mediaId>.href
  /// ```
  /// We look for mediaItems with type "embed/video" containing a YouTube href.
  /// The YouTube watch URL is converted to an embed URL for WebView display.
  static String? _parseVideoUrlFromState(Map<String, dynamic> state) {
    try {
      final queries = state['queryState']?['queries'] as List<dynamic>? ?? [];

      for (final query in queries) {
        final queryKey = query['queryKey'] as List<dynamic>? ?? [];
        // Look for the page query (first element is "sermonHub", second is "page")
        if (queryKey.length < 2 ||
            queryKey[0] != 'sermonHub' ||
            queryKey[1] != 'page') {
          continue;
        }

        final pageData = query['state']?['data']?['page'];
        if (pageData == null) continue;

        final sections = pageData['sections'] as Map<String, dynamic>? ?? {};

        for (final section in sections.values) {
          final blocks =
              (section as Map<String, dynamic>?)?['payload']?['blocks']
                  as List<dynamic>? ??
              [];

          for (final block in blocks) {
            final sermon = (block as Map<String, dynamic>?)?['sermon']
                as Map<String, dynamic>?;
            if (sermon == null) continue;

            final mediaItems =
                sermon['mediaItems'] as Map<String, dynamic>? ?? {};

            for (final media in mediaItems.values) {
              final mediaMap = media as Map<String, dynamic>?;
              if (mediaMap == null) continue;

              final type = mediaMap['type'] as String? ?? '';
              final href = mediaMap['href'] as String? ?? '';

              // Match embed/video type with a YouTube URL
              if (type == 'embed/video' && href.contains('youtube.com')) {
                return _convertToEmbedUrl(href);
              }
            }

            // Fallback: also check for liveStream/link type with YouTube URL
            for (final media in mediaItems.values) {
              final mediaMap = media as Map<String, dynamic>?;
              if (mediaMap == null) continue;

              final href = mediaMap['href'] as String? ?? '';
              if (href.contains('youtube.com/watch')) {
                return _convertToEmbedUrl(href);
              }
            }
          }
        }

        // Also check the sermon query (queries with sermon data ordered by date)
        // which may appear on the detail page
        final pagesData = query['state']?['data']?['pages'] as List<dynamic>?;
        if (pagesData != null) {
          for (final page in pagesData) {
            final sermonList = page['sermons'] as List<dynamic>? ?? [];
            for (final s in sermonList) {
              final mediaItems =
                  (s as Map<String, dynamic>)['mediaItems'] as Map<String, dynamic>? ?? {};
              for (final media in mediaItems.values) {
                final mediaMap = media as Map<String, dynamic>?;
                if (mediaMap == null) continue;
                final href = mediaMap['href'] as String? ?? '';
                if (href.contains('youtube.com')) {
                  return _convertToEmbedUrl(href);
                }
              }
            }
          }
        }
      }
    } catch (e) {
      // Parsing failed — return null
    }

    return null;
  }

  /// Converts a YouTube watch URL to an embeddable URL.
  /// Example: https://www.youtube.com/watch?v=ABC123
  ///       -> https://www.youtube.com/embed/ABC123
  static String _convertToEmbedUrl(String watchUrl) {
    final uri = Uri.tryParse(watchUrl);
    if (uri == null) return watchUrl;

    final videoId = uri.queryParameters['v'];
    if (videoId != null) {
      return 'https://www.youtube.com/embed/$videoId';
    }

    // Already an embed URL or other format — return as-is
    return watchUrl;
  }
}
