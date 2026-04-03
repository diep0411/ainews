import 'package:ai_new/models/news_model.dart';

class HistoryService {
  static final List<NewsModel> histories = [];
  static final Map<String, int> _accessedAtMillisByKey = <String, int>{};

  static String _articleKey(NewsModel article) {
    final title = article.title.trim().toLowerCase();
    final source = (article.sourceName ?? '').trim().toLowerCase();
    return '$title|$source';
  }

  static void addHistory(NewsModel article) {
    // Avoid duplicates by title + source and keep latest on top.
    histories.removeWhere(
      (item) =>
          item.title == article.title && item.sourceName == article.sourceName,
    );

    histories.insert(0, article);
    _accessedAtMillisByKey[_articleKey(article)] =
        DateTime.now().millisecondsSinceEpoch;
  }

  static String accessedAgoLabel(NewsModel article) {
    final millis = _accessedAtMillisByKey[_articleKey(article)];
    if (millis == null) return 'Just accessed';

    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(millis),
    );

    if (diff.inMinutes < 1) return 'Just accessed';
    if (diff.inHours < 1) return '${diff.inMinutes} minutes ago';
    if (diff.inDays < 1) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    final weeks = (diff.inDays / 7).floor();
    return '$weeks weeks ago';
  }

  static void clear() {
    histories.clear();
    _accessedAtMillisByKey.clear();
  }
}
