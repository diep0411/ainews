import 'package:ai_new/component/article_image.dart';
import 'package:ai_new/content.dart/all_content.dart';
import 'package:ai_new/models/news_model.dart';
import 'package:ai_new/utils/article_date_utils.dart';
import 'package:flutter/material.dart';

/// Card used in "Latest News" lists and "Bài viết liên quan" sections.
/// Time labels are computed internally from [article.publishedAt].
class NewsLateCard extends StatelessWidget {
  final NewsModel article;
  final List<NewsModel>? articlePool;

  const NewsLateCard({
    super.key,
    required this.article,
    this.articlePool,
  });

  @override
  Widget build(BuildContext context) {
    final relativeTime =
        ArticleDateUtils.formatRelativeTime(article.publishedAt) ?? 'Không rõ';
    final publishedTime =
        ArticleDateUtils.formatPublishedDate(article.publishedAt) ??
        'Không rõ thời gian';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailPage(
              imageUrl: article.imageUrl,
              sourceName: article.sourceName,
              time: publishedTime,
              title: article.title,
              description: article.description ?? 'Không có mô tả',
              content: article.content,
              relatedArticles: articlePool,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        color: Colors.grey.shade200,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ArticleImage(imageUrl: article.imageUrl, width: 120, height: 120),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'TIME',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '• $relativeTime',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    article.title,
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    article.description ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
