import 'package:ai_new/models/news_model.dart';

class HistoryService {
  static final List<NewsModel> histories = [];

  static void addHistory(NewsModel article) {
    // tránh trùng
    histories.removeWhere(
      (item) =>
          item.title == article.title &&
          item.sourceName == article.sourceName,
    );

    histories.insert(0, article,
    ); // mới nhất lên đầu
    
  }

  static void clear() {
    histories.clear();
  }
}