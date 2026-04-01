class ArticleDateUtils {
  ArticleDateUtils._();

  /// Formats a publishedAt ISO string to "YYYY-MM-DD".
  static String? formatPublishedDate(String? publishedAt) {
    if (publishedAt == null) return null;
    if (publishedAt.contains('T')) return publishedAt.split('T').first;
    if (publishedAt.length >= 10) return publishedAt.substring(0, 10);
    return publishedAt;
  }

  /// Returns a human-readable relative time string (e.g. "2 hours ago").
  static String? formatRelativeTime(String? publishedAt) {
    if (publishedAt == null) return null;

    try {
      final publishedDate = DateTime.parse(publishedAt).toLocal();
      final difference = DateTime.now().difference(publishedDate);

      if (difference.inSeconds < 60) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes} minutes ago';
      if (difference.inHours < 24) return '${difference.inHours} hours ago';
      if (difference.inDays < 30) return '${difference.inDays} days ago';

      final weeks = (difference.inDays / 7).floor();
      if (weeks < 4) return '$weeks weeks ago';

      return '${publishedDate.day}/${publishedDate.month}/${publishedDate.year}';
    } catch (_) {
      return null;
    }
  }
}
