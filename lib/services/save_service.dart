import 'package:ai_new/models/news_model.dart';

class SaveService {
  SaveService._();

  static final List<NewsModel> savedArticles = [];

  static bool saveArticle(NewsModel article) {
    final alreadySaved = savedArticles.any(
      (item) =>
          item.title == article.title && item.sourceName == article.sourceName,
    );

    if (alreadySaved) {
      return false;
    }

    savedArticles.add(article);
    return true;
  }

  static void clearAll() {
    savedArticles.clear();
  }
}
