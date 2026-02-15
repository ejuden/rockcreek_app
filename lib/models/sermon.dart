/// Data model for a sermon parsed from the church website.
///
/// Fields are populated by [ApiService.fetchSermons] from the
/// `__PRELOADED_STATE__` JSON embedded in the sermons page HTML.
/// The [slug] is the URL-friendly identifier used to build detail page URLs.
class Sermon {
  final String title;
  final String slug;
  final String? date;     // ISO 8601 string, e.g. "2026-02-15T10:00:00.000Z"
  final String? speaker;  // Display name, e.g. "Brad Wilkerson"

  const Sermon({
    required this.title,
    required this.slug,
    this.date,
    this.speaker,
  });

  /// Full relative path to the sermon detail page.
  String get detailUrl => '/sermons/$slug';
}
