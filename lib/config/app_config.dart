/// Centralized configuration for all URLs and contact info used in the app.
///
/// If the church website changes domains or page paths, update the URLs here.
/// All screens and services reference this file instead of hardcoding URLs.
class AppConfig {
  static const String baseUrl = 'https://www.rockcreektx.church';

  /// Sermons listing page — parsed by ApiService to extract sermon data.
  static const String sermonsUrl = '$baseUrl/sermons/';

  /// Events page — loaded directly in a WebView.
  static const String eventsUrl = '$baseUrl/events/';

  // ── Home screen action URLs ──
  // These map to the CTA buttons on the church website homepage.
  static const String giveUrl = '$baseUrl/give';
  static const String serveUrl = '$baseUrl/serve';
  static const String planVisitUrl = '$baseUrl/plan-your-visit';
  static const String nextStepsUrl = '$baseUrl/next-steps';
  static const String discipleshipUrl = '$baseUrl/discipleship';
  static const String meetTheTeamUrl = '$baseUrl/meet-the-team';

  /// Google Maps deep link for the church location.
  static const String mapUrl =
      'https://www.google.com/maps/search/?api=1&query=Rock+Creek+Church+Prosper+TX';

  // ── Church contact info shown on the Connect screen ──
  static const String churchName = 'Rock Creek Church';
  static const String churchAddress = '2860 West First Street\nProsper, TX 75078';
  static const String churchPhone = '(469) 815-5253';
  static const String churchEmail = 'info@rockcreektx.church';
  static const String churchWebsite = 'https://www.rockcreektx.church';
}
