import 'package:ai_new/component/article_image.dart';
import 'package:ai_new/content.dart/all_content.dart';
import 'package:ai_new/models/news_model.dart';
import 'package:ai_new/utils/article_date_utils.dart';
import 'package:flutter/material.dart';

/// Large featured card used in the "TOP HEADLINE" section.
/// Navigates to [ArticleDetailPage] on tap, passing [articlePool] as related articles.
class TopArticleCard extends StatelessWidget {
  final NewsModel article;
  final List<NewsModel> articlePool;

  const TopArticleCard({
    super.key,
    required this.article,
    required this.articlePool,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailPage(
              imageUrl: article.imageUrl,
              sourceName: article.sourceName,
              articleUrl: article.articleUrl,
              time:
                  ArticleDateUtils.formatPublishedDate(article.publishedAt) ??
                  'Unknown time',
              title: article.title,
              description: article.description ?? 'No description',
              content: article.content,
               contentItems: article.contentItems,
               relatedArticles: articlePool,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArticleImage(
            imageUrl: article.imageUrl,
            width: double.infinity,
            height: 210,
          ),
          const SizedBox(height: 12),
          Text(
            article.sourceName ?? 'Unknown source',
            style: const TextStyle(
              color: Colors.blue,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            article.title,
            maxLines: 3,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            article.description ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
