import 'dart:convert';

import 'package:ai_new/models/news_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveService {
  SaveService._();

  static const String _kSavedKey = 'saved_articles';
  static const String _kSavedAtKey = 'saved_article_timestamps';

  static final List<NewsModel> savedArticles = [];
  static final Map<String, int> _savedAtMillisByKey = <String, int>{};

  static String _articleKey(NewsModel article) {
    final title = article.title.trim().toLowerCase();
    final source = (article.sourceName ?? '').trim().toLowerCase();
    return '$title|$source';
  }

  /// Must be called once at app startup (after WidgetsFlutterBinding.ensureInitialized).
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kSavedKey) ?? [];
    final rawSavedAt = prefs.getString(_kSavedAtKey);

    if (rawSavedAt != null && rawSavedAt.isNotEmpty) {
      try {
        final decoded = jsonDecode(rawSavedAt) as Map<String, dynamic>;
        _savedAtMillisByKey
          ..clear()
          ..addAll(
            decoded.map((key, value) => MapEntry(key, (value as num).toInt())),
          );
      } catch (_) {
        _savedAtMillisByKey.clear();
      }
    } else {
      _savedAtMillisByKey.clear();
    }

    savedArticles
      ..clear()
      ..addAll(
        raw.map(
          (e) => NewsModel.fromMap(jsonDecode(e) as Map<String, dynamic>),
        ),
      );

    var changed = false;
    final now = DateTime.now().millisecondsSinceEpoch;
    for (final article in savedArticles) {
      final key = _articleKey(article);
      if (!_savedAtMillisByKey.containsKey(key)) {
        _savedAtMillisByKey[key] = now;
        changed = true;
      }
    }

    if (changed) {
      await _persist();
    }
  }

  /// Returns true if the article was saved, false if it was already saved.
  static Future<bool> saveArticle(NewsModel article) async {
    final alreadySaved = savedArticles.any(
      (item) =>
          item.title == article.title && item.sourceName == article.sourceName,
    );

    if (alreadySaved) return false;

    savedArticles.add(article);
    _savedAtMillisByKey[_articleKey(article)] =
        DateTime.now().millisecondsSinceEpoch;
    await _persist();
    return true;
  }

  /// Removes a single article and persists.
  static Future<void> removeArticle(NewsModel article) async {
    savedArticles.removeWhere(
      (item) =>
          item.title == article.title && item.sourceName == article.sourceName,
    );
    _savedAtMillisByKey.remove(_articleKey(article));
    await _persist();
  }

  static Future<void> clearAll() async {
    savedArticles.clear();
    _savedAtMillisByKey.clear();
    await _persist();
  }

  static String savedAgoLabel(NewsModel article) {
    final savedAt = _savedAtMillisByKey[_articleKey(article)];
    if (savedAt == null) return 'Saved recently';

    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(savedAt),
    );

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes} minutes ago';
    if (diff.inDays < 1) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';

    final weeks = (diff.inDays / 7).floor();
    return '$weeks weeks ago';
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = savedArticles.map((a) => jsonEncode(a.toMap())).toList();
    await prefs.setStringList(_kSavedKey, encoded);
    await prefs.setString(_kSavedAtKey, jsonEncode(_savedAtMillisByKey));
  }
}
