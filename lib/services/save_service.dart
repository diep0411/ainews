import 'dart:convert';

import 'package:ai_new/models/news_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveService {
  SaveService._();

  static const String _kSavedKey = 'saved_articles';

  static final List<NewsModel> savedArticles = [];

  /// Must be called once at app startup (after WidgetsFlutterBinding.ensureInitialized).
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kSavedKey) ?? [];
    savedArticles
      ..clear()
      ..addAll(
        raw.map((e) => NewsModel.fromMap(jsonDecode(e) as Map<String, dynamic>)),
      );
  }

  /// Returns true if the article was saved, false if it was already saved.
  static Future<bool> saveArticle(NewsModel article) async {
    final alreadySaved = savedArticles.any(
      (item) =>
          item.title == article.title && item.sourceName == article.sourceName,
    );

    if (alreadySaved) return false;

    savedArticles.add(article);
    await _persist();
    return true;
  }

  /// Removes a single article and persists.
  static Future<void> removeArticle(NewsModel article) async {
    savedArticles.removeWhere(
      (item) =>
          item.title == article.title && item.sourceName == article.sourceName,
    );
    await _persist();
  }

  static Future<void> clearAll() async {
    savedArticles.clear();
    await _persist();
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded =
        savedArticles.map((a) => jsonEncode(a.toMap())).toList();
    await prefs.setStringList(_kSavedKey, encoded);
  }
}
